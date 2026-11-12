#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GIT_ROOT="$(dirname -- "$SCRIPT_DIR")"
OUT_DIR="$SCRIPT_DIR/out"
WORK_DIR="${WORK_DIR:-$SCRIPT_DIR/work}"
# Old default location; still cleaned up so disk/tmpfs space is reclaimed.
LEGACY_WORK_DIR=/tmp/archiso-work
if [[ -z "$WORK_DIR" || "$WORK_DIR" == / ]]; then
    printf 'Refusing to use an unsafe WORK_DIR: %q\n' "$WORK_DIR" >&2
    exit 1
fi
OFFLINE_REPO="$SCRIPT_DIR/airootfs/opt/arch-offline-repo"
OPT_DIR="$SCRIPT_DIR/airootfs/opt"
PACKAGE_REPO="$GIT_ROOT/anarchy-repo/x86_64"
DOTFILES_DIR="$SCRIPT_DIR/airootfs/opt/dotfiles"
DOTFILES_REMOTE=https://github.com/Riezz0/anarchydots.git
DOTFILES_COMMIT_FILE="$SCRIPT_DIR/.dotfiles-commit"
DOTFILES_STAGING=''
AUR_BUILD_DIR=''
BUILD_PACMAN_CONF=''
OFFLINE_CHECK_DB=''
OFFLINE_CHECK_CONF=''
TOTAL_STEPS=13
completed_steps=0

# Colours come from the current pywal palette so the build UI matches the
# desktop. The static values below are only a fallback for hosts without
# pywal, or before `wal` has ever been run.
FG='#c0caf5'; BLUE='#7aa2f7'; GREEN='#9ece6a'
YELLOW='#e0af68'; RED='#f7768e'; PURPLE='#bb9af7'
BG='#1a1b26'

WAL_DIR="${WAL_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/wal}"

load_pywal_colors() {
    local -A wal=()
    local line key value index=0
    local colors_file="${WAL_COLORS:-$WAL_DIR/colors.sh}"

    if [[ -r "$colors_file" ]]; then
        while IFS= read -r line; do
            [[ "$line" == *=* ]] || continue
            key=${line%%=*}
            value=${line#*=}
            value=${value%\'}; value=${value#\'}
            value=${value%\"}; value=${value#\"}
            [[ "$key" =~ ^[A-Za-z][A-Za-z0-9_]*$ ]] || continue
            [[ "$value" =~ ^#[0-9A-Fa-f]{3,8}$ ]] || continue
            wal[$key]=$value
        done < "$colors_file"
    elif [[ -r "$WAL_DIR/colors" ]]; then
        # Plain pywal list: one hex colour per line, colour0 .. colour15.
        while IFS= read -r value; do
            if (( index > 15 )); then
                break
            fi
            if [[ ! "$value" =~ ^#?[0-9A-Fa-f]{6}$ ]]; then
                index=$((index + 1))
                continue
            fi
            [[ "$value" == \#* ]] || value="#$value"
            wal["color$index"]=$value
            index=$((index + 1))
        done < "$WAL_DIR/colors"
    else
        return 1
    fi

    FG=${wal[foreground]:-${wal[color7]:-$FG}}
    BLUE=${wal[color4]:-$BLUE}
    GREEN=${wal[color2]:-$GREEN}
    YELLOW=${wal[color3]:-$YELLOW}
    RED=${wal[color1]:-$RED}
    PURPLE=${wal[color5]:-$PURPLE}
    BG=${wal[background]:-$BG}
    return 0
}
load_pywal_colors || true

banner() {
    gum style --foreground "$PURPLE" --border double --border-foreground "$BLUE" \
        --padding '0 2' --bold 'Anarchy Hyprland ISO Builder'
}

ok() { gum style --foreground "$GREEN" "✓ $*"; }
fail() { gum style --foreground "$RED" --bold "✖ $*" >&2; }

run_step() {
    local title=$1
    shift
    local show_output=false
    if [[ ${1:-} == --show-output ]]; then
        show_output=true
        shift
    fi

    # gum spin execs its command, so shell functions only work when invoked
    # directly (--show-output).
    if [[ "$show_output" != true && $(type -t "${1:-}") == function ]]; then
        fail "Internal error: shell function '${1}' must be run with --show-output."
        exit 1
    fi

    if [[ "$show_output" == true ]]; then
        gum style --foreground "$FG" "▶ $title"
        if ! "$@"; then
            fail "$title failed. See the error output above."
            exit 1
        fi
    elif ! gum spin --spinner dot --show-error \
        --spinner.foreground "$BLUE" --title.foreground "$FG" \
        --title "$title" -- "$@"; then
        fail "$title failed. See the error output above."
        exit 1
    fi

    completed_steps=$((completed_steps + 1))
    progress_meter "$completed_steps" "$TOTAL_STEPS"
    ok "$title"
}

cleanup() {
    if [[ -n "$DOTFILES_STAGING" && -d "$DOTFILES_STAGING" ]]; then
        if [[ -d "$DOTFILES_STAGING/old-dotfiles" && ! -e "$DOTFILES_DIR" ]]; then
            mv -- "$DOTFILES_STAGING/old-dotfiles" "$DOTFILES_DIR" || true
        fi
        rm -rf -- "$DOTFILES_STAGING"
    fi
    [[ -z "$AUR_BUILD_DIR" ]] || rm -rf -- "$AUR_BUILD_DIR"
    [[ -z "$BUILD_PACMAN_CONF" ]] || rm -f -- "$BUILD_PACMAN_CONF"
    [[ -z "$OFFLINE_CHECK_CONF" ]] || rm -f -- "$OFFLINE_CHECK_CONF"
    [[ -z "$OFFLINE_CHECK_DB" ]] || sudo rm -rf -- "$OFFLINE_CHECK_DB" || true
}
trap cleanup EXIT

sync_dotfiles() {
    local remote_commit cached_commit='' clone_commit latest_commit first_entry=''
    local dotfiles_parent

    if ! remote_commit=$(git ls-remote "$DOTFILES_REMOTE" HEAD | awk 'NR == 1 { print $1 }'); then
        fail 'Could not check the latest anarchydots commit on GitHub.'
        exit 1
    fi
    if [[ ! "$remote_commit" =~ ^[[:xdigit:]]{40,64}$ ]]; then
        fail 'GitHub did not return a valid anarchydots commit.'
        exit 1
    fi

    if [[ -f "$DOTFILES_COMMIT_FILE" ]]; then
        IFS= read -r cached_commit < "$DOTFILES_COMMIT_FILE" || true
    fi
    if [[ -d "$DOTFILES_DIR" ]]; then
        first_entry=$(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -print -quit)
    fi
    if [[ "$cached_commit" == "$remote_commit" && -n "$first_entry" ]]; then
        printf 'Dotfiles already match GitHub (%s).\n' "${remote_commit:0:12}"
        return
    fi

    if [[ -e "$DOTFILES_DIR" && ! -d "$DOTFILES_DIR" || -L "$DOTFILES_DIR" ]]; then
        fail "Expected a regular directory at $DOTFILES_DIR; refusing to replace it."
        exit 1
    fi

    dotfiles_parent=$(dirname -- "$DOTFILES_DIR")
    DOTFILES_STAGING=$(mktemp -d "$dotfiles_parent/.dotfiles-sync.XXXXXX")
    printf 'Downloading anarchydots from GitHub (%s)...\n' "${remote_commit:0:12}"
    if ! git clone --depth 1 --single-branch "$DOTFILES_REMOTE" "$DOTFILES_STAGING/repo"; then
        fail 'Could not download anarchydots from GitHub; existing dotfiles were left untouched.'
        exit 1
    fi

    clone_commit=$(git -C "$DOTFILES_STAGING/repo" rev-parse HEAD)
    latest_commit=$(git ls-remote "$DOTFILES_REMOTE" HEAD | awk 'NR == 1 { print $1 }') || {
        fail 'Could not re-check the latest anarchydots commit; existing dotfiles were left untouched.'
        exit 1
    }
    if [[ "$clone_commit" != "$remote_commit" || "$latest_commit" != "$clone_commit" ]]; then
        fail 'anarchydots changed while downloading; rerun the ISO build to sync the newest commit.'
        exit 1
    fi

    mkdir -p "$DOTFILES_STAGING/tree"
    if ! git -C "$DOTFILES_STAGING/repo" checkout-index --all \
        --prefix="$DOTFILES_STAGING/tree/"; then
        fail 'Could not prepare the downloaded dotfiles; existing dotfiles were left untouched.'
        exit 1
    fi
    printf '%s\n' "$clone_commit" > "$DOTFILES_STAGING/commit"

    if [[ -d "$DOTFILES_DIR" ]]; then
        if ! mv -- "$DOTFILES_DIR" "$DOTFILES_STAGING/old-dotfiles"; then
            fail 'Could not stage the existing dotfiles for replacement.'
            exit 1
        fi
    fi
    if ! mv -- "$DOTFILES_STAGING/tree" "$DOTFILES_DIR"; then
        [[ ! -d "$DOTFILES_STAGING/old-dotfiles" ]] || \
            mv -- "$DOTFILES_STAGING/old-dotfiles" "$DOTFILES_DIR" || true
        fail 'Could not install the downloaded dotfiles; attempted to restore the previous directory.'
        exit 1
    fi
    if ! mv -f -- "$DOTFILES_STAGING/commit" "$DOTFILES_COMMIT_FILE"; then
        fail 'Dotfiles were updated, but could not save the synced commit marker.'
        exit 1
    fi

    printf 'Updated dotfiles to GitHub commit %s.\n' "$clone_commit"
}

offline_package_exists() {
    local expected_package=$1 archive actual_package

    for archive in "$OFFLINE_REPO/$expected_package"-*.pkg.tar.zst; do
        [[ -f "$archive" ]] || continue
        actual_package=$(pacman -Qp -- "$archive" 2>/dev/null | awk '{ print $1 }') || continue
        if [[ "$actual_package" == "$expected_package" ]]; then
            return 0
        fi
    done
    return 1
}

build_aur_helpers() {
    local package package_dir
    local -a archives missing_helpers=()
    local -a build_dependencies=(
        base-devel git go rust python
        python-wheel python-hatchling python-build python-installer
        python-setuptools python-markdown-it-py
    )

    for package in yay paru pikaur-git; do
        if offline_package_exists "$package"; then
            ok "$package already exists in the offline repo; skipping its build"
        else
            missing_helpers+=("$package")
        fi
    done
    if (( ${#missing_helpers[@]} == 0 )); then
        ok 'All selected AUR helper packages are already available offline'
        return 0
    fi

    if (( EUID == 0 )); then
        fail 'AUR helper packages must be built as a regular user, not root.'
        return 1
    fi
    command -v makepkg >/dev/null 2>&1 || {
        fail 'makepkg is required to build the AUR helpers.'
        return 1
    }

    AUR_BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/anarchy-aur-helpers.XXXXXX")
    BUILD_PACMAN_CONF=$(mktemp "${TMPDIR:-/tmp}/anarchy-build-pacman.XXXXXX.conf")
    # Keep build-tool installation on official Arch repositories only. In
    # particular, do not import keys from unrelated host repositories.
    awk '/^\[/ { skip = ($0 == "[offline_repo]") } !skip { print }' \
        "$SCRIPT_DIR/pacman.conf" > "$BUILD_PACMAN_CONF"
    if ! grep -q '^\[core\]$' "$BUILD_PACMAN_CONF" || \
       ! grep -q '^\[extra\]$' "$BUILD_PACMAN_CONF"; then
        fail 'Build pacman config must contain the official [core] and [extra] repositories.'
        return 1
    fi

    # These are build-only tools. Runtime dependencies (notably pyalpm) are
    # cached separately by cache-offline-repo.sh for the offline target system.
    if ! sudo pacman --config "$BUILD_PACMAN_CONF" -S --needed --noconfirm \
        "${build_dependencies[@]}"; then
        fail 'Could not install the official build dependencies for yay, paru, and pikaur-git.'
        return 1
    fi

    for package in "${missing_helpers[@]}"; do
        package_dir="$AUR_BUILD_DIR/$package"
        printf '\nBuilding %s from the AUR...\n' "$package"
        if ! git clone --depth 1 "https://aur.archlinux.org/$package.git" "$package_dir"; then
            fail "Could not clone the AUR repository for $package."
            return 1
        fi
        if ! (cd "$package_dir" && makepkg --cleanbuild --nodeps --noconfirm); then
            fail "makepkg failed while building $package."
            return 1
        fi

        shopt -s nullglob
        archives=("$package_dir"/"$package"-*.pkg.tar.zst)
        shopt -u nullglob
        if (( ${#archives[@]} == 0 )); then
            fail "No package archive was produced for $package."
            return 1
        fi
        cp -f -- "${archives[@]}" "$OFFLINE_REPO/"
        ok "Added ${#archives[@]} $package archive(s) to the offline repository"
    done
}

verify_offline_helpers() {
    OFFLINE_CHECK_DB=$(mktemp -d "${TMPDIR:-/tmp}/anarchy-offline-check.XXXXXX")
    OFFLINE_CHECK_CONF=$(mktemp "${TMPDIR:-/tmp}/anarchy-offline-check.XXXXXX.conf")
    cat > "$OFFLINE_CHECK_CONF" <<EOF
[options]
Architecture = auto
SigLevel = Optional TrustAll

[offline_repo]
SigLevel = Optional TrustAll
Server = file://$OFFLINE_REPO
EOF

    if ! sudo pacman --config "$OFFLINE_CHECK_CONF" --dbpath "$OFFLINE_CHECK_DB" \
        -Sy --noconfirm; then
        fail 'Could not read the freshly built offline repository index.'
        return 1
    fi
    if ! sudo pacman --config "$OFFLINE_CHECK_CONF" --dbpath "$OFFLINE_CHECK_DB" \
        -Sp --noconfirm yay paru pikaur-git anarchy-installer; then
        fail 'The offline repo is missing a helper/installer package or one of its runtime dependencies.'
        return 1
    fi
}

# Copied or synced trees can lose the executable bit (for example when a
# dotfile is tracked without it). Make sure every shell script that ships in
# the ISO can actually be run.
ensure_scripts_executable() {
    local root="$SCRIPT_DIR/airootfs"
    local script count=0
    local -a scripts=()

    [[ -d "$root" ]] || {
        printf 'Missing airootfs directory: %s\n' "$root" >&2
        return 1
    }

    mapfile -d '' -t scripts < <(find "$root" -type f -name '*.sh' -print0)
    for script in "${scripts[@]}"; do
        [[ -x "$script" ]] && continue
        sudo chmod +x -- "$script"
        printf '  + %s\n' "${script#"$SCRIPT_DIR"/}"
        count=$((count + 1))
    done
    printf 'Ensured %d of %d shell script(s) are executable under %s\n' \
        "$count" "${#scripts[@]}" "${root#"$SCRIPT_DIR"/}"
}

# mkarchiso runs airootfs/root/customize_airootfs.sh inside the chroot after
# pacstrap. That is the only point where the sddm group and package-provided
# paths such as /usr/share/icons/default and /var/local/sddm-wallpaper exist,
# so ownership can be handed to liveuser there. Fail early if the hook went
# missing so the build cannot silently produce an ISO whose live session
# cannot write its theme files.
verify_live_permissions_hook() {
    local hook="$SCRIPT_DIR/airootfs/root/customize_airootfs.sh"

    if [[ ! -f "$hook" ]]; then
        printf 'Missing chroot hook: %s\n' "$hook" >&2
        return 1
    fi
    if [[ ! -x "$hook" ]]; then
        sudo chmod +x -- "$hook"
    fi
    printf 'Chroot hook ready: %s\n' "${hook#"$SCRIPT_DIR"/}"
}

clean_work_dirs() {
    local dir
    for dir in "$WORK_DIR" "$LEGACY_WORK_DIR"; do
        [[ -n "$dir" && "$dir" != / ]] || continue
        sudo rm -rf -- "$dir"
    done
}

disk_available_bytes() {
    df --output=avail -B1 -- "$1" 2>/dev/null | tail -n 1 | tr -d '[:space:]'
}

ensure_disk_space() {
    local repo_bytes needed work_free out_free work_dev out_dev work_base out_base

    repo_bytes=$(du -sb -- "$OFFLINE_REPO" | awk '{ print $1 }')
    [[ -n "$repo_bytes" ]] || repo_bytes=0
    # SquashFS plus the ISO copy, with a safety margin. The uncompressed
    # repository size is an upper bound for the compressed image.
    needed=$(( repo_bytes + repo_bytes / 5 + 512 * 1024 * 1024 ))

    work_base=$(dirname -- "$WORK_DIR")
    out_base=$(dirname -- "$OUT_DIR")
    work_free=$(disk_available_bytes "$work_base")
    out_free=$(disk_available_bytes "$out_base")
    work_dev=$(stat -c %d -- "$work_base")
    out_dev=$(stat -c %d -- "$out_base")
    if [[ -z "$work_free" || -z "$out_free" ]]; then
        fail "Could not determine free disk space for $work_base / $out_base."
        return 1
    fi

    if [[ "$work_dev" == "$out_dev" ]]; then
        if (( work_free < needed * 2 )); then
            fail "Not enough free space on $work_base: need ~$(( needed * 2 / 1048576 )) MiB, have $(( work_free / 1048576 )) MiB."
            return 1
        fi
    else
        if (( work_free < needed )); then
            fail "Not enough free space on $work_base: need ~$(( needed / 1048576 )) MiB, have $(( work_free / 1048576 )) MiB."
            return 1
        fi
        if (( out_free < needed )); then
            fail "Not enough free space on $out_base: need ~$(( needed / 1048576 )) MiB, have $(( out_free / 1048576 )) MiB."
            return 1
        fi
    fi
}

# mkarchiso runs pacstrap with -c, which reuses the host package cache
# (/var/cache/pacman/pkg) by filename. A stale file that happens to share a
# name with an offline-repo package (for example the same version built by a
# different repository such as chaotic-aur) is picked up instead of the
# offline copy and then fails pacman's checksum verification. Only entries
# whose content differs from the offline archive are removed; identical cached
# copies stay so repeat builds keep their speed.
purge_stale_pkg_cache() {
    local host_cache=/var/cache/pacman/pkg
    local archive name checked=0 removed=0
    local -a stale=()

    [[ -d "$host_cache" ]] || {
        printf 'Host package cache not found at %s; nothing to purge.\n' "$host_cache"
        return 0
    }

    shopt -s nullglob
    for archive in "$OFFLINE_REPO"/*.pkg.tar.zst; do
        name=$(basename -- "$archive")
        [[ -e "$host_cache/$name" ]] || continue
        checked=$((checked + 1))
        if ! cmp -s -- "$host_cache/$name" "$archive"; then
            stale+=("$name")
        fi
    done
    shopt -u nullglob

    if (( ${#stale[@]} == 0 )); then
        printf 'Host package cache matches the offline repository (%d package(s) checked).\n' "$checked"
        return 0
    fi

    for name in "${stale[@]}"; do
        sudo rm -f -- "$host_cache/$name" "$host_cache/$name.sig"
        printf '  - %s\n' "$name"
        removed=$((removed + 1))
    done
    printf 'Removed %d stale host cache package(s) that shadowed offline repo packages (%d checked).\n' \
        "$removed" "$checked"
}

build_iso() {
    ensure_disk_space || return 1
    sudo mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$SCRIPT_DIR"
}

progress_meter() {
    local completed=$1 total=$2 width=24 filled percent bar='' i
    filled=$((completed * width / total))
    percent=$((completed * 100 / total))
    for ((i = 0; i < width; i++)); do
        if (( i < filled )); then
            bar+='#'
        else
            bar+='-'
        fi
    done
    printf 'Progress [%s] %d/%d (%d%%)\n' \
        "$bar" "$completed" "$total" "$percent"
}

for command in gum sudo mkarchiso pacman repo-add git makepkg; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Missing required command: %s\n' "$command" >&2
        exit 1
    fi
done
if (( EUID == 0 )); then
    printf 'Run iso_build.sh as a regular user; it invokes sudo only for privileged steps.\n' >&2
    exit 1
fi

[[ -f "$SCRIPT_DIR/profiledef.sh" ]] || { fail "Not an Archiso profile: $SCRIPT_DIR"; exit 1; }
[[ -f "$SCRIPT_DIR/packages.x86_64" ]] || { fail "Missing packages.x86_64 in $SCRIPT_DIR"; exit 1; }
[[ -d "$PACKAGE_REPO" ]] || { fail "Anarchy package repository not found: $PACKAGE_REPO"; exit 1; }

banner
gum style --foreground "$FG" \
    "Profile: $SCRIPT_DIR" \
    "Output:  $OUT_DIR" \
    "Work:    $WORK_DIR"

if ! gum confirm --default=false --affirmative 'Build ISO' --negative 'Cancel' \
    --prompt.foreground "$BLUE" \
    --selected.background "$BLUE" --selected.foreground "$BG" \
    --unselected.foreground "$FG" \
    'This clears previous build output, downloads and runs the yay/paru/pikaur-git AUR PKGBUILDs, and may install build tools on this machine. Continue?'; then
    gum style --foreground "$YELLOW" 'Build cancelled; existing output was left untouched.'
    exit 0
fi

if ! mkdir -p "$OFFLINE_REPO" "$DOTFILES_DIR"; then
    fail 'Could not create the offline repository and dotfiles directories.'
    exit 1
fi

if ! sudo -v; then
    fail 'Could not authenticate with sudo.'
    exit 1
fi

progress_meter 0 "$TOTAL_STEPS"
sync_dotfiles
completed_steps=$((completed_steps + 1))
progress_meter "$completed_steps" "$TOTAL_STEPS"
ok 'Dotfiles synchronized'

mkdir -p "$OUT_DIR"
run_step 'Cleaning previous ISO output' sudo find "$OUT_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
run_step 'Cleaning previous Archiso work directory' --show-output clean_work_dirs

run_step 'Copying live-environment files into the ISO tree' --show-output bash "$SCRIPT_DIR/files.sh"
run_step 'Making shell scripts executable' --show-output ensure_scripts_executable
run_step 'Checking the live-user permission hook' --show-output verify_live_permissions_hook
run_step 'Building AUR helpers and adding them to the offline repo' --show-output build_aur_helpers
run_step 'Caching offline packages and their dependencies' --show-output bash "$OPT_DIR/cache-offline-repo.sh"

shopt -s nullglob
installer_packages=("$PACKAGE_REPO"/anarchy-installer-*.pkg.tar.zst)
if (( ${#installer_packages[@]} == 0 )); then
    fail "No built anarchy-installer package found in $PACKAGE_REPO. Build it first."
    exit 1
fi
latest_installer=$(printf '%s\n' "${installer_packages[@]}" | sort -V | tail -n 1)
run_step "Adding $(basename -- "$latest_installer") to the offline repository" \
    cp -f -- "$latest_installer" "$OFFLINE_REPO/"

run_step 'Refreshing the offline repository index' bash "$OPT_DIR/repo_builder.sh"
run_step 'Verifying helper packages and dependencies resolve offline' --show-output verify_offline_helpers
run_step 'Purging stale host package-cache entries' --show-output purge_stale_pkg_cache
run_step 'Building the bootable ISO' --show-output build_iso

mapfile -t iso_images < <(find "$OUT_DIR" -maxdepth 1 -type f -name '*.iso' -printf '%f\n' | sort)
if (( ${#iso_images[@]} == 0 )); then
    fail "mkarchiso finished without producing an ISO in $OUT_DIR"
    exit 1
fi

ok 'ISO build complete'
printf '\n'
iso_list=$(printf '  %s\n' "${iso_images[@]}")
summary=$(printf 'Created ISO(s):\n%s' "$iso_list")
gum style --foreground "$FG" --border rounded --border-foreground "$BLUE" --padding '1 2' \
    "$summary"
