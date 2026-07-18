#!/bin/bash

WATCH_DIR="$HOME/.config/fastfetch"
WATCH_FILE="$WATCH_DIR/arch.png"

if ! command -v inotifywait &>/dev/null; then
    echo "Error: inotify-tools is required. Install it with:"
    echo "  pacman -S inotify-tools    # Arch"
    echo "  apt install inotify-tools  # Debian/Ubuntu"
    echo "  dnf install inotify-tools  # Fedora"
    exit 1
fi

clear
fastfetch

echo ""
echo "Watching $WATCH_FILE for changes..."

while inotifywait -qq -e close_write "$WATCH_FILE" 2>/dev/null; do
    clear
    fastfetch
    echo ""
    echo "Watching $WATCH_FILE for changes..."
done
