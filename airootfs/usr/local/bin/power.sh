#!/bin/bash
USER=$(whoami)
CONFIG="/home/$USER/.config/waybar/power-bar/power-bar.jsonc"
STYLE="/home/$USER/.config/waybar/power-bar/power-bar-style.css"
PID_FILE="/tmp/waybar-power-menu.pid"

# Check if power menu is already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        # Power menu is running, kill it
        kill "$PID"
        rm "$PID_FILE"
        exit 0
    else
        # PID file exists but process is dead, clean up
        rm "$PID_FILE"
    fi
fi

# Start new power menu with both config and style, and save its PID
waybar -c "$CONFIG" -s "$STYLE" &
echo $! > "$PID_FILE"
