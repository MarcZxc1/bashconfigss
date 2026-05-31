#!/usr/bin/env bash
# ==============================================================================
# Hyprland Advanced Display Manager (Alignment Aware Version)
# ==============================================================================

# 1. Dynamic Detection
MONITORS_JSON=$(hyprctl monitors all -j)
INTERNAL=$(echo "$MONITORS_JSON" | jq -r '.[] | select(.name | startswith("eDP")) | .name' | head -n 1)
[ -z "$INTERNAL" ] || [ "$INTERNAL" == "null" ] && INTERNAL="eDP-1"
EXTERNAL=$(echo "$MONITORS_JSON" | jq -r ".[] | select(.name != \"$INTERNAL\") | .name" | head -n 1)

if [[ -z "$EXTERNAL" || "$EXTERNAL" == "null" ]]; then
    notify-send "Display Manager" "No external display detected."
    hyprctl keyword monitor "$INTERNAL, preferred, auto, 1"
    exit 0
fi

# 2. STABLE CONFIGURATION
EXT_RES="1366x768@59.79" 
EXT_W=1366
EXT_H=768
INT_W=1366
INT_H=768

# Function to route workspaces correctly
route_workspaces() {
    local primary=$1
    local secondary=$2

    for i in {1..5}; do
        hyprctl keyword workspace "$i, monitor:$primary" > /dev/null
        hyprctl dispatch moveworkspacetomonitor "$i" "$primary" > /dev/null 2>&1
    done

    if [[ -n "$secondary" ]]; then
        for i in {6..10}; do
            hyprctl keyword workspace "$i, monitor:$secondary" > /dev/null
            hyprctl dispatch moveworkspacetomonitor "$i" "$secondary" > /dev/null 2>&1
        done
    fi
    hyprctl dispatch workspace 1 > /dev/null
}

apply_layout() {
    local mode=$1
    local align=$2
    local batch_cmd=""

    case "$mode" in
        "Internal Only")
            batch_cmd="keyword monitor $INTERNAL, preferred, 0x0, 1 ; keyword monitor $EXTERNAL, disable"
            route_workspaces "$INTERNAL" ""
            ;;
        "External Only")
            batch_cmd="keyword monitor $INTERNAL, disable ; keyword monitor $EXTERNAL, $EXT_RES, 0x0, 1"
            route_workspaces "$EXTERNAL" ""
            ;;
        "Mirror")
            batch_cmd="keyword monitor $INTERNAL, preferred, 0x0, 1 ; keyword monitor $EXTERNAL, $EXT_RES, 0x0, 1, mirror, $INTERNAL"
            route_workspaces "$INTERNAL" ""
            ;;
        "Extend")
            # Logic for mouse navigation based on alignment
            case "$align" in
                "External Right")
                    batch_cmd="keyword monitor $INTERNAL, preferred, 0x0, 1 ; keyword monitor $EXTERNAL, $EXT_RES, ${INT_W}x0, 1"
                    ;;
                "External Left")
                    batch_cmd="keyword monitor $EXTERNAL, $EXT_RES, 0x0, 1 ; keyword monitor $INTERNAL, preferred, ${EXT_W}x0, 1"
                    ;;
                "External Top")
                    batch_cmd="keyword monitor $EXTERNAL, $EXT_RES, 0x0, 1 ; keyword monitor $INTERNAL, preferred, 0x${EXT_H}, 1"
                    ;;
                "External Bottom")
                    batch_cmd="keyword monitor $INTERNAL, preferred, 0x0, 1 ; keyword monitor $EXTERNAL, $EXT_RES, 0x${INT_H}, 1"
                    ;;
            esac
            route_workspaces "$INTERNAL" "$EXTERNAL"
            ;;
    esac

    hyprctl --batch "$batch_cmd"
    
    # UI Refresh
    sleep 1
    # Refresh Wallpaper with awww
    if pgrep -x "awww-daemon" > /dev/null; then
        awww img "/home/marc/.config/hypr/arch1-wallpaper.png" > /dev/null
    fi
    # Force Waybar to restart and pick up new monitors
    killall waybar > /dev/null 2>&1
    sleep 0.5
    waybar > /dev/null 2>&1 &
    
    notify-send "Display Profile" "Applied: $mode ($align)"
}

# --- MENU SYSTEM ---
MAIN_OPTIONS="Extend\nMirror\nExternal Only\nInternal Only"
CHOICE=$(echo -e "$MAIN_OPTIONS" | rofi -dmenu -i -p "Mode:")

if [[ "$CHOICE" == "Extend" ]]; then
    ALIGN_OPTIONS="External Right\nExternal Left\nExternal Top\nExternal Bottom"
    ALIGN_CHOICE=$(echo -e "$ALIGN_OPTIONS" | rofi -dmenu -i -p "Where is the external monitor?")
    [[ -n "$ALIGN_CHOICE" ]] && apply_layout "Extend" "$ALIGN_CHOICE"
elif [[ -n "$CHOICE" ]]; then
    apply_layout "$CHOICE" "Standard"
fi
