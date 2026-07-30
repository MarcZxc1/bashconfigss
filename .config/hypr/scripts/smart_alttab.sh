#!/usr/bin/env bash
# Rofi Alt-Tab controller with MRU ordering and release/hover commit handling.

set -u

RUNTIME_DIR="${ALTTAB_RUNTIME_DIR:-${XDG_RUNTIME_DIR:-/tmp}}"
BASE_PATH="${RUNTIME_DIR}/hypr-alttab-${UID}"
LOCK_FILE="${BASE_PATH}.lock"
ACTIVE_FILE="${BASE_PATH}.active"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
ACTIVATE_SCRIPT="${SCRIPT_DIR}/alttab_activate.sh"
HOVER_SCRIPT="${SCRIPT_DIR}/alttab_hover_preview.sh"
RELEASE_SCRIPT="${SCRIPT_DIR}/alttab_release.sh"
THEME_FILE="${ALTTAB_THEME:-${CONFIG_HOME}/rofi/alttab.rasi}"
MINIMIZED_WS="special:minimized"
REVERSE=0

[ "${1:-}" = "--reverse" ] && REVERSE=1

# Repeated presses are delivered to the existing Rofi instance by bindn. Only
# the first press owns the controller lock and creates a session.
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

SESSION_DIR="$(mktemp -d "${RUNTIME_DIR}/hypr-alttab-session-${UID}.XXXXXX")" || exit 1
SESSION_ID="${SESSION_DIR##*.}"
ACTIVE_JSON="${SESSION_DIR}/active.json"
CLIENTS_JSON="${SESSION_DIR}/clients.json"
MENU_ROWS="${SESSION_DIR}/rows.tsv"
ROFI_INPUT="${SESSION_DIR}/rofi.input"
ROFI_OUTPUT="${SESSION_DIR}/rofi.output"
SELECTION_FILE="${SESSION_DIR}/selection"
HELD_FILE="${SESSION_DIR}/held"
PID_FILE="${SESSION_DIR}/rofi.pid"
COMMITTED_FILE="${SESSION_DIR}/committed"
FINISHED_FILE="${SESSION_DIR}/finished"
ROFI_PID=""

cleanup() {
    local active_session=""

    if [[ "$ROFI_PID" =~ ^[0-9]+$ ]] && (( ROFI_PID > 1 )) \
        && kill -0 "$ROFI_PID" 2>/dev/null; then
        kill -TERM "$ROFI_PID" 2>/dev/null || true
    fi

    if [ -r "$ACTIVE_FILE" ]; then
        read -r active_session < "$ACTIVE_FILE" || true
        [ "$active_session" = "$SESSION_DIR" ] && rm -f -- "$ACTIVE_FILE"
    fi

    rmdir -- "${SESSION_DIR}/commit.claim" 2>/dev/null || true
    rm -f -- "$ACTIVE_JSON" "$CLIENTS_JSON" "$MENU_ROWS" "$ROFI_INPUT" \
        "$ROFI_OUTPUT" "$SELECTION_FILE" "$HELD_FILE" "$PID_FILE" \
        "$COMMITTED_FILE" "$FINISHED_FILE" "${SESSION_DIR}/hover.lock" \
        "${SESSION_DIR}/original" "${SESSION_DIR}/selection.tmp."* \
        2>/dev/null || true
    rmdir -- "$SESSION_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# Publish the session before any compositor queries. An Alt release occurring
# during menu construction removes the held marker and is committed as soon as
# the real Rofi PID and initial selection are available.
: > "$HELD_FILE"
ACTIVE_TMP="${ACTIVE_FILE}.${SESSION_ID}"
printf '%s\n' "$SESSION_DIR" > "$ACTIVE_TMP"
mv -f -- "$ACTIVE_TMP" "$ACTIVE_FILE"

hyprctl activewindow -j > "$ACTIVE_JSON" 2>/dev/null || exit 1
hyprctl clients -j > "$CLIENTS_JSON" 2>/dev/null || exit 1

IFS=$'\t' read -r ORIGINAL_ADDRESS ACTIVE_WS < <(
    jq -r '[.address // "", (.workspace.id // 0 | tostring)] | @tsv' "$ACTIVE_JSON"
)
[[ "$ACTIVE_WS" =~ ^-?[0-9]+$ ]] || ACTIVE_WS=0
printf '%s\n' "$ORIGINAL_ADDRESS" > "${SESSION_DIR}/original"

# Generate every menu row from one immutable client snapshot. This keeps MRU
# selection, row ordering, and row indices internally consistent.
jq -r \
    --arg active "$ORIGINAL_ADDRESS" \
    --arg minimized_ws "$MINIMIZED_WS" \
    --argjson active_ws "$ACTIVE_WS" \
    --argjson reverse "$REVERSE" '
    def rank:
        if ((.focusHistoryID // -1) >= 0)
        then .focusHistoryID
        else 2147483647
        end;
    [.[] | select(.mapped == true and .hidden == false
                  and .workspace.id > 0
                  and .workspace.name != $minimized_ws)] as $eligible |
    ($eligible | map(select(.address != $active)) | sort_by(rank)) as $choices |
    (if ($choices | length) == 0 then ""
     elif $reverse == 1 then $choices[-1].address
     else $choices[0].address end) as $initial |
    ($eligible | map(select(.workspace.id == $active_ws)) | sort_by(rank)) as $current |
    ($eligible | map(select(.workspace.id != $active_ws)) | sort_by(rank)) as $other |
    ($current[] |
        ["window", .address, (.class // ""), (.title // ""),
         (.workspace.id | tostring), (.address == $initial | tostring)] | @tsv),
    (if ($other | length) > 0
     then ["separator", "SEP", "", "", "", "false"] | @tsv
     else empty end),
    ($other[] |
        ["window", .address, (.class // ""), (.title // ""),
         (.workspace.id | tostring), (.address == $initial | tostring)] | @tsv)
' "$CLIENTS_JSON" > "$MENU_ROWS" || exit 1

sanitize_label() {
    local value="$1"

    value="${value//\\/∖}"
    value="${value//\"/″}"
    printf '%s' "$value"
}

ROFI_ROW=0
INITIAL_ROW=0
INITIAL_ADDRESS=""
FIRST_ADDRESS=""
WINDOW_COUNT=0

while IFS=$'\t' read -r kind address icon title workspace_id is_initial; do
    if [ "$kind" = "separator" ]; then
        printf 'SEP\0display\x1f%s\x1fnonselectable\x1ftrue\n' \
            '─── other workspaces ───'
        ((ROFI_ROW += 1))
        continue
    fi

    [[ "$address" == 0x* ]] || continue
    icon="$(sanitize_label "$icon")"
    title="$(sanitize_label "$title")"
    [ -n "$FIRST_ADDRESS" ] || FIRST_ADDRESS="$address"
    ((WINDOW_COUNT += 1))

    if [ "$workspace_id" = "$ACTIVE_WS" ]; then
        display_text="  ${icon}  ·  ${title:0:60}"
    else
        display_text="  [${workspace_id}]  ${icon}  ·  ${title:0:45}"
    fi

    printf '%s\0display\x1f%s\x1finfo\x1f%s\x1ficon\x1f%s\n' \
        "$address" "$display_text" "$address" "$icon"

    if [ "$is_initial" = "true" ]; then
        INITIAL_ROW=$ROFI_ROW
        INITIAL_ADDRESS="$address"
    fi
    ((ROFI_ROW += 1))
done < "$MENU_ROWS" > "$ROFI_INPUT"

# With no alternative window, Alt-Tab is a no-op and no selector flashes.
if (( WINDOW_COUNT < 2 )) && [[ "$ORIGINAL_ADDRESS" == 0x* ]]; then
    exit 0
fi

if [ -z "$INITIAL_ADDRESS" ]; then
    INITIAL_ADDRESS="$FIRST_ADDRESS"
    INITIAL_ROW=0
fi
[ -n "$INITIAL_ADDRESS" ] || exit 0

SELECTION_TMP="${SESSION_DIR}/selection.tmp.$$"
printf '%s\t%s\n' "initial-${SESSION_ID}" "$INITIAL_ADDRESS" > "$SELECTION_TMP"
mv -f -- "$SELECTION_TMP" "$SELECTION_FILE"

# Publish the initially highlighted MRU row. Hover changes update this state,
# but never activate a window while Alt remains held.
"$HOVER_SCRIPT" "$SESSION_DIR" "$INITIAL_ADDRESS"

rofi -dmenu -i \
    -theme "$THEME_FILE" \
    -show-icons \
    -hover-select \
    -on-selection-changed "$HOVER_SCRIPT \"$SESSION_DIR\" \"{entry}\"" \
    -kb-row-down "Alt+Tab,Tab,Down,Control+n" \
    -kb-row-up "Alt+ISO_Left_Tab,ISO_Left_Tab,Up,Control+p" \
    -kb-element-next "" \
    -kb-element-prev "" \
    -no-custom \
    -p "" \
    -selected-row "$INITIAL_ROW" < "$ROFI_INPUT" > "$ROFI_OUTPUT" &
ROFI_PID=$!
printf '%s\n' "$ROFI_PID" > "$PID_FILE"

# Close the startup race: if Alt was released while the list was being built,
# commit now that both the selection and real Rofi PID exist.
if [ ! -f "$HELD_FILE" ]; then
    "$RELEASE_SCRIPT" "$SESSION_DIR"
fi

ROFI_STATUS=0
wait "$ROFI_PID" 2>/dev/null || ROFI_STATUS=$?

# Release/hover commits mark the session before terminating Rofi. Wait for the
# committing worker to finish activation so cleanup cannot race the final IPC.
if [ -f "$COMMITTED_FILE" ]; then
    for _ in {1..200}; do
        [ -f "$FINISHED_FILE" ] && break
        sleep 0.005
    done
    exit 0
fi

SELECTED=""
[ -r "$ROFI_OUTPUT" ] && IFS= read -r SELECTED < "$ROFI_OUTPUT" || true

if (( ROFI_STATUS == 0 )) && [[ "$SELECTED" == 0x* ]]; then
    "$ACTIVATE_SCRIPT" "$SELECTED" \
        || { [[ "$ORIGINAL_ADDRESS" == 0x* ]] && "$ACTIVATE_SCRIPT" "$ORIGINAL_ADDRESS"; }
else
    # Escape or an unexpected Rofi exit restores the pre-switch window.
    [[ "$ORIGINAL_ADDRESS" == 0x* ]] && "$ACTIVATE_SCRIPT" "$ORIGINAL_ADDRESS" || true
fi
