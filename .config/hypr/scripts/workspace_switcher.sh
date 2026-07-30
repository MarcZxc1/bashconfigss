#!/usr/bin/env bash
# Compact Rofi selector for existing Hyprland workspaces.

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
lock_file="${runtime_dir}/hypr-workspace-switcher-${UID}.lock"
hover_script="${HOME}/.config/hypr/scripts/workspace_hover_select.sh"
active_session="${runtime_dir}/hypr-workspace-active-${UID}"
session_id="$$-${RANDOM}-$(date +%s%N)"

exec 9>"$lock_file"
flock -n 9 || exit 0
input_file="$(mktemp "${runtime_dir}/hypr-workspaces.XXXXXX")"
state_file="$(mktemp "${runtime_dir}/hypr-workspaces-hover.XXXXXX")"
hold_file="$(mktemp "${runtime_dir}/hypr-workspaces-held.XXXXXX")"
control_file="${input_file}.control"
output_file="${input_file}.output"
rofi_pid=""

# Keep Rofi's action command parseable when a workspace title contains shell
# quote characters. These substitutions only affect the displayed label.
sanitize_label() {
    local value="$1"

    value="${value//\\/∖}"
    value="${value//\"/″}"
    printf '%s' "$value"
}

cleanup() {
    local current_session=""

    if [ -r "$active_session" ]; then
        IFS=$'\t' read -r current_session _ < "$active_session" || true
        [ "$current_session" = "$session_id" ] && rm -f "$active_session"
    fi

    if [[ "$rofi_pid" =~ ^[0-9]+$ ]] && kill -0 "$rofi_pid" 2>/dev/null; then
        kill -TERM "$rofi_pid" 2>/dev/null || true
    fi
    rm -f "$input_file" "$state_file" "$hold_file" "$control_file" "$output_file"
}
trap cleanup EXIT

active_workspace="$(hyprctl activeworkspace -j | jq -r '.id')"

hyprctl workspaces -j | jq -r --argjson active "$active_workspace" '
    [.[] | select(.id > 0)]
    | sort_by([.id != $active, .id])
    | .[]
    | [(.id | tostring), (.windows | tostring), (.lastwindowtitle // "")]
    | @tsv
' | while IFS=$'\t' read -r id windows title; do
    title="$(sanitize_label "$title")"
    short="${title:0:52}"
    printf '%s\0display\x1f  Workspace %s  ·  %s window(s)  ·  %s\x1ficon\x1fview-grid-symbolic\n' \
        "$id" "$id" "$windows" "$short"
done > "$input_file"

"$hover_script" "$state_file" "$hold_file" "$control_file" "$active_workspace"
printf '%s\t%s\n' "$session_id" "$hold_file" > "$active_session"

rofi -dmenu -i \
    -theme ~/.config/rofi/alttab.rasi \
    -show-icons \
    -hover-select \
    -on-selection-changed "$hover_script $state_file $hold_file $control_file \"{entry}\"" \
    -no-custom \
    -p "" \
    -selected-row 0 \
    -kb-row-down "Super+Tab,Tab,Down,Control+n" \
    -kb-row-up "Super+ISO_Left_Tab,ISO_Left_Tab,Up,Control+p" \
    -kb-element-next "" \
    -kb-element-prev "" < "$input_file" > "$output_file" &
rofi_pid=$!
printf '%s\n' "$rofi_pid" > "$control_file"

wait "$rofi_pid" 2>/dev/null || true
selected="$(< "$output_file")"

[[ "$selected" =~ ^[0-9]+$ ]] || exit 0
hyprctl eval \
    "hl.dispatch(hl.dsp.focus({ workspace = $selected }))" >/dev/null
