#!/usr/bin/env bash
# ~/.config/hypr/scripts/minimize_toggle.sh
# Minimize to a hidden special workspace, then restore one window at a time.

set -u

SPECIAL_WS="special:minimized"
STACK_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_minimized_stack"

notify_user() {
    command -v notify-send >/dev/null 2>&1 || return 0
    notify-send -a Hyprland "$1" "$2"
}

get_clients() {
    hyprctl clients -j 2>/dev/null
}

current_workspace_id() {
    hyprctl activeworkspace -j 2>/dev/null | jq -r 'if (.id | type) == "number" and .id > 0 then .id else 1 end'
}

remove_from_stack() {
    local address="$1"
    local tmp

    [ -f "$STACK_FILE" ] || return 0
    tmp="${STACK_FILE}.$$"
    grep -vxF "$address" "$STACK_FILE" > "$tmp" 2>/dev/null || true
    mv "$tmp" "$STACK_FILE"
}

clean_stack() {
    local clients="$1"
    local tmp

    [ -f "$STACK_FILE" ] || return 0
    tmp="${STACK_FILE}.$$"

    while IFS= read -r address; do
        [ -n "$address" ] || continue
        if jq -e --arg address "$address" --arg ws "$SPECIAL_WS" \
            '.[] | select(.address == $address and .workspace.name == $ws)' \
            >/dev/null <<<"$clients"; then
            printf '%s\n' "$address"
        fi
    done < "$STACK_FILE" > "$tmp"

    mv "$tmp" "$STACK_FILE"
}

minimize_active() {
    local address

    address="$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')"
    if [ -z "$address" ] || [ "$address" = "null" ]; then
        notify_user "Nothing to minimize" "No active window is selected."
        exit 0
    fi

    mkdir -p "$(dirname "$STACK_FILE")"
    remove_from_stack "$address"
    printf '%s\n' "$address" >> "$STACK_FILE"
    hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS" >/dev/null
}

last_minimized_address() {
    local clients="$1"
    local address

    clean_stack "$clients"

    if [ -f "$STACK_FILE" ]; then
        while IFS= read -r address; do
            [ -n "$address" ] || continue
            if jq -e --arg address "$address" --arg ws "$SPECIAL_WS" \
                '.[] | select(.address == $address and .workspace.name == $ws)' \
                >/dev/null <<<"$clients"; then
                printf '%s\n' "$address"
                return 0
            fi
        done < <(tac "$STACK_FILE")
    fi

    jq -r --arg ws "$SPECIAL_WS" \
        '[.[] | select(.workspace.name == $ws)] | last.address // empty' \
        <<<"$clients"
}

float_like_windows() {
    local address="${1:-}"
    local width height target_width target_height

    if [ -z "$address" ] || ! hyprctl clients -j | jq -e --arg address "$address" \
        '.[] | select(.address == $address and .floating == true)' \
        >/dev/null; then
        hyprctl dispatch setfloating >/dev/null 2>&1 || true
    fi

    read -r width height < <(
        hyprctl monitors -j 2>/dev/null |
            jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"' |
            head -n 1
    )

    if [[ "${width:-}" =~ ^[0-9]+$ ]] && [[ "${height:-}" =~ ^[0-9]+$ ]]; then
        target_width=$((width * 92 / 100))
        target_height=$((height * 88 / 100))
        hyprctl dispatch resizeactive exact "$target_width" "$target_height" >/dev/null 2>&1 || true
    fi

    hyprctl dispatch centerwindow >/dev/null 2>&1 || true
}

activate_window() {
    local address="$1"

    hyprctl dispatch focuswindow "address:$address" >/dev/null
    hyprctl dispatch alterzorder "top,address:$address" >/dev/null 2>&1 || true
    hyprctl dispatch bringactivetotop >/dev/null 2>&1 || true
}

restore_last() {
    local clients address workspace

    clients="$(get_clients)" || {
        notify_user "Restore failed" "Could not read Hyprland windows."
        exit 1
    }

    address="$(last_minimized_address "$clients")"
    if [ -z "$address" ] || [ "$address" = "null" ]; then
        notify_user "No minimized windows" "There is nothing to restore."
        exit 0
    fi

    workspace="$(current_workspace_id)"
    hyprctl dispatch movetoworkspacesilent "$workspace,address:$address" >/dev/null
    activate_window "$address"
    float_like_windows "$address"
    activate_window "$address"
    remove_from_stack "$address"
}

case "${1:-restore}" in
    minimize)
        minimize_active
        ;;
    restore|toggle)
        restore_last
        ;;
    *)
        printf 'Usage: %s [minimize|restore]\n' "$0" >&2
        exit 2
        ;;
esac
