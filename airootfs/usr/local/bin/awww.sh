#!/bin/bash

# Advanced awww wallpaper script
# Sets wallpaper with transitions and error handling

USER=$(whoami)
WALLPAPER_DIR="/usr/local/share/wallpapers"
LOG_FILE="/usr/local/share/wallpapers/.awww-wallpaper.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if awww is running
if ! awww query; then
    echo "Starting awww daemon..."
    awww-daemon
    sleep 1
fi

# Check if wallpapers directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    error_msg="Error: Wallpaper directory $WALLPAPER_DIR does not exist!"
    echo "$error_msg"
    log "$error_msg"
    exit 1
fi

# Function to set wallpaper
set_wallpaper() {
    local wallpaper=$1
    log "Attempting to set wallpaper: $wallpaper"
    
    # Set wallpaper with awww - using crop to fill entire screen
    if awww img "$wallpaper" --resize=crop --transition-type=any --transition-fps=60 --transition-duration=2; then
        log "Successfully set wallpaper: $wallpaper"
        echo "Wallpaper set successfully: $(basename "$wallpaper")"
        return 0
    else
        error_msg="Failed to set wallpaper: $wallpaper"
        echo "$error_msg"
        log "$error_msg"
        return 1
    fi
}

# Check for available wallpaper files
if [ -f "$WALLPAPER_DIR/Wall.jpg" ]; then
    set_wallpaper "$WALLPAPER_DIR/Wall.jpg"
elif [ -f "$WALLPAPER_DIR/Wall.png" ]; then
    set_wallpaper "$WALLPAPER_DIR/Wall.png"
else
    error_msg="Error: No Wall.jpg or Wall.png found in $WALLPAPER_DIR"
    echo "$error_msg"
    log "$error_msg"
    exit 1
fi
