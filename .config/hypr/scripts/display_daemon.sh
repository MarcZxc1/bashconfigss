#!/usr/bin/env bash
# ==============================================================================
# Hyprland IPC Display Event Listener
# ==============================================================================

SCRIPT_PATH="$HOME/.config/hypr/scripts/display_manager.sh"

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    if [[ "$line" == "monitoradded>>"* ]]; then
        # Small delay to ensure the display is ready
        sleep 2
        "$SCRIPT_PATH" "Extend (External Primary)"
    elif [[ "$line" == "monitorremoved>>"* ]]; then
        "$SCRIPT_PATH" "Internal Only"
    fi
done
