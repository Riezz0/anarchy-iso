#!/bin/sh
POS=$(hyprctl cursorpos)
X=$(echo "$POS" | awk -F', ' '{print $1}')
Y=$(echo "$POS" | awk -F', ' '{print $2}')
hyprctl monitors -j | jq -r --argjson x "$X" --argjson y "$Y" '[.[] | select($x >= .x and $x < .x + .width and $y >= .y and $y < .y + .height)] | .[0].name // empty'
