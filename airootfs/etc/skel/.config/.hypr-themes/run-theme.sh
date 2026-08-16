#!/bin/bash
# Detached theme runner
LOG="/tmp/theme-apply.log"
THEME_SCRIPT="$1"

echo "[$(date)] Starting theme: $THEME_SCRIPT" >> "$LOG"

if [ -z "$THEME_SCRIPT" ] || [ ! -f "$THEME_SCRIPT" ]; then
    echo "[$(date)] ERROR: Script not found: $THEME_SCRIPT" >> "$LOG"
    exit 1
fi

# Run theme script — it handles hyprlook copy, patching, killall, and restart
bash "$THEME_SCRIPT" >> "$LOG" 2>&1

echo "[$(date)] Script finished" >> "$LOG"
