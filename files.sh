#!/usr/bin/env bash
# Copy the live-environment files that must ship inside the ISO.
#
# The sources come from the anarchydots tree. By default the copy synced by
# iso_build.sh into airootfs/opt/dotfiles is used, so the skeleton files match
# the dotfiles the installer deploys. Override with ANARCHYDOTS_DIR to test a
# local checkout.
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GIT_ROOT="$(dirname -- "$SCRIPT_DIR")"
SYNCED_DOTFILES="$SCRIPT_DIR/airootfs/opt/dotfiles"
SKEL_DIR="$SCRIPT_DIR/airootfs/etc/skel"
BIN_DIR="$SCRIPT_DIR/airootfs/usr/local/bin"

if [[ -n "${ANARCHYDOTS_DIR:-}" ]]; then
    ANARCHYDOTS="$ANARCHYDOTS_DIR"
elif [[ -d "$SYNCED_DOTFILES" ]]; then
    ANARCHYDOTS="$SYNCED_DOTFILES"
elif [[ -d "$HOME/anarchydots" ]]; then
    ANARCHYDOTS="$HOME/anarchydots"
elif [[ -d "$GIT_ROOT/anarchydots" ]]; then
    ANARCHYDOTS="$GIT_ROOT/anarchydots"
else
    echo "Could not find the anarchydots tree (set ANARCHYDOTS_DIR)." >&2
    exit 1
fi

copy_file() {
    local src=$1 dest=$2 mode=$3
    if [[ ! -f "$src" ]]; then
        echo "Missing live-environment file: $src" >&2
        return 1
    fi
    if [[ -e "$dest" ]]; then
        if [[ ! -f "$dest" ]]; then
            echo "Refusing to replace non-regular file: $dest" >&2
            return 1
        fi
        printf '  = %s (already exists, skipped)\n' "${dest#"$SCRIPT_DIR"/}"
        return 0
    fi
    install -Dm"$mode" -- "$src" "$dest"
    printf '  + %s\n' "${dest#"$SCRIPT_DIR"/}"
}

copy_dir() {
    local src=$1 dest=$2
    if [[ ! -d "$src" ]]; then
        echo "Missing live-environment directory: $src" >&2
        return 1
    fi
    if [[ -e "$dest" ]]; then
        if [[ ! -d "$dest" ]]; then
            echo "Refusing to replace non-directory: $dest" >&2
            return 1
        fi
        printf '  = %s/ (already exists, skipped)\n' "${dest#"$SCRIPT_DIR"/}"
        return 0
    fi
    mkdir -p -- "$(dirname -- "$dest")"
    cp -a -- "$src" "$dest"
    printf '  + %s/\n' "${dest#"$SCRIPT_DIR"/}"
}

# Copy the *contents* of a source directory into an existing destination,
# reusing the skip-if-exists helpers so a wallpaper that is already there is
# never overwritten.
copy_dir_contents() {
    local src=$1 dest=$2
    local entry name

    if [[ ! -d "$src" ]]; then
        echo "Missing live-environment directory: $src" >&2
        return 1
    fi
    mkdir -p -- "$dest"
    for entry in "$src"/* "$src"/.[!.]*; do
        [[ -e "$entry" || -L "$entry" ]] || continue
        name=${entry##*/}
        if [[ -d "$entry" ]]; then
            copy_dir "$entry" "$dest/$name"
        else
            copy_file "$entry" "$dest/$name" 644
        fi
    done
}

# GRUB and SDDM assets are read from system paths rather than from a home
# directory, so they cannot live in /etc/skel. Ship them in the live tree so
# the ISO carries the same themes the installer deploys to the target.
copy_system_themes() {
    local grub_theme_dir="$SCRIPT_DIR/airootfs/usr/share/grub/themes"
    local sddm_theme_dir="$SCRIPT_DIR/airootfs/usr/share/sddm/themes"
    local etc_default_dir="$SCRIPT_DIR/airootfs/etc/default"
    local sddm_wallpaper_dir="$SCRIPT_DIR/airootfs/var/local/sddm-wallpaper"
    local cursors_dir="$SCRIPT_DIR/airootfs/etc/skel/.local/share/icons"

    mkdir -p -- "$grub_theme_dir" "$sddm_theme_dir" "$etc_default_dir" "$sddm_wallpaper_dir" "$cursors_dir"

    copy_file "$ANARCHYDOTS/sys/grub/grub" "$etc_default_dir/grub" 644
    copy_dir "$ANARCHYDOTS/sys/grub/tokyo-night" "$grub_theme_dir/tokyo-night"

    copy_dir "$ANARCHYDOTS/sys/sddm/anarchy-sddm" "$sddm_theme_dir/anarchy-sddm"
    copy_file "$ANARCHYDOTS/sys/sddm/sddm.conf" "$SCRIPT_DIR/airootfs/etc/sddm.conf" 644

    # Seed the greeter background/colours so the first boot has something to
    # show before liveuser runs the theme script.
    copy_dir_contents "$ANARCHYDOTS/sys/sddm/initial-setup" "$sddm_wallpaper_dir"
}

printf 'Copying live-environment files from %s\n' "$ANARCHYDOTS"

copy_system_themes

mkdir -p -- "$SKEL_DIR/.config" "$SKEL_DIR/.local/share/themes" "$BIN_DIR"

copy_file "$ANARCHYDOTS/scripts/bin/awww.sh" "$BIN_DIR/awww.sh" 755
copy_file "$ANARCHYDOTS/zsh/.zshrc" "$SKEL_DIR/.zshrc" 644
copy_file "$ANARCHYDOTS/hypr-themes/.config/.hypr-themes/tokyo-night/tokyo-night.sh" \
    "$SKEL_DIR/.local/share/themes/hypr-theme-active.sh" 755

copy_dir "$ANARCHYDOTS/bg/.config/activebg" "$SKEL_DIR/.config/activebg"
copy_dir "$ANARCHYDOTS/gtk3/.config/gtk-3.0" "$SKEL_DIR/.config/gtk-3.0"
copy_dir "$ANARCHYDOTS/gtk4/.config/gtk-4.0" "$SKEL_DIR/.config/gtk-4.0"
copy_dir "$ANARCHYDOTS/gradience/.config/presets" "$SKEL_DIR/.config/presets"
copy_dir "$ANARCHYDOTS/fastfetch/.config/fastfetch" "$SKEL_DIR/.config/fastfetch"
copy_dir "$ANARCHYDOTS/kitty/.config/kitty" "$SKEL_DIR/.config/kitty"
copy_dir "$ANARCHYDOTS/rofi/.config/rofi" "$SKEL_DIR/.config/rofi"
copy_dir "$ANARCHYDOTS/neovim/.config/nvim" "$SKEL_DIR/.config/nvim"
copy_dir "$ANARCHYDOTS/pywal/.config/pywal" "$SKEL_DIR/.config/pywal"
copy_dir "$ANARCHYDOTS/wal/.config/wal" "$SKEL_DIR/.config/wal"
copy_dir "$ANARCHYDOTS/omz/.oh-my-zsh" "$SKEL_DIR/.oh-my-zsh"
copy_dir "$ANARCHYDOTS/themes/.themes" "$SKEL_DIR/.themes"
copy_dir "$ANARCHYDOTS/icons/.icons" "$SKEL_DIR/.icons"
copy_dir "$ANARCHYDOTS/hypr-themes/.config/.hypr-themes/tokyo-night/" "$SKEL_DIR/.config/.hypr-themes/tokyo-night"
copy_dir "$ANARCHYDOTS/cursors/.local/share/icons/bibata_tokyo_night_modern" \
    "$SKEL_DIR/.local/share/icons/bibata_tokyo_night_modern"
copy_file "$ANARCHYDOTS/hypr-themes/.config/.hypr-themes/get-themes.sh" \
    "$SKEL_DIR/.config/.hypr-themes/get-themes.sh" 755
copy_file "$ANARCHYDOTS/hypr-themes/.config/.hypr-themes/patch-look.sh" \
    "$SKEL_DIR/.config/.hypr-themes/patch-look.sh" 755
copy_file "$ANARCHYDOTS/hypr-themes/.config/.hypr-themes/run-theme.sh" \
    "$SKEL_DIR/.config/.hypr-themes/run-theme.sh" 755
copy_file "$ANARCHYDOTS/hypr-themes/.config/.hypr-themes/scan-themes.sh" \
    "$SKEL_DIR/.config/.hypr-themes/scan-themes.sh" 755
copy_file "$ANARCHYDOTS/hypr-themes/.config/.hypr-themes/set-cursor-theme.sh" \
    "$SKEL_DIR/.config/.hypr-themes/set-cursor-theme.sh" 755

