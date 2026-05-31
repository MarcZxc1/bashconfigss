#!/bin/bash
# Event-driven Display Hot-Plugging Daemon for Hyprland
# Listens to the Hyprland IPC socket and triggers display_manager.sh

handle() {
  # The input line is from the IPC socket.
  # e.g., "monitoradded>>DP-1" or "monitorremoved>>DP-1"
  
  if [[ ${1:0:12} == "monitoradded" ]]; then
    echo "Monitor connected. Triggering Auto-Extend..."
    # Add a small sleep to ensure the display is fully initialized by the GPU driver
    sleep 2
    ~/.config/hypr/scripts/display_manager.sh --auto-extend
    
  elif [[ ${1:0:14} == "monitorremoved" ]]; then
    echo "Monitor disconnected. Triggering Auto-Internal..."
    ~/.config/hypr/scripts/display_manager.sh --auto-internal
  fi
}

echo "Starting Hyprland Hot-Plug Daemon..."

# Continuously read from the Hyprland IPC socket using socat
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
