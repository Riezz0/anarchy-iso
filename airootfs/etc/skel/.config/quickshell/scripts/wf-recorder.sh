#!/bin/env bash

# ── Source Hyprland environment variables ──────────────────────────────────
# QuickShell's Process doesn't inherit Wayland env vars, so we fetch them
# from the Hyprland process environment
HYPID=$(pgrep -x Hyprland)
if [ -n "$HYPID" ] && [ -f "/proc/$HYPID/environ" ]; then
    while IFS='=' read -r -d '' key value; do
        case "$key" in
            WAYLAND_DISPLAY|XDG_RUNTIME_DIR|DISPLAY|XDG_SESSION_TYPE|XDG_CURRENT_DESKTOP|HOME|PATH|USER)
                export "$key=$value"
                ;;
        esac
    done < "/proc/$HYPID/environ"
fi

# Ultra Quality Settings
FRAMERATE=60
CODEC="libx264"
PRESET="fast"
CRF=17

# Get pywal colors — prefer JSON format (same source as QuickShell Theme.qml)
WAL_JSON="$HOME/.cache/wal/colors.json"
WAL_TEXT="$HOME/.cache/wal/colors"

if [ -f "$WAL_JSON" ] && command -v jq &>/dev/null; then
    # Read from JSON format (consistent with QuickShell Theme.qml)
    COLOR_3=$(jq -r '.colors.color2 // "#b8bb26"' "$WAL_JSON" | tr -d '#')
    COLOR_2=$(jq -r '.colors.color3 // "#fabd2f"' "$WAL_JSON" | tr -d '#')
    COLOR_1=$(jq -r '.colors.color1 // "#fb4934"' "$WAL_JSON" | tr -d '#')
    COLOR_WARNING=$(jq -r '.colors.color9 // .colors.color1 // "#fb4934"' "$WAL_JSON" | tr -d '#')
    COLOR_TEXT=$(jq -r '.colors.color7 // "#ebdbb2"' "$WAL_JSON" | tr -d '#')
    COLOR_BG=$(jq -r '.special.background // "#272e33"' "$WAL_JSON" | tr -d '#')
    COLOR_FG=$(jq -r '.special.foreground // "#d8caac"' "$WAL_JSON" | tr -d '#')
elif [ -f "$WAL_TEXT" ]; then
    # Fallback to text format
    mapfile -t colors < "$WAL_TEXT"

    COLOR_3="${colors[2]:-b8bb26}"
    COLOR_2="${colors[3]:-fabd2f}"
    COLOR_1="${colors[1]:-fb4934}"
    COLOR_WARNING="${colors[9]:-${colors[1]:-fb4934}}"
    COLOR_TEXT="${colors[7]:-ebdbb2}"
    COLOR_BG="${colors[0]:-272e33}"
    COLOR_FG="${colors[15]:-d8caac}"

    COLOR_3="${COLOR_3#\#}"
    COLOR_2="${COLOR_2#\#}"
    COLOR_1="${COLOR_1#\#}"
    COLOR_WARNING="${COLOR_WARNING#\#}"
    COLOR_TEXT="${COLOR_TEXT#\#}"
    COLOR_BG="${COLOR_BG#\#}"
    COLOR_FG="${COLOR_FG#\#}"
else
    # Fallback to Gruvbox colors
    COLOR_3="b8bb26"
    COLOR_2="fabd2f"
    COLOR_1="fb4934"
    COLOR_WARNING="fb4934"
    COLOR_TEXT="ebdbb2"
    COLOR_BG="272e33"
    COLOR_FG="d8caac"
fi

# Check if wf-recorder is running
if pgrep -x "wf-recorder" > /dev/null; then
    pkill -INT -x "wf-recorder"
    sleep 0.5
    if ! pgrep -x "wf-recorder" > /dev/null; then
        notify-send -h string:wf-recorder:record -t 2000 "Recording Stopped" "Video saved to ~/Videos/"
    else
        notify-send -h string:wf-recorder:record -t 2000 "Error" "Failed to stop recording"
    fi
    exit 0
fi

if ! command -v slurp &> /dev/null; then
    notify-send -h string:wf-recorder:record -t 5000 "Error" "slurp is required for region selection\nInstall: sudo pacman -S slurp (Arch)\nor: sudo apt install slurp (Debian)"
    exit 1
fi

# Countdown with pywal colors
notify-send -h string:wf-recorder:record -t 1000 "Recording in:" "<span color='#$COLOR_3' font='20px'><b>3</b></span>"
sleep 1
notify-send -h string:wf-recorder:record -t 1000 "Recording in:" "<span color='#$COLOR_2' font='20px'><b>2</b></span>"
sleep 1
notify-send -h string:wf-recorder:record -t 950 "Recording in:" "<span color='#$COLOR_1' font='20px'><b>1</b></span>"
sleep 1

# Show region selection with pywal-colored ESC instruction
notify-send -h string:wf-recorder:record -t 5000 "Screen Recorder" "<span color='#$COLOR_TEXT'>Select screen region to record</span>\n<span color='#$COLOR_WARNING' font='11px'><b>⎋  Press ESC to cancel</b></span>"

# Capture region with slurp
region=$(slurp 2>&1)

# Check if region was selected or cancelled
if [ -z "$region" ]; then
    notify-send -h string:wf-recorder:record -t 2000 "Recording Cancelled" "<span color='#$COLOR_WARNING'>Region selection cancelled</span>"
    exit 0
elif echo "$region" | grep -q "cancelled"; then
    notify-send -h string:wf-recorder:record -t 2000 "Recording Cancelled" "<span color='#$COLOR_WARNING'>No region selected</span>"
    exit 0
fi

if echo "$region" | grep -q "error"; then
    notify-send -h string:wf-recorder:record -t 5000 "Error" "Failed to select region: $region"
    exit 1
fi

dateTime=$(date +%m-%d-%Y-%H:%M:%S)

# Ultra quality recording
wf-recorder \
    -g "$region" \
    -c "$CODEC" \
    -p "$PRESET" \
    -r "$FRAMERATE" \
    --codec-params "crf=$CRF" \
    --pixel-format yuv420p \
    --force-yuv \
    -f "$HOME/Videos/ULTRA-$dateTime.mp4" &

sleep 0.5

if pgrep -x "wf-recorder" > /dev/null; then
    notify-send -h string:wf-recorder:record -t 3000 "Recording Started" "<span color='#$COLOR_TEXT'>Ultra Quality (CRF $CRF)</span>\n<span color='#$COLOR_TEXT'>${FRAMERATE}fps - $CODEC ($PRESET)</span>\n<span color='#$COLOR_WARNING'>Press hotkey to stop</span>"
else
    notify-send -h string:wf-recorder:record -t 2000 "Error" "Failed to start recording"
fi