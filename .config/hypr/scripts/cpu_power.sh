#!/usr/bin/env bash

set -u

performance="󰓅  Performance"
balance="󰗑  Balanced"
batterysaving="󰾆  Battery Saving"
options="$performance\n$balance\n$batterysaving"

chosen="$(
    printf '%b\n' "$options" |
        rofi -dmenu -i -p "CPU Energy Profile" -config "$HOME/.config/rofi/config.rasi"
)"

case "$chosen" in
    "$performance")
        preference="performance"
        label="Performance"
        ;;
    "$balance")
        preference="balance_power"
        label="Balanced"
        ;;
    "$batterysaving")
        preference="power"
        label="Battery Saving"
        ;;
    *)
        exit 0
        ;;
esac

available="/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences"
if [ ! -r "$available" ] || ! grep -qw "$preference" "$available"; then
    notify-send -a "CPU-Power" "CPU Power" "The $label profile is unavailable."
    exit 1
fi

# Invoke the fixed system binary through polkit. This avoids an invisible sudo
# prompt from Waybar and does not elevate this user-writable script itself.
if pkexec /usr/bin/cpupower set -e "$preference"; then
    notify-send -a "CPU-Power" "CPU Power" "Mode set to $label"
else
    notify-send -a "CPU-Power" "CPU Power" "Profile change was cancelled or denied."
fi
