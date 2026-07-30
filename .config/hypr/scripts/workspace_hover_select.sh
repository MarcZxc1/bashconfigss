#!/usr/bin/env bash
# Commit a Rofi workspace row after it remains selected for the hover delay.

set -u

state_file="${1:-}"
hold_file="${2:-}"
control_file="${3:-}"
selection="${4:-}"
workspace=""
delay="${WORKSPACE_HOVER_DELAY:-1}"

[ -f "$state_file" ] || exit 0

if [[ "$selection" =~ ^[0-9]+$ ]]; then
    workspace="$selection"
elif [[ "$selection" =~ ^[[:space:]]*Workspace[[:space:]]+([0-9]+)([[:space:]]|$) ]]; then
    workspace="${BASH_REMATCH[1]}"
fi

[[ "$workspace" =~ ^[0-9]+$ ]] || exit 0

token="$$-${RANDOM}-$(date +%s%N)"
printf '%s\t%s\n' "$token" "$workspace" > "$state_file"

(
    sleep "$delay"

    [ -f "$state_file" ] || exit 0
    IFS=$'\t' read -r current_token current_workspace < "$state_file" || exit 0
    [ "$current_token" = "$token" ] || exit 0
    [ "$current_workspace" = "$workspace" ] || exit 0

    # Do not commit while Super remains held. A different highlighted row
    # invalidates this timer even while it is waiting for Super's release.
    while [ -f "$hold_file" ]; do
        sleep 0.05
        [ -f "$state_file" ] || exit 0
        IFS=$'\t' read -r current_token current_workspace < "$state_file" || exit 0
        [ "$current_token" = "$token" ] || exit 0
        [ "$current_workspace" = "$workspace" ] || exit 0
    done

    rofi_pid=""
    if [ -r "$control_file" ]; then
        read -r rofi_pid < "$control_file" || true
    fi

    if [[ "$rofi_pid" =~ ^[0-9]+$ ]]; then
        kill -TERM "$rofi_pid" 2>/dev/null || true
        for _ in {1..100}; do
            kill -0 "$rofi_pid" 2>/dev/null || break
            sleep 0.01
        done
    fi

    sleep 0.05
    hyprctl eval \
        "hl.dispatch(hl.dsp.focus({ workspace = $workspace }))" \
        >/dev/null 2>&1 || true
) >/dev/null 2>&1 &

exit 0
