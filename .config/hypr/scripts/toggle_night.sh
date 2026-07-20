#!/bin/bash

SHADER="/usr/share/hyprshade/shaders/blue-light-filter.glsl"
STATE_FILE="/tmp/.night_mode_active"

if [ -f "$STATE_FILE" ]; then
    hyprctl keyword decoration:screen_shader ""
    rm "$STATE_FILE"
    notify-send -a "System" "Night Mode" "Disabled" -i notification-display-brightness
else
    hyprctl keyword decoration:screen_shader "$SHADER"
    touch "$STATE_FILE"
    notify-send -a "System" "Night Mode" "Enabled" -i notification-display-brightness-low
fi
