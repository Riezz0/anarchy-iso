#!/bin/bash
# Keep Anarchy-Bar's Hyprland settings in sync across themes.
#
# Usage:
#   patch-look.sh <source_hyprlook>  Patch a theme into the active look.lua
#   patch-look.sh --sync-all [value] Update every theme and the active config

ANARCHY_BAR_JSON="$HOME/.config/quickshell/Anarchy-Bar/Settings/bar.json"
ANARCHY_SHELL_JSON="$HOME/.config/anarchy-shell/hyprland.json"
LOOK_LUA="$HOME/.config/hypr/modules/look.lua"

read_border_value() {
    sed -nE 's/.*"hyprlandBorderThickness"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON"
}

# Anarchy-Shell is migrating off Anarchy-Bar: when its shell.json has a
# "hyprland" section key, those values win over bar.json (which then acts
# as the fallback default). Usage: read_shell_value <shell.json key> <default>
read_shell_value() {
    local shell_value
    shell_value=$(jq -r --arg k "$1" '.hyprland[$k] // empty' "$ANARCHY_SHELL_JSON" 2>/dev/null)
    if [ -n "$shell_value" ] && [ "$shell_value" != "null" ]; then
        printf '%s' "$shell_value"
    else
        printf '%s' "$2"
    fi
}

patch_file() {
    local file="$1"
    local value="$2"
    local active="$3"
    local inactive="$4"
    local rounding="$5"
    local power="$6"
    local blur_enabled="$7"
    local blur_passes="$8"
    local blur_size="$9"
    local blur_vibrancy="${10}"
    local gap_in="${11}"
    local gap_out="${12}"
    sed -i -E "s/border_size[[:space:]]*=[[:space:]]*[0-9]+/border_size = $value/g" "$file"
    sed -i -E "s/gaps_in[[:space:]]*=[[:space:]]*[0-9]+/gaps_in = $gap_in/g; s/gaps_out[[:space:]]*=[[:space:]]*[0-9]+/gaps_out = $gap_out/g" "$file"
    sed -i -E "s/active_opacity[[:space:]]*=[[:space:]]*[0-9.]+/active_opacity = $active/g; s/inactive_opacity[[:space:]]*=[[:space:]]*[0-9.]+/inactive_opacity = $inactive/g" "$file"
    sed -i -E "s/rounding[[:space:]]*=[[:space:]]*[0-9]+/rounding = $rounding/g; s/rounding_power[[:space:]]*=[[:space:]]*[0-9]+/rounding_power = $power/g" "$file"
    sed -i -E "/blur[[:space:]]*=/,/},},/ { s/enabled[[:space:]]*=[[:space:]]*(true|false)/enabled = $blur_enabled/g; s/passes[[:space:]]*=[[:space:]]*[0-9]+/passes = $blur_passes/g; s/size[[:space:]]*=[[:space:]]*[0-9]+/size = $blur_size/g; s/vibrancy[[:space:]]*=[[:space:]]*[0-9.]+/vibrancy = $blur_vibrancy/g; }" "$file"
    sed -i -E 's/gaps_in[[:space:]]*=/gaps_in =/g; s/gaps_out[[:space:]]*=/gaps_out =/g' "$file"
}

if [ "$1" = "--sync-all" ]; then
    VALUE="${2:-$(read_shell_value borderSize "$(read_border_value)")}"
    ACTIVE="${3:-$(read_shell_value activeOpacity "$(sed -nE 's/.*"hyprlandActiveOpacity"[[:space:]]*:[[:space:]]*([0-9.]+).*/\1/p' "$ANARCHY_BAR_JSON")")}"
    INACTIVE="${4:-$(read_shell_value inactiveOpacity "$(sed -nE 's/.*"hyprlandInactiveOpacity"[[:space:]]*:[[:space:]]*([0-9.]+).*/\1/p' "$ANARCHY_BAR_JSON")")}"
    ROUNDING="${5:-$(read_shell_value rounding "$(sed -nE 's/.*"hyprlandRounding"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")}"
    POWER="${6:-$(read_shell_value roundingPower "$(sed -nE 's/.*"hyprlandRoundingPower"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")}"
    BLUR_ENABLED="${7:-$(read_shell_value blurEnabled "$(sed -nE 's/.*"hyprlandBlurEnabled"[[:space:]]*:[[:space:]]*(true|false).*/\1/p' "$ANARCHY_BAR_JSON")")}"
    BLUR_PASSES="${8:-$(read_shell_value blurPasses "$(sed -nE 's/.*"hyprlandBlurPasses"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")}"
    BLUR_SIZE="${9:-$(read_shell_value blurSize "$(sed -nE 's/.*"hyprlandBlurSize"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")}"
    BLUR_VIBRANCY="${10:-$(read_shell_value blurVibrancy "$(sed -nE 's/.*"hyprlandBlurVibrancy"[[:space:]]*:[[:space:]]*([0-9.]+).*/\1/p' "$ANARCHY_BAR_JSON")")}"
    GAP_IN="${11:-$(read_shell_value gapsIn "$(sed -nE 's/.*"hyprlandGapIn"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")}"
    GAP_OUT="${12:-$(read_shell_value gapsOut "$(sed -nE 's/.*"hyprlandGapOut"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")}"
    case "$VALUE" in
        ''|*[!0-9]*) exit 2 ;;
    esac
    case "$ACTIVE" in
        ''|*[!0-9.]*) exit 2 ;;
    esac
    case "$INACTIVE" in
        ''|*[!0-9.]*) exit 2 ;;
    esac
    case "$ROUNDING:$POWER" in
        ''|*[!0-9:]*) exit 2 ;;
    esac
    case "$BLUR_ENABLED" in true|false) ;; *) exit 2 ;; esac
    case "$BLUR_PASSES:$BLUR_SIZE:$BLUR_VIBRANCY" in
        ''|*[!0-9.:]*) exit 2 ;;
    esac
    case "$GAP_IN:$GAP_OUT" in
        ''|*[!0-9:]*) exit 2 ;;
    esac

    for SOURCE in "$HOME"/.config/.hypr-themes/*/hyprlook; do
        [ -f "$SOURCE" ] || continue
        patch_file "$SOURCE" "$VALUE" "$ACTIVE" "$INACTIVE" "$ROUNDING" "$POWER" "$BLUR_ENABLED" "$BLUR_PASSES" "$BLUR_SIZE" "$BLUR_VIBRANCY" "$GAP_IN" "$GAP_OUT"
    done

    if [ -f "$LOOK_LUA" ]; then
        patch_file "$LOOK_LUA" "$VALUE" "$ACTIVE" "$INACTIVE" "$ROUNDING" "$POWER" "$BLUR_ENABLED" "$BLUR_PASSES" "$BLUR_SIZE" "$BLUR_VIBRANCY" "$GAP_IN" "$GAP_OUT"
        hyprctl reload 2>/dev/null || true
    fi
    exit 0
fi

VALUE=$(read_shell_value borderSize "$(read_border_value)")
ACTIVE=$(read_shell_value activeOpacity "$(sed -nE 's/.*"hyprlandActiveOpacity"[[:space:]]*:[[:space:]]*([0-9.]+).*/\1/p' "$ANARCHY_BAR_JSON")")
INACTIVE=$(read_shell_value inactiveOpacity "$(sed -nE 's/.*"hyprlandInactiveOpacity"[[:space:]]*:[[:space:]]*([0-9.]+).*/\1/p' "$ANARCHY_BAR_JSON")")
ROUNDING=$(read_shell_value rounding "$(sed -nE 's/.*"hyprlandRounding"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")
POWER=$(read_shell_value roundingPower "$(sed -nE 's/.*"hyprlandRoundingPower"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")
BLUR_ENABLED=$(read_shell_value blurEnabled "$(sed -nE 's/.*"hyprlandBlurEnabled"[[:space:]]*:[[:space:]]*(true|false).*/\1/p' "$ANARCHY_BAR_JSON")")
BLUR_PASSES=$(read_shell_value blurPasses "$(sed -nE 's/.*"hyprlandBlurPasses"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")
BLUR_SIZE=$(read_shell_value blurSize "$(sed -nE 's/.*"hyprlandBlurSize"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")
BLUR_VIBRANCY=$(read_shell_value blurVibrancy "$(sed -nE 's/.*"hyprlandBlurVibrancy"[[:space:]]*:[[:space:]]*([0-9.]+).*/\1/p' "$ANARCHY_BAR_JSON")")
GAP_IN=$(read_shell_value gapsIn "$(sed -nE 's/.*"hyprlandGapIn"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")
GAP_OUT=$(read_shell_value gapsOut "$(sed -nE 's/.*"hyprlandGapOut"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$ANARCHY_BAR_JSON")")
[ -n "$VALUE" ] || exit 0
[ -n "$ACTIVE" ] || exit 0
[ -n "$INACTIVE" ] || exit 0
[ -n "$ROUNDING" ] || exit 0
[ -n "$POWER" ] || exit 0
[ -n "$BLUR_ENABLED" ] || exit 0
[ -n "$BLUR_PASSES" ] || exit 0
[ -n "$BLUR_SIZE" ] || exit 0
[ -n "$BLUR_VIBRANCY" ] || exit 0
[ -n "$GAP_IN" ] || exit 0
[ -n "$GAP_OUT" ] || exit 0
[ -f "$LOOK_LUA" ] || exit 0

if [ -n "$1" ] && [ -f "$1" ]; then
    TMPFILE=$(mktemp "${LOOK_LUA}.XXXXXX")
    cp "$1" "$TMPFILE"
    patch_file "$TMPFILE" "$VALUE" "$ACTIVE" "$INACTIVE" "$ROUNDING" "$POWER" "$BLUR_ENABLED" "$BLUR_PASSES" "$BLUR_SIZE" "$BLUR_VIBRANCY" "$GAP_IN" "$GAP_OUT"
    mv "$TMPFILE" "$LOOK_LUA"
else
    patch_file "$LOOK_LUA" "$VALUE" "$ACTIVE" "$INACTIVE" "$ROUNDING" "$POWER" "$BLUR_ENABLED" "$BLUR_PASSES" "$BLUR_SIZE" "$BLUR_VIBRANCY" "$GAP_IN" "$GAP_OUT"
fi
