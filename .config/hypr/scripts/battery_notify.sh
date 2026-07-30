#!/bin/bash

# Automatically detect the battery directory
for bat_path in /sys/class/power_supply/BAT*; do
    if [ -d "$bat_path" ]; then
        BAT_DIR="$bat_path"
        break
    fi
done

# Exit if no battery is found
if [ -z "$BAT_DIR" ]; then
    exit 0
fi

while true; do
    STATUS=$(cat "$BAT_DIR/status")
    CAPACITY=$(cat "$BAT_DIR/capacity")

    if [ "$STATUS" = "Discharging" ]; then
        if [ "$CAPACITY" -le 10 ]; then
            notify-send -u critical "CRITICAL BATTERY" "Laptop will die soon! ($CAPACITY%)" -i battery-empty
            sleep 60 # Remind every minute when critical
        elif [ "$CAPACITY" -le 20 ]; then
            notify-send -u normal "Low Battery" "Battery is at $CAPACITY%. Please plug in the charger." -i battery-low
            sleep 300 # Remind every 5 minutes when low
        else
            sleep 60 # Check every minute normally
        fi
    else
        sleep 60 # Check every minute if charging
    fi
done
