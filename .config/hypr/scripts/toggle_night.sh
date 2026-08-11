#!/bin/bash

SHADER="blue-light-filter"

if ! hyprshade toggle "$SHADER"; then
    notify-send -a "System" -u critical "Night Mode" "Could not change the screen shader"
    exit 1
fi

if [ "$(hyprshade current)" = "$SHADER" ]; then
    notify-send -a "System" "Night Mode" "Enabled" -i notification-display-brightness-low
else
    notify-send -a "System" "Night Mode" "Disabled" -i notification-display-brightness
fi
