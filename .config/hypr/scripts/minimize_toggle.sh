#!/bin/bash
# ~/.config/hypr/scripts/minimize_toggle.sh
# Restores the most recently minimized window OR minimizes the active one.

if [ "$1" == "minimize" ]; then
    hyprctl dispatch movetoworkspacesilent special:minimized
else
    # To restore, we bring the special workspace into view 
    # and then move the active window back to the previous workspace
    # Alternatively, use a script to find the last minimized window.
    # For now, we'll toggle the special workspace which is the standard method.
    hyprctl dispatch togglespecialworkspace minimized
fi
