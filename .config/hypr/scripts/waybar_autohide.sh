#!/bin/bash

# Configuration
TRIGGER_Y_SHOW=5
TRIGGER_Y_HOVER=45
HIDE_TIMEOUT=30 # 30 * 0.1s = 3 seconds
TICKS=0

# Ensure waybar is killed on exit
trap "killall -9 waybar 2>/dev/null; exit" INT TERM EXIT

toggle_bar() {
    if pgrep -x waybar > /dev/null; then
        killall -9 waybar
    else
        waybar > /dev/null 2>&1 &
        TICKS=0
    fi
}

# Trap USR1 for manual toggle (SUPER+W)
trap 'toggle_bar' USR1

# Main Loop 
while true; do
    pos=$(hyprctl cursorpos 2>/dev/null)
    y=$(echo "$pos" | cut -d',' -f2 | tr -d ' ')
    
    if [[ "$y" =~ ^[0-9]+$ ]]; then
        if ! pgrep -x waybar > /dev/null; then
            if [ "$y" -le "$TRIGGER_Y_SHOW" ]; then
                waybar > /dev/null 2>&1 &
                TICKS=0
            fi
        else
            if [ "$y" -gt "$TRIGGER_Y_HOVER" ]; then
                TICKS=$((TICKS + 1))
                if [ "$TICKS" -ge "$HIDE_TIMEOUT" ]; then
                    killall -9 waybar
                    TICKS=0
                fi
            else
                # Reset timer if mouse is hovering over the bar
                TICKS=0
            fi
        fi
    fi
    sleep 0.1
done
