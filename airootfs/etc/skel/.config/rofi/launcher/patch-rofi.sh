#!/usr/bin/env bash
LAUNCHER_RASI="$1"
RADIUS="$2"
THICKNESS="$3"

sed -i "s/border-radius:[[:space:]]*[0-9]*px[[:space:]]*[0-9]*px[[:space:]]*[0-9]*px[[:space:]]*[0-9]*px/border-radius: ${RADIUS}px ${RADIUS}px ${RADIUS}px ${RADIUS}px/g" "$LAUNCHER_RASI"
sed -i "s/border-radius:[[:space:]]*[0-9]*px;/border-radius: ${RADIUS}px;/g" "$LAUNCHER_RASI"
sed -i "0,/border:[[:space:]]*[0-9]*px solid;/s/border:[[:space:]]*[0-9]*px solid;/border: ${THICKNESS}px solid;/" "$LAUNCHER_RASI"
