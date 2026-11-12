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

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
THEME_ROOT="$(cd "$(dirname "$SELF")" && pwd -P)"
# .../.config/.hypr-themes -> repo root (works via the stow symlink and even
# when the repo has been cloned under a different name/location).
REPO_ROOT="$(cd "$THEME_ROOT/../../.." && pwd -P)"

# Reapply user-managed Hyprland values after any theme script copy, including
# future theme scripts that still copy hyprlook directly.
bash "$THEME_ROOT/patch-look.sh" --sync-all >> "$LOG" 2>&1

echo "[$(date)] Script finished" >> "$LOG"

#------------------------#
# CAELESTIA SHELL COLORS #
#------------------------#
# Resolve the bridge instead of hardcoding the checkout directory, so the
# theme still recolours the shell when the repo lives somewhere else (fresh
# VM, different username, renamed clone).
BRIDGE="$(command -v wal-to-caelestia 2>/dev/null || true)"
[ -n "$BRIDGE" ] || BRIDGE="$HOME/.local/bin/wal-to-caelestia"
[ -x "$BRIDGE" ] || BRIDGE="$REPO_ROOT/local-bin/bin/wal-to-caelestia"

theme_dir="$(dirname "$THEME_SCRIPT")"
theme_name="$(basename "$theme_dir")"
if [ -f "$BRIDGE" ]; then
    python3 "$BRIDGE" "$theme_name" >> "$LOG" 2>&1
else
    echo "[$(date)] ERROR: wal-to-caelestia bridge not found" >> "$LOG"
fi
