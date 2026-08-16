#!/bin/bash
# Patch look.lua with saved bar settings (avoids flash on theme switch)
BAR_JSON="$HOME/.config/quickshell/bar-settings.json"
LOOK_LUA="$HOME/.config/hypr/modules/look.lua"
[ -f "$BAR_JSON" ] || exit 0
[ -f "$LOOK_LUA" ] || exit 0
RADIUS=$(grep -o '"hyprlandRadius":[[:space:]]*[0-9]*' "$BAR_JSON" | grep -o '[0-9]*$')
BORDER=$(grep -o '"hyprlandBorderThickness":[[:space:]]*[0-9]*' "$BAR_JSON" | grep -o '[0-9]*$')
GAPIN=$(grep -o '"hyprlandGapIn":[[:space:]]*[0-9]*' "$BAR_JSON" | grep -o '[0-9]*$')
GAPOUT=$(grep -o '"hyprlandGapOut":[[:space:]]*[0-9]*' "$BAR_JSON" | grep -o '[0-9]*$')
OPACITY=$(grep -o '"hyprlandWindowOpacity":[[:space:]]*[0-9.]*' "$BAR_JSON" | grep -o '[0-9.]*$')
BLUREN=$(grep -o '"hyprlandBlurEnabled":[[:space:]]*\(true\|false\)' "$BAR_JSON" | grep -o 'true\|false')
BLURSIZE=$(grep -o '"hyprlandBlurSize":[[:space:]]*[0-9]*' "$BAR_JSON" | grep -o '[0-9]*$')
BLURPASSES=$(grep -o '"hyprlandBlurPasses":[[:space:]]*[0-9]*' "$BAR_JSON" | grep -o '[0-9]*$')
BLURVIB=$(grep -o '"hyprlandBlurVibrancy":[[:space:]]*[0-9.]*' "$BAR_JSON" | grep -o '[0-9.]*$')
[ -n "$RADIUS" ] && sed -i "s/rounding\s*=\s*[0-9]\+/rounding = $RADIUS/g" "$LOOK_LUA"
[ -n "$RADIUS" ] && sed -i "s/rounding_power\s*=\s*[0-9]\+/rounding_power = $RADIUS/g" "$LOOK_LUA"
[ -n "$BORDER" ] && sed -i "s/border_size\s*=\s*[0-9]\+/border_size = $BORDER/g" "$LOOK_LUA"
[ -n "$GAPIN" ] && sed -i "s/gaps_in\s*=\s*[0-9]\+/gaps_in  = $GAPIN/g" "$LOOK_LUA"
[ -n "$GAPOUT" ] && sed -i "s/gaps_out\s*=\s*[0-9]\+/gaps_out = $GAPOUT/g" "$LOOK_LUA"
[ -n "$OPACITY" ] && sed -i "s/active_opacity\s*=\s*[0-9.]\+/active_opacity    = $OPACITY/g" "$LOOK_LUA"
[ -n "$OPACITY" ] && sed -i "s/inactive_opacity\s*=\s*[0-9.]\+/inactive_opacity  = $OPACITY/g" "$LOOK_LUA"
[ -n "$BLUREN" ] && sed -i "s/ enabled\\s*=\\s*true\\| enabled\\s*=\\s*false/enabled   = $BLUREN/g" "$LOOK_LUA"
[ -n "$BLURSIZE" ] && sed -i "s/ size\\s*=\\s*[0-9]\\+/size      = $BLURSIZE/g" "$LOOK_LUA"
[ -n "$BLURPASSES" ] && sed -i "s/ passes\\s*=\\s*[0-9]\\+/passes    = $BLURPASSES/g" "$LOOK_LUA"
[ -n "$BLURVIB" ] && sed -i "s/ vibrancy\\s*=\\s*[0-9.]\\+/vibrancy  = $BLURVIB/g" "$LOOK_LUA"
