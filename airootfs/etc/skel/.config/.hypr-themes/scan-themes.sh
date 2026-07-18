#!/bin/bash
THEME_DIR="$HOME/.config/.hypr-themes"
THUMB_NAMES=("thumbnail.png" "thumbnail.jpg" "thumbnail.jpeg" "thumbnail.webp")

for dir in "$THEME_DIR"/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")

    script=""
    for f in "$dir"*.sh; do
        [ -f "$f" ] || continue
        script="$f"
        break
    done

    thumb=""
    for t in "${THUMB_NAMES[@]}"; do
        if [ -f "$dir$t" ]; then
            thumb="$dir$t"
            break
        fi
    done

    printf '{"name":"%s","thumbnail":"%s","script":"%s"}\n' \
        "$name" "$thumb" "$script"
done
