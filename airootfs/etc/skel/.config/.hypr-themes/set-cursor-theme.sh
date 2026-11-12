#!/bin/bash
# Set cursor theme in /usr/share/icons/default/index.theme
CURSOR_THEME="$1"
THEME_FILE="/usr/share/icons/default/index.theme"

if [ -z "$CURSOR_THEME" ]; then
    echo "Usage: $0 <cursor-theme-name>"
    exit 1
fi

if [ ! -f "$THEME_FILE" ]; then
    echo "[Icon Theme]" > "$THEME_FILE"
    echo "Inherits=$CURSOR_THEME" >> "$THEME_FILE"
else
    sed -i "s/^Inherits=.*/Inherits=$CURSOR_THEME/" "$THEME_FILE"
fi
