#!/usr/bin/env bash
# Activate one Hyprland window without mutating its size or position.

set -u

ADDRESS="${1:-${ROFI_INFO:-}}"
[[ "$ADDRESS" == 0x* ]] || exit 1

# One fresh snapshot protects against selecting a window that closed while the
# menu was open. Workspace, focus, and z-order changes are then one synchronous
# compositor round trip.
CLIENTS_JSON="$(hyprctl clients -j 2>/dev/null)" || exit 1
TARGET_WORKSPACE="$(
    jq -er --arg address "$ADDRESS" \
        '.[] | select(.address == $address) | .workspace.id' <<< "$CLIENTS_JSON" \
        | head -n 1
)" || exit 1
[[ "$TARGET_WORKSPACE" =~ ^[0-9]+$ ]] || exit 1
(( TARGET_WORKSPACE > 0 )) || exit 1

hyprctl eval "
    hl.dispatch(hl.dsp.focus({ workspace = ${TARGET_WORKSPACE} }))
    hl.dispatch(hl.dsp.focus({ window = \"address:${ADDRESS}\" }))
    hl.dispatch(hl.dsp.window.alter_zorder({
        mode = \"top\",
        window = \"address:${ADDRESS}\",
    }))
" >/dev/null 2>&1
