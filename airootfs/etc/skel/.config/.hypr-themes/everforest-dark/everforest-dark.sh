#!/bin/bash

#========================#
#     EVERFOREST DARK    #
#========================#

#------------------------#
# VARIABLES
#------------------------#
USER_HOME="$HOME"
THEME_NAME="everforest-dark"
THEME_DISPLAY="Everforest Dark"
THEME_DIR="$USER_HOME/.config/.hypr-themes/$THEME_NAME"

# Wallpaper
WALL="$USER_HOME/.config/.hypr-themes/$THEME_NAME/thumbnail.png"

# Pywal
PYWAL="$USER_HOME/.config/pywal/themes/active.json"

# GTK, Icons and Cursors
GTK_THEME="graphite-anarchy-everforest-dark"
ICON_THEME="EverforestDark-Icons"
CURSOR_THEME="EverforestDark-Cursors"

# Kvantum
KVANTUM_DIR="$USER_HOME/.config/Kvantum/pywal"
#------------------------#

#------------------------#
# SET WALLPAPER
#------------------------#
awww img "$WALL" --transition-fps 144 --transition-step 255 --transition-type random
cp -r "$WALL" "/home/$USER/.config/hypr/lock.png"
cp -r "$WALL" "/home/$USER/.config/activebg/Wall.png"
cp "$WALL" "/var/local/sddm-wallpaper/background.jpg"

#------------------------#
# SET COLOR SCHEME
#------------------------#
cp -r "$THEME_DIR/pywal" "$PYWAL"
wal --theme "$PYWAL"  # synchronous to ensure cache files exist
cp ~/.cache/wal/colors.json /var/local/sddm-wallpaper/colors.json

#------------------------#
# MAKE DIRECTORIES
#------------------------#
mkdir -p /home/$USER/.config/vesktop/themes/

#------------------------#
# COPY CONFIG FILES
#------------------------#
cp -r "$THEME_DIR/hypr-colors" "$USER_HOME/.config/hypr/modules/colors.lua"
cp -r "$THEME_DIR/hyprlook" "$USER_HOME/.config/hypr/modules/look.lua"
cp -r "$THEME_DIR/kitty" "$USER_HOME/.config/kitty/kitty.conf"
cp -r "$THEME_DIR/qcol" "$USER_HOME/.config/quickshell/mainbar/Theme.qml"
cp -r "$THEME_DIR/rofi" "$USER_HOME/.config/rofi/launcher/colors.rasi"
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
echo "$ICON_THEME" > "$HOME/.cache/current_icon_theme.txt"
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
# FASTFETCH
#------------------------#
rm -rf ~/.cache/fastfetch 
cp -r "$THEME_DIR/arch-everforest-dark.png" "/home/$USER/.config/fastfetch/arch.png"

#------------------------#
# WAYBAR ICON
#------------------------#
cp -r "$THEME_DIR/arch-everforest-dark.png" "/home/$USER/.config/waybar/icons/arch.png"
cp -r "$THEME_DIR/arch-everforest-dark.png" "/home/$USER/.config/quickshell/assets/arch.png"

#------------------------#
# REFRESH INTERFACES
#------------------------#
hyprctl setcursor "$CURSOR_THEME" 30
hyprctl reload
kill -SIGUSR1 $(pidof kitty)
pywalfox update & disown 
#swaync-client -rs
#bash /home/$USER/.config/scripts/waybar.sh
killall quickshell
bash /usr/local/bin/qbarmain.sh
systemctl --user restart xdg-desktop-portal-gtk xdg-desktop-portal
wait 

#------------------------#
# COPY THEME
#------------------------#
cp "$THEME_DIR/$THEME_NAME.sh" "/home/$USER/.local/share/themes/hypr-theme-active.sh"

#------------------------#
# NOTIFICATION
#------------------------#
notify-send -a "$THEME_DISPLAY" "Theme Loaded"

#------------------------#
# NAUTILUS
#------------------------#
nautilus -q && gtk4-update-icon-cache ~/.config/gtk-4.0
