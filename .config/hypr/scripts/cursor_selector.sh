#!/bin/bash

# Define options with Nerd Font icons
breeze="󰆿  Breeze"
bibata_ice="󰆿  Bibata Ice (Modern)"
bibata_amber="󰆿  Bibata Amber"
adwaita="󰆿  Adwaita"

options="$bibata_ice\n$bibata_amber\n$breeze\n$adwaita"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Select Cursor" -config ~/.config/rofi/config.rasi)

case "$chosen" in
    "$bibata_ice")
        theme="Bibata-Modern-Ice"
        ;;
    "$bibata_amber")
        theme="Bibata-Modern-Amber"
        ;;
    "$breeze")
        theme="breeze_cursors"
        ;;
    "$adwaita")
        theme="Adwaita"
        ;;
    *)
        exit 1
        ;;
esac

# Apply theme
gsettings set org.gnome.desktop.interface cursor-theme "$theme"
hyprctl keyword env XCURSOR_THEME,$theme
notify-send -a "System" "Cursor Updated" "Theme set to $theme. (Restart apps to apply fully)"
