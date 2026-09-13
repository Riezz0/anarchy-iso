#!/bin/bash
# Usage: patch-hypr-bool.sh <key> <value> <file_path>
KEY="$1"
VALUE="$2"
FILE="$3"

if [ -z "$KEY" ] || [ -z "$VALUE" ] || [ -z "$FILE" ]; then
    echo "Usage: patch-hypr-bool.sh <key> <value> <file_path>"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

sed -i "s/${KEY}[[:space:]]*=[[:space:]]*true/${KEY}   = ${VALUE}/g; s/${KEY}[[:space:]]*=[[:space:]]*false/${KEY}   = ${VALUE}/g" "$FILE"
