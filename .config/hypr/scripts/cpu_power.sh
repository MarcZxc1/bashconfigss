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
        profile="performance"
        label="Performance"
        ;;
    "$balance")
        profile="balanced"
        label="Balanced"
        ;;
    "$batterysaving")
        profile="power"
        label="Battery Saving"
        ;;
    *)
        exit 0
        ;;
esac

# The root-owned helper validates the profile and changes both Dell's platform
# profile and Intel's energy/performance preference as one operation.
if pkexec /usr/local/libexec/dell-power-profile "$profile"; then
    notify-send -a "CPU-Power" "CPU Power" "Mode set to $label"
else
    notify-send -a "CPU-Power" "CPU Power" "Profile change was cancelled or denied."
fi
