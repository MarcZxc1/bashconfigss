#!/usr/bin/env bash
# Leave maximize/fullscreen state, then force the active window into tiling.

set -u

fullscreen="$(hyprctl activewindow -j 2>/dev/null | jq -r '.fullscreen // 0')"

case "$fullscreen" in
    1)
        hyprctl eval \
            'hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "unset" }))' \
            >/dev/null 2>&1 || true
        ;;
    2)
        hyprctl eval \
            'hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "unset" }))' \
            >/dev/null 2>&1 || true
        ;;
    3)
        hyprctl eval '
            hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "unset" }))
            hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "unset" }))
        ' >/dev/null 2>&1 || true
        ;;
esac

hyprctl eval \
    'hl.dispatch(hl.dsp.window.float({ action = "unset" }))' \
    >/dev/null 2>&1 || true
