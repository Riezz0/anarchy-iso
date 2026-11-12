#!/bin/bash

THEME_DIR="$HOME/.config/.hypr-themes"

printf "["

first=true

for dir in "$THEME_DIR"/*/; do
    name=$(basename "$dir")
    thumb="$dir/thumbnail.png"
    script="$dir/$name.sh"

    if [ "$first" = true ]; then
        first=false
    else
        printf ","
    fi

    printf '\n{
      "name":"%s",
      "thumbnail":"%s",
      "script":"%s"
    }' \
    "$name" \
    "$thumb" \
    "$script"
done

printf "\n]"
