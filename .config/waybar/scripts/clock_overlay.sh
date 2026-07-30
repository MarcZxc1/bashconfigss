#!/bin/bash

# Define the special workspace name
WORKSPACE="clock_popup"

# Function to check if the window exists
window_exists() {
    hyprctl clients -j | jq -e '.[] | select(.class == "org.gnome.clocks")' > /dev/null
}

# 1. Ensure gnome-clocks is at least running in daemon mode
if ! pgrep -x "gnome-clocks" > /dev/null; then
    gnome-clocks --gapplication-service &
    sleep 0.2
fi

# 2. Check if the window exists
if ! window_exists; then
    # Launch the UI
    gnome-clocks &
    
    # Wait for window to appear
    COUNT=0
    while ! window_exists && [ $COUNT -lt 20 ]; do
        sleep 0.1
        ((COUNT++))
    done
fi

# 3. Toggle visibility
# We use the special workspace toggle
hyprctl eval \
    "hl.dispatch(hl.dsp.workspace.toggle_special(\"$WORKSPACE\"))"
