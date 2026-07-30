#!/usr/bin/env bash
# Keep newly opened stacked apps inside the monitor work area and in front.

set -u

LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-window-open-focus.lock"
SOCKET="${XDG_RUNTIME_DIR:-/tmp}/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}/.socket2.sock"

exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

[ -S "$SOCKET" ] || exit 0

fit_to_workarea_if_needed() {
    local address="$1"
    local client monitor monitor_id
    local at_x at_y win_w win_h fullscreen floating
    local mon_x mon_y mon_w mon_h res_l res_t res_r res_b
    local work_x work_y work_w work_h

    client="$(hyprctl clients -j 2>/dev/null | jq -c --arg address "$address" '.[] | select(.address == $address)' | head -n 1)"
    [ -n "$client" ] || return 0

    floating="$(jq -r '.floating' <<<"$client")"
    fullscreen="$(jq -r '.fullscreen' <<<"$client")"

    [ "$floating" = "true" ] || return 0
    [ "${fullscreen:-0}" = "0" ] || return 0

    monitor_id="$(jq -r '.monitor' <<<"$client")"
    read -r at_x at_y win_w win_h < <(jq -r '"\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"' <<<"$client")

    monitor="$(hyprctl monitors -j 2>/dev/null | jq -c --argjson id "$monitor_id" '.[] | select(.id == $id)' | head -n 1)"
    [ -n "$monitor" ] || return 0

    read -r mon_x mon_y mon_w mon_h res_l res_t res_r res_b < <(
        jq -r '"\(.x) \(.y) \(.width) \(.height) \(.reserved[0]) \(.reserved[1]) \(.reserved[2]) \(.reserved[3])"' <<<"$monitor"
    )

    work_x=$((mon_x + res_l))
    work_y=$((mon_y + res_t))
    work_w=$((mon_w - res_l - res_r))
    work_h=$((mon_h - res_t - res_b))

    if (( win_w * 100 >= mon_w * 90 && win_h * 100 >= mon_h * 85 )); then
        hyprctl eval "
            hl.dispatch(hl.dsp.window.resize({
                x = $work_w,
                y = $work_h,
                relative = false,
                window = \"address:${address}\",
            }))
            hl.dispatch(hl.dsp.window.move({
                x = $work_x,
                y = $work_y,
                relative = false,
                window = \"address:${address}\",
            }))
        " >/dev/null 2>&1 || true
        return 0
    fi

    if (( at_x < work_x || at_y < work_y || at_x + win_w > work_x + work_w || at_y + win_h > work_y + work_h )); then
        hyprctl eval "
            hl.dispatch(hl.dsp.window.move({
                x = $work_x,
                y = $work_y,
                relative = false,
                window = \"address:${address}\",
            }))
        " >/dev/null 2>&1 || true
    fi
}

has_large_blocker() {
    local address="$1"
    local clients new monitor monitor_id ws_id mon_w mon_h

    clients="$(hyprctl clients -j 2>/dev/null)" || return 1
    new="$(jq -c --arg address "$address" '.[] | select(.address == $address)' <<<"$clients" | head -n 1)"
    [ -n "$new" ] || return 1

    ws_id="$(jq -r '.workspace.id' <<<"$new")"
    monitor_id="$(jq -r '.monitor' <<<"$new")"
    monitor="$(hyprctl monitors -j 2>/dev/null | jq -c --argjson id "$monitor_id" '.[] | select(.id == $id)' | head -n 1)"
    [ -n "$monitor" ] || return 1
    read -r mon_w mon_h < <(jq -r '"\(.width) \(.height)"' <<<"$monitor")

    jq -e \
        --arg address "$address" \
        --argjson ws "$ws_id" \
        --argjson mon_w "$mon_w" \
        --argjson mon_h "$mon_h" \
        '.[] | select(
            .address != $address
            and .workspace.id == $ws
            and .mapped == true
            and .hidden == false
            and .floating == true
            and (
                ((.fullscreen // 0) != 0)
                or ((.size[0] * 100) >= ($mon_w * 90) and (.size[1] * 100) >= ($mon_h * 85))
            )
        )' <<<"$clients" >/dev/null
}

is_file_dialog() {
    local client="$1"
    local title initial_title class initial_class

    title="$(jq -r '.title // ""' <<<"$client")"
    initial_title="$(jq -r '.initialTitle // ""' <<<"$client")"
    class="$(jq -r '.class // ""' <<<"$client")"
    initial_class="$(jq -r '.initialClass // ""' <<<"$client")"

    [[ "$title" =~ ^(Save([[:space:]]File|[[:space:]]As)?|Open([[:space:]]File)?|Select[[:space:]]a[[:space:]]File|Choose[[:space:]]File|Confirm[[:space:]]Save([[:space:]]As)?|Replace[[:space:]]File|File[[:space:]]Already[[:space:]]Exists)$ ]] \
        || [[ "$initial_title" =~ ^(Save([[:space:]]File|[[:space:]]As)?|Open([[:space:]]File)?|Select[[:space:]]a[[:space:]]File|Choose[[:space:]]File|Confirm[[:space:]]Save([[:space:]]As)?|Replace[[:space:]]File|File[[:space:]]Already[[:space:]]Exists)$ ]] \
        || [[ "$class" =~ ^(xdg-desktop-portal-gtk|org\.freedesktop\.impl\.portal\.desktop\.gtk)$ ]] \
        || [[ "$initial_class" =~ ^(xdg-desktop-portal-gtk|org\.freedesktop\.impl\.portal\.desktop\.gtk)$ ]]
}

move_dialog_to_workspace() {
    local address="$1"
    local workspace="$2"

    [[ "$workspace" =~ ^[0-9]+$ ]] || return 0
    (( workspace > 0 )) || return 0

    hyprctl eval "
        hl.dispatch(hl.dsp.window.move({
            workspace = $workspace,
            follow = false,
            window = \"address:${address}\",
        }))
    " >/dev/null 2>&1 || true
}

handle_openwindow() {
    local payload="$1"
    local address="${payload%%,*}" client active_workspace

    [ -n "$address" ] || return 0
    [[ "$address" == 0x* ]] || address="0x${address}"

    active_workspace="$(hyprctl activeworkspace -j 2>/dev/null \
        | jq -r 'if (.id | type) == "number" and .id > 0 then .id else empty end')"

    sleep 0.12

    client="$(hyprctl clients -j 2>/dev/null | jq -c --arg address "$address" \
        '.[] | select(.address == $address)' | head -n 1)"
    [ -n "$client" ] || return 0
    [ "$(jq -r '.floating' <<<"$client")" = "true" ] || return 0

    if is_file_dialog "$client"; then
        move_dialog_to_workspace "$address" "$active_workspace"
    fi

    hyprctl eval "
        hl.dispatch(hl.dsp.focus({ window = \"address:${address}\" }))
    " >/dev/null 2>&1 || return 0
    fit_to_workarea_if_needed "$address"
    hyprctl eval "
        hl.dispatch(hl.dsp.window.alter_zorder({
            mode = \"top\",
            window = \"address:${address}\",
        }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    " >/dev/null 2>&1 || true
}

socat -U - "UNIX-CONNECT:${SOCKET}" | while IFS= read -r line; do
    case "$line" in
        openwindow\>\>*) handle_openwindow "${line#openwindow>>}" ;;
    esac
done
