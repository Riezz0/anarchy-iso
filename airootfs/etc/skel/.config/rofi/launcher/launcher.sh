#!/usr/bin/env bash

dir="$HOME/.config/rofi/launcher/"
theme='launcher'

# Read the active icon theme from our cache file
CACHE_FILE="$HOME/.cache/current_icon_theme.txt"
if [ -f "$CACHE_FILE" ]; then
    ACTIVE_ICONS=$(cat "$CACHE_FILE")
else
    ACTIVE_ICONS="TokyoNight-Icons" # Fallback just in case
fi

## Run
rofi \
    -show drun \
    -show-icons \
    -icon-theme "$ACTIVE_ICONS" \
    -theme ${dir}/${theme}.rasi \
