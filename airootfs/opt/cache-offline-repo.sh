#!/usr/bin/env bash
# Build the offline repository used by Anarchy-Installer-Offline.
#
# This script populates airootfs/opt/arch-offline-repo with every package that
# the installer needs, together with the complete dependency closure:
#
#   * official Arch packages (core/extra/multilib) are downloaded with pacman
#   * third-party/AUR packages are reused from the cache, restored from
#     anarchy-repo git history, or built from the AUR with makepkg
#   * everything is resolved in a single transaction, so the official
#     dependencies of the AUR packages are downloaded too
#   * the freshly synced core/extra/multilib databases are shipped alongside,
#     so the installed system has usable sync databases on first boot
#
# The repository index itself is created afterwards by repo_builder.sh.
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
GIT_ROOT="$(dirname -- "$SCRIPT_DIR")"
CACHE_DIR="$SCRIPT_DIR/airootfs/opt/arch-offline-repo"
PACKAGE_REPO="${ANARCHY_REPO_DIR:-$GIT_ROOT/anarchy-repo/x86_64}"
SOURCE_PACMAN_CONF="${PACMAN_CONF:-/etc/pacman.conf}"

BUILD_CONF="$(mktemp "${TMPDIR:-/tmp}/offline-build-pacman.XXXXXX.conf")"
RESOLVE_CONF="$(mktemp "${TMPDIR:-/tmp}/offline-resolve-pacman.XXXXXX.conf")"
DB_DIR="$(mktemp -d "${TMPDIR:-/tmp}/offline-resolve-db.XXXXXX")"
REPO_INDEX_DIR="$(mktemp -d "${TMPDIR:-/tmp}/offline-local-repo.XXXXXX")"
AUR_BUILD_DIR=''
INSTALLER_TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/anarchy-installer-src.XXXXXX")"

cleanup() {
    sudo rm -rf -- "$DB_DIR" 2>/dev/null || true
    rm -rf -- "$REPO_INDEX_DIR"
    [[ -z "$AUR_BUILD_DIR" ]] || rm -rf -- "$AUR_BUILD_DIR"
    [[ -z "$INSTALLER_TMP_DIR" ]] || rm -rf -- "$INSTALLER_TMP_DIR"
    rm -f "$BUILD_CONF" "$RESOLVE_CONF"
}
trap cleanup EXIT

if [[ ! -f "$SOURCE_PACMAN_CONF" ]]; then
    echo "Missing pacman config: $SOURCE_PACMAN_CONF" >&2
    exit 1
fi

INSTALLER_PACKAGE=anarchy-installer

# The installer is the single source of truth for what ends up on the target
# system. Its PACSTRAP_PACKAGES list is read at build time, so the offline
# repository always contains exactly the packages the installer installs
# (plus their full dependency closure, resolved by pacman below).
INSTALLER_SOURCE="${ANARCHY_INSTALLER_SOURCE:-}"

# AUR helpers are installed by the installer via $AUR_HELPER_PACKAGE, but the
# actual name is chosen at runtime, so all of them are cached.
AUR_HELPER_PACKAGES=(yay paru pikaur-git)

# Packages the installer may install depending on the user's choices
# (currently the optional NCT6687D DKMS driver).
OPTIONAL_PACKAGES=(dkms base-devel)

read_installer_script() {
    local repo_dir="$GIT_ROOT/anarchy-installer"
    local script="$repo_dir/Anarchy-Installer-Offline"
    local -a archives

    if [[ -n "${INSTALLER_SOURCE:-}" ]]; then
        [[ -f "$INSTALLER_SOURCE" ]] || {
            echo "ANARCHY_INSTALLER_SOURCE is not a file: $INSTALLER_SOURCE" >&2
            return 1
        }
        printf '%s\n' "$INSTALLER_SOURCE"
        return 0
    fi

    # Prefer the built package: that is the script the ISO actually runs.
    shopt -s nullglob
    archives=("$PACKAGE_REPO"/anarchy-installer-*.pkg.tar.zst)
    shopt -u nullglob
    if (( ${#archives[@]} > 0 )); then
        local package
        package=$(printf '%s\n' "${archives[@]}" | sort -V | tail -n1)
        tar -xOf "$package" usr/local/bin/Anarchy-Installer-Offline > "$INSTALLER_TMP_DIR/Anarchy-Installer-Offline" || return 1
        printf '%s\n' "$INSTALLER_TMP_DIR/Anarchy-Installer-Offline"
        return 0
    fi

    # Fall back to the source checkout when the package has not been built.
    if [[ -f "$script" ]]; then
        printf '%s\n' "$script"
        return 0
    fi

    echo "No built anarchy-installer package or installer source found." >&2
    return 1
}

read_installer_packages() {
    local source_file
    source_file=$(read_installer_script) || return 1

    sed -n '/^PACSTRAP_PACKAGES=(/,/^)/p' "$source_file" \
        | sed '1s/^PACSTRAP_PACKAGES=(//; $s/^)$//' \
        | sed 's/#.*//' \
        | tr ' ' '\n' \
        | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
        | grep -vE '^$|\$' \
        | sort -u
}

mapfile -t INSTALL_PACKAGES < <(read_installer_packages)
if (( ${#INSTALL_PACKAGES[@]} == 0 )); then
    echo "Could not read PACSTRAP_PACKAGES from the Anarchy-Installer-Offline script." >&2
    exit 1
fi

# Third-party packages. pacman cannot fetch these from the AUR, so they are
# reused from $CACHE_DIR, restored from anarchy-repo history, or built with
# makepkg before the dependency resolution runs.
THIRD_PARTY_PACKAGES=(
    arch-update goverlay-git gradience-git grim-git gtk2 hyprmon-bin hyprscratch
    kvantum-qt6-git nautilus-admin-gtk4 nautilus-open-any-terminal-git oh-my-zsh-git
    python-anyascii python-cssutils python-encutils python-libsass
    python-material-color-utilities python-pywal16 python-pywalfox python-yapsy-git
    qt5-styleplugins slurp-git vesktop-bin ttf-font-awesome-4 ttf-font-awesome-5
    vkbasalt wf-recorder-git xfce-polkit zsh-autoswitch-virtualenv-git
    zsh-fast-syntax-highlighting libcava ttf-rubik-vf qt6-m3shapes-git quickshell-git
    rewaita wlsunset qt5-multimedia
)

# AUR-only dependencies of the third-party packages above. pacman cannot
# download these from the official repositories, so they have to be built and
# indexed as well; otherwise the final dependency resolution fails with
# "unable to satisfy dependency". They are not listed in the installer's
# PACSTRAP_PACKAGES because pacstrap pulls them in as dependencies.
AUR_DEPENDENCY_PACKAGES=(
    python-fortune-python
)

# Everything the AUR builder must produce has to be installed by the
# installer; otherwise it would be cached but never used.
for package in "${THIRD_PARTY_PACKAGES[@]}"; do
    if ! printf '%s\n' "${INSTALL_PACKAGES[@]}" | grep -qx -- "$package"; then
        echo "Third-party package '$package' is missing from the installer's PACSTRAP_PACKAGES." >&2
        exit 1
    fi
done

# Packages that are built from the AUR and indexed locally, whether they are
# requested by the installer or only needed as a dependency.
AUR_PACKAGES=("${THIRD_PARTY_PACKAGES[@]}" "${AUR_DEPENDENCY_PACKAGES[@]}")

offline_package_exists() {
    local expected_package=$1 archive actual_package
    local -a archives=()

    # Use compgen instead of toggling nullglob so the caller's shell options
    # are left untouched.
    while IFS= read -r archive; do
        archives+=("$archive")
    done < <(compgen -G "$CACHE_DIR/$expected_package-*.pkg.tar.zst" || true)

    for archive in "${archives[@]}"; do
        [[ -f "$archive" ]] || continue
        actual_package=$(pacman -Qp -- "$archive" 2>/dev/null | awk '{ print $1 }') || continue
        if [[ "$actual_package" == "$expected_package" ]]; then
            return 0
        fi
    done
    return 1
}

# Some AUR sources do not build from scratch on the current toolchain
# (notably gtk2 with gobject-introspection). Prefer the last prebuilt binary
# already published in anarchy-repo git history when available.
restore_prebuilt_from_history() {
    local pkg=$1 repo_dir="$GIT_ROOT/anarchy-repo"
    local commit filename

    [[ -d "$repo_dir/.git" ]] || return 1
    commit=$(git -C "$repo_dir" log --all --format=%H --diff-filter=A -- "x86_64/$pkg-*.pkg.tar.zst" 2>/dev/null | head -n1)
    [[ -n "$commit" ]] || return 1
    filename=$(git -C "$repo_dir" ls-tree --name-only "$commit:x86_64" 2>/dev/null \
        | grep -E "^${pkg}-" | grep -v -- "-debug-" | head -n1) || return 1
    [[ -n "$filename" ]] || return 1
    git -C "$repo_dir" show "$commit:x86_64/$filename" > "$CACHE_DIR/$filename" || return 1
    echo "✓ Restored prebuilt $filename from anarchy-repo history (${commit:0:7})"
    return 0
}

aur_package_base() {
    local pkg=$1 base=''
    if command -v curl >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
        base=$(curl -fsSL --max-time 15 "https://aur.archlinux.org/rpc/v5/info/$pkg" 2>/dev/null \
            | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["results"][0]["PackageBase"] if d["results"] else "")' 2>/dev/null || true)
    fi
    printf '%s' "${base:-$pkg}"
}

install_package_makedepends() {
    local pkgdir=$1 raw cleaned
    local -a makedeps=() to_install=()

    mapfile -t makedeps < <(cd "$pkgdir" && bash -c '
source ./PKGBUILD 2>/dev/null
printf "%s\n" "${makedepends[@]}" "${makedepends_x86_64[@]}" "${makedepends_aarch64[@]}"
' 2>/dev/null | sed '/^\s*$/d')

    (( ${#makedeps[@]} > 0 )) || return 0
    for raw in "${makedeps[@]}"; do
        cleaned=$(printf '%s' "$raw" | sed -E 's/[<>].*//; s/:.*//' | tr -d '[:space:]')
        [[ -n "$cleaned" ]] || continue
        to_install+=("$cleaned")
    done
    (( ${#to_install[@]} > 0 )) || return 0

    echo "Installing makedepends for $(basename -- "$pkgdir"): ${to_install[*]}"
    sudo pacman --config "$BUILD_CONF" -S --needed --noconfirm "${to_install[@]}" || {
        echo "Warning: some makedepends could not be installed for $(basename -- "$pkgdir"); continuing with --nodeps." >&2
    }
}

# --- 1. Make sure every third-party package archive exists in the cache ---
mkdir -p "$CACHE_DIR"

missing_third_party=()
for package in "${AUR_PACKAGES[@]}"; do
    if offline_package_exists "$package"; then
        echo "✓ $package already cached"
    else
        missing_third_party+=("$package")
    fi
done

if (( ${#missing_third_party[@]} > 0 )); then
    to_build=()
    for package in "${missing_third_party[@]}"; do
        restore_prebuilt_from_history "$package" && continue
        to_build+=("$package")
    done
    missing_third_party=("${to_build[@]+"${to_build[@]}"}")
fi

# Official-only config for installing build tools/makedepends on the host.
{
    awk '/^\[/ { keep = ($0 == "[options]") } keep { print }' "$SOURCE_PACMAN_CONF"
    awk '/^\[/ { keep = ($0 == "[core]" || $0 == "[extra]" || $0 == "[multilib]") } keep { print }' "$SOURCE_PACMAN_CONF"
} > "$BUILD_CONF"
if ! grep -q '^\[core\]$' "$BUILD_CONF" || ! grep -q '^\[extra\]$' "$BUILD_CONF"; then
    echo "The selected Pacman config must contain [core] and [extra]: $SOURCE_PACMAN_CONF" >&2
    exit 1
fi

if (( ${#missing_third_party[@]} > 0 )); then
    if (( EUID == 0 )); then
        echo "Missing AUR packages must be built as a regular user, not root." >&2
        exit 1
    fi
    command -v makepkg >/dev/null 2>&1 || {
        echo "makepkg is required to build missing AUR packages: ${missing_third_party[*]}" >&2
        exit 1
    }
    command -v git >/dev/null 2>&1 || {
        echo "git is required to fetch missing AUR packages." >&2
        exit 1
    }

    sudo pacman --config "$BUILD_CONF" -S --needed --noconfirm \
        base-devel git cmake meson ninja autoconf-archive go rust python \
        python-wheel python-hatchling python-build python-installer \
        python-setuptools python-markdown-it-py python-cairo \
        vulkan-headers spirv-tools cli11 wayland-protocols >/dev/null || {
            echo "Warning: could not install build tools; makepkg may fail." >&2
        }

    AUR_BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/anarchy-offline-aur.XXXXXX")
    for package in "${missing_third_party[@]}"; do
        package_dir="$AUR_BUILD_DIR/$package"
        base_package=$(aur_package_base "$package")
        echo "Building $package from the AUR (base: $base_package)..."
        git clone --depth 1 "https://aur.archlinux.org/$base_package.git" "$package_dir" || {
            echo "Could not clone the AUR repository for $package (base $base_package)." >&2
            exit 1
        }
        if [[ ! -f "$package_dir/PKGBUILD" ]]; then
            echo "No PKGBUILD found for $package (base $base_package); AUR repo may be empty." >&2
            exit 1
        fi
        install_package_makedepends "$package_dir"
        (cd "$package_dir" && makepkg --cleanbuild --nodeps --noconfirm) || {
            echo "makepkg failed while building $package." >&2
            exit 1
        }
        shopt -s nullglob
        archives=("$package_dir"/"$package"-*.pkg.tar.zst)
        if (( ${#archives[@]} == 0 )); then
            # Split packages (e.g. font-awesome-5 -> ttf-font-awesome-5)
            archives=("$package_dir"/*.pkg.tar.zst)
        fi
        shopt -u nullglob
        # Debug packages are never installed and only bloat the ISO.
        non_debug=()
        for archive in "${archives[@]}"; do
            [[ "$(basename -- "$archive")" == *-debug-* ]] && continue
            non_debug+=("$archive")
        done
        archives=("${non_debug[@]+"${non_debug[@]}"}")
        if (( ${#archives[@]} == 0 )); then
            echo "No package archive was produced for $package." >&2
            exit 1
        fi
        cp -f -- "${archives[@]}" "$CACHE_DIR/"
        echo "✓ Added ${#archives[@]} $package archive(s) to the offline repo"
    done
else
    echo "✓ All third-party packages are already cached"
fi

# --- 2. Index the local packages so one transaction can resolve everything ---
indexed=0
shopt -s nullglob

# Anarchy packages (anarchy-installer, anarchy-welcome, ...).
for archive in "$PACKAGE_REPO"/*.pkg.tar.zst; do
    ln -sf -- "$archive" "$REPO_INDEX_DIR/$(basename -- "$archive")"
    indexed=$((indexed + 1))
done

# Cached third-party packages, so their dependencies resolve locally.
index_cached_packages() {
    local package archive
    shopt -s nullglob
    for package in "$@"; do
        for archive in "$CACHE_DIR/$package"-*.pkg.tar.zst; do
            ln -sf -- "$archive" "$REPO_INDEX_DIR/$(basename -- "$archive")"
            indexed=$((indexed + 1))
        done
    done
    shopt -u nullglob
}
index_cached_packages "${AUR_PACKAGES[@]}"

# AUR helpers (built by iso_build.sh) when they are already cached.
helper_packages_present=()
for package in "${AUR_HELPER_PACKAGES[@]}"; do
    if offline_package_exists "$package"; then
        helper_packages_present+=("$package")
    fi
done
if (( ${#helper_packages_present[@]} > 0 )); then
    index_cached_packages "${helper_packages_present[@]}"
fi
if (( ${#helper_packages_present[@]} < ${#AUR_HELPER_PACKAGES[@]} )); then
    echo "Warning: not all AUR helpers are cached yet (${helper_packages_present[*]:-none}); their dependencies are completed when iso_build.sh builds them first." >&2
fi
shopt -u nullglob

if (( indexed == 0 )); then
    echo "No local packages available to index." >&2
    exit 1
fi

(
    cd "$REPO_INDEX_DIR"
    repo-add -q offline_local.db.tar.zst ./*.pkg.tar.zst
    mv -f offline_local.db.tar.zst offline_local.db
    mv -f offline_local.files.tar.zst offline_local.files
)

# --- 3. Resolve and download the full closure in one transaction ---
# The local repository comes first so the pinned third-party builds win over
# any same-named package that may have moved into the official repos.
{
    awk '/^\[/ { keep = ($0 == "[options]") } keep { print }' "$SOURCE_PACMAN_CONF"
    printf '\n[offline_local]\nSigLevel = Optional TrustAll\nServer = file://%s\n' "$REPO_INDEX_DIR"
    awk '/^\[/ { keep = ($0 == "[core]" || $0 == "[extra]" || $0 == "[multilib]") } keep { print }' "$SOURCE_PACMAN_CONF"
} > "$RESOLVE_CONF"
if ! grep -q '^\[core\]$' "$RESOLVE_CONF" || ! grep -q '^\[extra\]$' "$RESOLVE_CONF"; then
    echo "The selected Pacman config must contain [core] and [extra]: $SOURCE_PACMAN_CONF" >&2
    exit 1
fi

echo "Resolving and downloading packages with full dependency closure..."
sudo pacman --config "$RESOLVE_CONF" -Syyw --noconfirm \
    --dbpath "$DB_DIR" --cachedir "$CACHE_DIR" \
    "${INSTALL_PACKAGES[@]}" \
    "${helper_packages_present[@]+"${helper_packages_present[@]}"}" \
    "${OPTIONAL_PACKAGES[@]}" \
    "$INSTALLER_PACKAGE"

# --- 4. Ship the synced official databases with the offline repository ---
# The installed system needs them on first boot, otherwise every pacman
# command warns that the 'core', 'extra' and 'multilib' database files do not
# exist (mkarchiso strips sync databases from the live image).
for sync_db in core extra multilib; do
    if [[ -f "$DB_DIR/sync/$sync_db.db" ]]; then
        sudo cp -f -- "$DB_DIR/sync/$sync_db.db" "$CACHE_DIR/"
        echo "Packaged sync database: $sync_db.db"
    else
        echo "Warning: $sync_db.db was not synced; run 'pacman -Sy' on the installed system after first boot." >&2
    fi
done

shopt -s nullglob
cached_archives=("$CACHE_DIR"/*.pkg.tar.zst)
shopt -u nullglob
echo "Installer package list: ${#INSTALL_PACKAGES[@]} packages (read from Anarchy-Installer-Offline)"
echo "Offline repository now holds ${#cached_archives[@]} package archive(s) in $CACHE_DIR"
