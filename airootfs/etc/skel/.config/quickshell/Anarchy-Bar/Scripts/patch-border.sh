#!/bin/bash
# Usage: patch-border.sh <border_size> <look.lua_path>
BORDER_SIZE="$1"
LOOK_LUA="$2"

if [ -z "$BORDER_SIZE" ] || [ -z "$LOOK_LUA" ]; then
    echo "Usage: patch-border.sh <border_size> <look.lua_path>"
    exit 1
fi

if [ ! -f "$LOOK_LUA" ]; then
    echo "File not found: $LOOK_LUA"
    exit 1
fi

sed -i "s/border_size[[:space:]]*=[[:space:]]*[0-9]*/border_size = $BORDER_SIZE/g" "$LOOK_LUA"
