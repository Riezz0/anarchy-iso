#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/work"
OUT_DIR="${SCRIPT_DIR}/out"
LOCAL_REPO="${SCRIPT_DIR}/airootfs/var/local/anarchy-repo"
SOURCE_REPO="${ANARCHY_REPO_DIR:-/home/${USER}/git/anarchy-repo}/x86_64"

echo "==> Checking local anarchy-repo for offline install..."
mkdir -p "$LOCAL_REPO"
shopt -s nullglob
PACKAGE_FILES=("$LOCAL_REPO"/*.pkg.tar.zst)
SOURCE_PACKAGE_FILES=("$SOURCE_REPO"/*.pkg.tar.zst)
if [ ${#SOURCE_PACKAGE_FILES[@]} -gt 0 ]; then
    echo "  Refreshing ISO package cache from $SOURCE_REPO"
    rm -f "$LOCAL_REPO"/*.pkg.tar.zst
    cp "${SOURCE_PACKAGE_FILES[@]}" "$LOCAL_REPO/"
    PACKAGE_FILES=("$LOCAL_REPO"/*.pkg.tar.zst)
elif [ ${#PACKAGE_FILES[@]} -eq 0 ]; then
    echo "  Local repository is empty; downloading package archives..."
    CLONE_DIR=$(mktemp -d /tmp/anarchy-repo.XXXXXX)
    cleanup_clone() { rm -rf "$CLONE_DIR"; }
    trap cleanup_clone EXIT
    git clone --depth 1 https://github.com/Riezz0/anarchy-repo.git "$CLONE_DIR"
    cp "$CLONE_DIR"/x86_64/*.pkg.tar.zst "$LOCAL_REPO/"
    cleanup_clone
    trap - EXIT
    PACKAGE_FILES=("$LOCAL_REPO"/*.pkg.tar.zst)
fi
if [ ${#PACKAGE_FILES[@]} -eq 0 ]; then
    echo "ERROR: No package archives found in $LOCAL_REPO" >&2
    exit 1
fi
echo "  Found ${#PACKAGE_FILES[@]} local package archives"

echo "  Building repo database..."
cd "$LOCAL_REPO"
rm -f anarchy-repo.db anarchy-repo.files anarchy-repo.db.tar.zst anarchy-repo.files.tar.zst
repo-add anarchy-repo.db.tar.zst "${PACKAGE_FILES[@]}"
mv anarchy-repo.db.tar.zst anarchy-repo.db
mv anarchy-repo.files.tar.zst anarchy-repo.files 2>/dev/null || true
cd "$SCRIPT_DIR"

echo "==> Cleaning previous build artifacts..."
sudo rm -rf "${WORK_DIR}"
sudo rm -f "${OUT_DIR}"/*.iso "${OUT_DIR}"/*.sha512
echo "==> Removing stale anarchy-installer package caches..."
sudo rm -f /var/cache/pacman/pkg/anarchy-installer-*.pkg.tar.*
rm -f "${SCRIPT_DIR}"/airootfs/var/cache/pacman/pkg/anarchy-installer-*.pkg.tar.*
INSTALLER_PACKAGES=("$LOCAL_REPO"/anarchy-installer-*.pkg.tar.zst)
if [ ${#INSTALLER_PACKAGES[@]} -eq 0 ]; then
    echo "ERROR: Refreshed anarchy-installer package was not found." >&2
    exit 1
fi
sudo cp "${INSTALLER_PACKAGES[@]}" /var/cache/pacman/pkg/

echo "==> Building ISO..."
sudo mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${SCRIPT_DIR}"

echo "==> Cleaning up..."
sudo rm -rf "${WORK_DIR}"

echo "==> Build complete. Output in ${OUT_DIR}/"
