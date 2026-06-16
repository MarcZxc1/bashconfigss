#!/bin/bash

# Define options
performance="󰓅  Performance"
balance="󰗑  Balance"
batterysaving="󰾆  Battery Saving"

# Create a list for Rofi
options="$performance\n$balance\n$batterysaving"

# Show Rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "CPU Frequency" -config ~/.config/rofi/config.rasi)

# Apply choice
case "$chosen" in
    "$performance")
        sudo cpupower frequency-set -g performance
        notify-send -a "CPU-Power" "CPU Power" "Mode set to Performance"
        ;;
    "$balance")
        sudo cpupower frequency-set -g powersave
        sudo cpupower set -e balance_performance
        notify-send -a "CPU-Power" "CPU Power" "Mode set to Balance"
        ;;
    "$batterysaving")
        sudo cpupower frequency-set -g powersave
        sudo cpupower set -e power
        notify-send -a "CPU-Power" "CPU Power" "Mode set to Battery Saving"
        ;;
esac
