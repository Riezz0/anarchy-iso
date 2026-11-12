#!/bin/bash
THEME_DIR="$HOME/.config/.hypr-themes"
CACHE_DIR="$HOME/.cache/anarchy-theme-switcher/thumbnails-v2"
THUMB_NAMES=("thumbnail.png" "thumbnail.jpg" "thumbnail.jpeg" "thumbnail.webp")

mkdir -p "$CACHE_DIR"

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

    cached="$CACHE_DIR/$name.png"
    if [ -n "$thumb" ] && { [ ! -f "$cached" ] || [ "$thumb" -nt "$cached" ]; }; then
        magick "$thumb" -thumbnail '230x360^' -gravity center -extent 230x360 -strip "$cached" 2>/dev/null || rm -f "$cached"
    fi

    if [ -f "$cached" ]; then
        thumb="$cached"
    fi

    printf '{"name":"%s","thumbnail":"%s","script":"%s"}\n' \
        "$name" "$thumb" "$script"
done
