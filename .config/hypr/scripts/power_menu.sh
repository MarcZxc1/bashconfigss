#!/usr/bin/env bash

set -u

# Define options
shutdown="󰐥  Shutdown"
reboot="󰜉  Reboot"
logout="󰍃  Logout"
suspend="󰤄  Suspend"

# Create a list for Rofi
options="$shutdown\n$reboot\n$suspend\n$logout"

# Show Rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -config ~/.config/rofi/config.rasi)

confirm_action() {
    local action="$1"
    local answer

    answer="$(
        printf 'Cancel\n%s\n' "$action" |
            rofi -dmenu -i -p "Confirm $action?"
    )"
    [ "$answer" = "$action" ]
}

# Apply choice
case "$chosen" in
    "$shutdown")
        confirm_action "Shutdown" && systemctl poweroff
        ;;
    "$reboot")
        confirm_action "Reboot" && systemctl reboot
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$logout")
        confirm_action "Logout" && uwsm stop
        ;;
esac
