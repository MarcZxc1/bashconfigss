#!/bin/bash

# Define options
shutdown="󰐥  Shutdown"
reboot="󰜉  Reboot"
logout="󰍃  Logout"
suspend="󰤄  Suspend"

# Create a list for Rofi
options="$shutdown\n$reboot\n$suspend\n$logout"

# Show Rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -config ~/.config/rofi/config.rasi)

# Apply choice
case "$chosen" in
    "$shutdown")
        systemctl poweroff
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$logout")
        hyprctl dispatch exit
        ;;
esac
