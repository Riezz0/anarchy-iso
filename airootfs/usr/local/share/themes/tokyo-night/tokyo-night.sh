#!/bin/bash

#========================#
#       TOKYO NIGHT      #
#========================#

#------------------------#
# VARIABLES
#------------------------#
USER_HOME="$HOME"
THEME_NAME="tokyo-night"
THEME_DISPLAY="Tokyo Night Dark Theme"
THEME_DIR="$USER_HOME/.config/.hypr-themes/$THEME_NAME"

# Wallpaper
WALL="$USER_HOME/.config/.hypr-themes/$THEME_NAME/thumbnail.png"

# Pywal
PYWAL="$USER_HOME/.config/pywal/themes/active.json"

# GTK and Icons
GTK_THEME="adw-gtk3-dark"
ICON_THEME="oomox-tokyo-night"

# Kvantum
KVANTUM_DIR="$USER_HOME/.config/Kvantum/pywal"
#------------------------#

#------------------------#
# SET WALLPAPER
#------------------------#
awww img "$WALL" --transition-fps 144 --transition-step 255 --transition-type random
cp -r "$WALL" "/home/$USER/.config/hypr/lock.png"
cp -r "$WALL" "/home/$USER/.config/wallpapers/Wall.png"

#------------------------#
# SET COLOR SCHEME
#------------------------#
cp -r "$THEME_DIR/pywal" "$PYWAL"
wal --theme "$PYWAL"  # synchronous to ensure cache files exist

#------------------------#
# MAKE DIRECTORIES
#------------------------#
mkdir -p /home/$USER/.config/vesktop/themes/

#------------------------#
# COPY CONFIG FILES
#------------------------#
cp -r "$THEME_DIR/hypr-colors" "$USER_HOME/.config/hypr/colors.conf"
cp -r "$THEME_DIR/hyprlook" "$USER_HOME/.config/hypr/look.conf"
cp -r "$THEME_DIR/kitty" "$USER_HOME/.config/kitty/kitty.conf"
cp -r "$THEME_DIR/main-bar" "$USER_HOME/.config/waybar/main-bar/bar-style.css"
cp -r "$THEME_DIR/power-bar" "$USER_HOME/.config/waybar/power-bar/power-bar-style.css"
cp -r "$THEME_DIR/theme-bar" "$USER_HOME/.config/waybar/power-bar/theme-bar-style.css"
cp -r "$THEME_DIR/rofi" "$USER_HOME/.config/rofi/launcher/colors.rasi"
cp -r "$THEME_DIR/wf-recorder-toggle.sh" "$USER_HOME/.config/scripts/wf-recorder-toggle.sh"
cp -f "${HOME}"/.cache/wal/pywal.json "${HOME}"/.config/presets/user/pywal.json
cp -r $HOME/.cache/wal/colors-discord.css $HOME/.config/vesktop/themes/pywal-vencord.theme.css
#--------------------------#
# REMOVE CONFLICTING FILES
#--------------------------#
rm -rf /home/$USER/.config/gtk-4.0/*
rm -rf /home/$USER/.config/gtk-3.0/*

#------------------------#
# SET GTK AND ICON THEME
#------------------------#
cp -r "/home/$USER/.themes/adw-gtk3-dark/gtk-4.0/assets/" "$USER_HOME/.config/gtk-4.0/"
cp -r "/home/$USER/.themes/adw-gtk3-dark/gtk-4.0/gtk-dark.css" "$USER_HOME/.config/gtk-4.0/"
cp -r "/home/$USER/.themes/adw-gtk3-dark/gtk-4.0/gtk.css" "$USER_HOME/.config/gtk-4.0/"
cp -r "/home/$USER/.themes/adw-gtk3-dark/gtk-4.0/libadwaita-tweaks.css" "$USER_HOME/.config/gtk-4.0/"
cp -r "/home/$USER/.themes/adw-gtk3-dark/gtk-4.0/libadwaita.css" "$USER_HOME/.config/gtk-4.0/"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
wait
gradience-cli apply -p ~/.config/presets/user/pywal.json --gtk both  
gradience-cli flatpak-overrides -e both 

#------------------------#
# SET KVANTUM THEME
#------------------------#
mkdir -p "$KVANTUM_DIR"

# Wait until Pywal cache files exist
while [ ! -f "$HOME/.cache/wal/pywal.kvconfig" ] || [ ! -f "$HOME/.cache/wal/pywal.svg" ]; do
    sleep 0.1
done

cp "$HOME/.cache/wal/pywal.kvconfig" "$KVANTUM_DIR/pywal.kvconfig"
cp "$HOME/.cache/wal/pywal.svg" "$KVANTUM_DIR/pywal.svg"

#------------------------#
# FLATPAK THEME COMPATIBILITY
#------------------------#
flatpak override --user --filesystem="$HOME/.themes"
flatpak override --user --filesystem="$HOME/.icons"
flatpak override --user --filesystem=xdg-config/gtk-4.0

#------------------------#
# REFRESH INTERFACES
#------------------------#
hyprctl reload
kill -SIGUSR1 $(pidof kitty)
pywalfox update
swaync-client -rs
bash /home/$USER/.config/scripts/waybar.sh

#------------------------#
# NOTIFICATION
#------------------------#
swaync-client --hide-all
notify-send "$THEME_DISPLAY Loaded"

