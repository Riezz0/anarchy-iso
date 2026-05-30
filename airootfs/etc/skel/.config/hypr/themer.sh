#!/bin/bash

#Theme Variables
animeroom="/home/$USER/.config/.hypr-themes/anime-room/anime-room.sh"
catppuccinmocha="/home/$USER/.config/.hypr-themes/catppuccin-mocha/catppuccin-mocha.sh"
everforestdark="/home/$USER/.config/.hypr-themes/everforest-dark/everforest-dark.sh"
gruvboxdark="/home/$USER/.config/.hypr-themes/gruvbox-dark/gruvbox-dark.sh"
tokyonight="/home/$USER/.config/.hypr-themes/tokyo-night/tokyo-night.sh"

selected=$(gum choose \
    --header="Please select a theme:" \
    "1. Anime-Room" \
    "2. Catppuccin-Mocha" \
    "3. Everforest-Dark" \
    "4. Gruvbox-Dark" \
    "5. Tokyo-Night")

# Apply theme
case $selected in
    "1. Anime-Room")
        bash $animeroom
        ;;
    "2. Catppuccin-Mocha")
        bash $catppuccinmocha
        ;;
    "3. Everforest-Dark")
        bash $everforestdark
        ;;
    "4. Gruvbox-Dark")
        bash $gruvboxdark
        ;;
    "5. Tokyo-Night")
        bash $tokyonight
        ;;
esac

