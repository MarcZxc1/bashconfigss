#!/usr/bin/env bash
# Toggle fullscreen/maximized, then keep the active window above other floating windows.

set -u

mode="${1:-0}"
case "$mode" in
    0|1) ;;
    *) exit 1 ;;
esac

address="$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')"

[ -n "$address" ] || exit 0
[[ "$address" == 0x* ]] || exit 0

if [ "$mode" = "0" ]; then
    fullscreen_mode="fullscreen"
else
    fullscreen_mode="maximized"
fi

hyprctl eval "
    hl.dispatch(hl.dsp.window.fullscreen({
        mode = \"$fullscreen_mode\",
        action = \"toggle\",
        window = \"address:${address}\",
    }))
" >/dev/null 2>&1 || exit 0

# Let Hyprland apply the fullscreen state before adjusting z-order.
sleep 0.03

hyprctl eval "
    hl.dispatch(hl.dsp.focus({ window = \"address:${address}\" }))
    hl.dispatch(hl.dsp.window.alter_zorder({
        mode = \"top\",
        window = \"address:${address}\",
    }))
    hl.dispatch(hl.dsp.window.bring_to_top())
" >/dev/null 2>&1 || true
