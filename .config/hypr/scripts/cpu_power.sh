#!/bin/bash

# Define options
performance="󰓅  Performance"
powersave="󰾆  Power Save"

# Create a list for Rofi
options="$performance\n$powersave"

# Show Rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "CPU Power Mode" -config ~/.config/rofi/config.rasi)

# Apply choice
case "$chosen" in
    "$performance")
        sudo cpupower frequency-set -g performance
        notify-send -a "CPU-Power" "CPU Power" "Mode set to Performance"
        ;;
    "$powersave")
        sudo cpupower frequency-set -g powersave
        notify-send -a "CPU-Power" "CPU Power" "Mode set to Power Save"
        ;;
esac
