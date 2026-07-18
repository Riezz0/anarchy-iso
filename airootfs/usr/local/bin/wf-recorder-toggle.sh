#!/bin/env bash

# Ultra Quality Settings
FRAMERATE=60
CODEC="libx264"
PRESET="fast"
CRF=17

# Get pywal colors
WAL_COLORS="$HOME/.cache/wal/colors"
if [ -f "$WAL_COLORS" ]; then
    # Read pywal colors
    mapfile -t colors < "$WAL_COLORS"
    
    # Pywal color mapping (0-15)
    # 0: background, 1: color1, 2: color2, 3: color3, 4: color4, 
    # 5: color5, 6: color6, 7: color7, 8: color8, 15: foreground
    
    # Countdown colors
    COLOR_3="${colors[2]:-b8bb26}"  # color2 (green)
    COLOR_2="${colors[3]:-fabd2f}"  # color3 (yellow)
    COLOR_1="${colors[1]:-fb4934}"  # color1 (red)
    
    # ESC warning color - use color1 (red) or color9 (bright red if available)
    if [ ${#colors[@]} -ge 10 ]; then
        COLOR_WARNING="${colors[9]:-${colors[1]}}"  # color9 (bright red) or fallback to color1
    else
        COLOR_WARNING="${colors[1]:-fb4934}"  # color1 (red)
    fi
    
    # Normal text color - use color7 (foreground) or color15
    COLOR_TEXT="${colors[7]:-ebdbb2}"
    
    # Remove # from hex colors
    COLOR_3="${COLOR_3#\#}"
    COLOR_2="${COLOR_2#\#}"
    COLOR_1="${COLOR_1#\#}"
    COLOR_WARNING="${COLOR_WARNING#\#}"
    COLOR_TEXT="${COLOR_TEXT#\#}"
else
    # Fallback to Gruvbox colors
    COLOR_3="b8bb26"
    COLOR_2="fabd2f"
    COLOR_1="fb4934"
    COLOR_WARNING="fb4934"
    COLOR_TEXT="ebdbb2"
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
