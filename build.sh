#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/work"
OUT_DIR="${SCRIPT_DIR}/out"
LOCAL_REPO="${SCRIPT_DIR}/airootfs/var/local/anarchy-repo"

REQUIRED_PACKAGES=(
    adw-gtk-theme-git anarchy-installer anarchy-welcome arch-update awww
    blueman broadcom-wl-dkms bluez bluez-utils coolercontrol coolercontrold
    eza goverlay-git gradience-git grim-git hypridle hyprlock hyprmon-bin
    hyprpicker hyprscratch inter-font kitty kvantum-qt6-git mesa-utils
    nautilus nautilus-admin-gtk4 nautilus-open-any-terminal-git neovim
    nwg-displays nwg-look oh-my-zsh-git otf-font-awesome-5 plymouth
    pyprland python-anyascii python-cssutils python-gobject python-libsass
    python-material-color-utilities python-pywal16 python-pywalfox
    python-yapsy-git qt5-graphicaleffects qt5-imageformats qt5-multimedia
    qt5-quickcontrols qt5-quickcontrols2 qt5-styleplugins qt5-svg
    qt6-5compat qt6-base qt6-declarative qt6-imageformats qt6-multimedia
    qt6-svg rofi slurp-git swaync ttf-font-awesome-4 ttf-font-awesome-5
    ttf-jetbrains-mono-nerd vencord-bin vesktop-bin vkbasalt vlc
    vlc-plugins-all wf-recorder-git wlsunset xdg-terminal-exec xfce-polkit
    zsh-autocomplete zsh-autosuggestions zsh-autoswitch-virtualenv-git
    zsh-fast-syntax-highlighting zsh-syntax-highlighting
)

echo "==> Setting up local anarchy-repo for offline install..."
mkdir -p "$LOCAL_REPO"

MISSING=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! ls "$LOCAL_REPO"/${pkg}-*.pkg.tar.zst &>/dev/null; then
        MISSING+=("$pkg")
    fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
    echo "  All ${#REQUIRED_PACKAGES[@]} packages present in $LOCAL_REPO"
else
    echo "  Missing ${#MISSING[@]} packages: ${MISSING[*]}"
    echo "  Cloning anarchy-repo to fetch missing packages..."
    git clone --depth 1 https://github.com/Riezz0/anarchy-repo.git /tmp/anarchy-repo-clone
    for pkg in "${MISSING[@]}"; do
        pkg_file=$(ls /tmp/anarchy-repo-clone/x86_64/${pkg}-*.pkg.tar.zst 2>/dev/null | head -1)
        if [ -n "$pkg_file" ]; then
            echo "    Copying $(basename "$pkg_file")"
            cp "$pkg_file" "$LOCAL_REPO/"
        else
            echo "    WARNING: ${pkg} not found in anarchy-repo, skipping..."
        fi
    done
    rm -rf /tmp/anarchy-repo-clone
fi

echo "  Building repo database..."
cd "$LOCAL_REPO"
repo-add anarchy-repo.db.tar.zst *.pkg.tar.zst
mv anarchy-repo.db.tar.zst anarchy-repo.db
mv anarchy-repo.files.tar.zst anarchy-repo.files 2>/dev/null || true
cd "$SCRIPT_DIR"

echo "==> Cleaning previous build artifacts..."
sudo rm -rf "${WORK_DIR}"

echo "==> Building ISO..."
sudo mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${SCRIPT_DIR}"

echo "==> Cleaning up..."
sudo rm -rf "${WORK_DIR}"
sudo rm -rf "$LOCAL_REPO"

echo "==> Build complete. Output in ${OUT_DIR}/"
