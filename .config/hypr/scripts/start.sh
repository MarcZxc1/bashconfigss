#!/bin/bash

# ~/.config/hypr/scripts/start.sh
# Windows-like startup script

# Kill already running processes to avoid duplicates
killall -q waybar dunst nm-applet blueman-applet udiskie

# Start taskbar and notifications
waybar &
dunst &

# Start system tray applets
nm-applet --indicator &
blueman-applet &
udiskie &

# Set up hyprswitch (Alt+Tab Switcher) daemon
hyprswitch init --show-title &
