#!/bin/bash
# Sync GTK settings with GSettings for Hyprland
CONFIG="\$HOME/.config/gtk-3.0/settings.ini"
if [ -f "\$CONFIG" ]; then
    GTK_THEME=\$(grep 'gtk-theme-name' "\$CONFIG" | cut -d'=' -f2)
    ICON_THEME=\$(grep 'gtk-icon-theme-name' "\$CONFIG" | cut -d'=' -f2)
    CURSOR_THEME=\$(grep 'gtk-cursor-theme-name' "\$CONFIG" | cut -d'=' -f2)
    FONT_NAME=\$(grep 'gtk-font-name' "\$CONFIG" | cut -d'=' -f2)

    gsettings set org.gnome.desktop.interface gtk-theme "\$GTK_THEME"
    gsettings set org.gnome.desktop.interface icon-theme "\$ICON_THEME"
    gsettings set org.gnome.desktop.interface cursor-theme "\$CURSOR_THEME"
    gsettings set org.gnome.desktop.interface font-name "\$FONT_NAME"
fi
