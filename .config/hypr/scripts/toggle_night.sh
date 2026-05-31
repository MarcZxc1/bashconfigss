#!/bin/bash

if hyprshade current | grep -q "blue-light-filter"; then
    hyprshade off
    notify-send -a "System" "Night Mode" "Disabled (Normal Colors)" -i notification-display-brightness
else
    hyprshade on blue-light-filter
    notify-send -a "System" "Night Mode" "Enabled (Blue Light Filter)" -i notification-display-brightness-low
fi
