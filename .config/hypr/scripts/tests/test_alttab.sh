#!/usr/bin/env bash
# Mocked integration tests for the Rofi/Hyprland Alt-Tab state machine.

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MOCK_DIR="${SCRIPT_DIR}/tests/mocks"
TEST_ROOT="$(mktemp -d /tmp/hypr-alttab-tests.XXXXXX)"
ORIGINAL_PATH="$PATH"
PASS_COUNT=0

cleanup() {
    if [ "${KEEP_ALTTAB_TEST_ROOT:-0}" = "1" ]; then
        printf 'test artifacts kept at %s\n' "$TEST_ROOT" >&2
        return
    fi
    rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
    printf 'not ok - %s\n' "$1" >&2
    exit 1
}

pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    printf 'ok %d - %s\n' "$PASS_COUNT" "$1"
}

assert_contains() {
    local file="$1"
    local expected="$2"
    local message="$3"

    grep -aF -- "$expected" "$file" >/dev/null || fail "$message"
}

assert_not_contains() {
    local file="$1"
    local unexpected="$2"
    local message="$3"

    if grep -aF -- "$unexpected" "$file" >/dev/null; then
        fail "$message"
    fi
}

wait_for_file() {
    local file="$1"

    for _ in {1..300}; do
        [ -e "$file" ] && return 0
        sleep 0.01
    done
    fail "timed out waiting for $file"
}

wait_for_process() {
    local pid="$1"

    for _ in {1..300}; do
        kill -0 "$pid" 2>/dev/null || {
            wait "$pid" 2>/dev/null || true
            return 0
        }
        sleep 0.01
    done
    kill -TERM "$pid" 2>/dev/null || true
    fail "controller process $pid did not finish"
}

write_standard_clients() {
    local file="$1"

    printf '%s\n' '[
      {"address":"0xa","class":"Current","title":"Current window","mapped":true,"hidden":false,"workspace":{"id":1,"name":"1"},"focusHistoryID":0},
      {"address":"0xb","class":"Browser","title":"Duplicate title","mapped":true,"hidden":false,"workspace":{"id":1,"name":"1"},"focusHistoryID":1},
      {"address":"0xc","class":"Browser","title":"Duplicate title","mapped":true,"hidden":false,"workspace":{"id":2,"name":"2"},"focusHistoryID":2},
      {"address":"0xd","class":"Hidden","title":"Minimized","mapped":true,"hidden":false,"workspace":{"id":-99,"name":"special:minimized"},"focusHistoryID":3},
      {"address":"0xe","class":"Hidden","title":"Hidden group member","mapped":true,"hidden":true,"workspace":{"id":1,"name":"1"},"focusHistoryID":4}
    ]' > "$file"
}

new_case() {
    local name="$1"

    CASE_DIR="${TEST_ROOT}/${name}"
    mkdir -p "$CASE_DIR/runtime"
    export ALTTAB_RUNTIME_DIR="${CASE_DIR}/runtime"
    export MOCK_ACTIVE_JSON="${CASE_DIR}/active.json"
    export MOCK_CLIENTS_JSON="${CASE_DIR}/clients.json"
    export MOCK_HYPRCTL_LOG="${CASE_DIR}/hyprctl.log"
    export MOCK_ROFI_INPUT="${CASE_DIR}/rofi.input"
    export MOCK_ROFI_ARGS="${CASE_DIR}/rofi.args"
    export MOCK_ROFI_SELECTED_ROW="${CASE_DIR}/rofi.selected-row"
    export MOCK_ROFI_READY="${CASE_DIR}/rofi.ready"
    export MOCK_ROFI_EVENTS_DONE="${CASE_DIR}/rofi.events-done"
    export MOCK_HYPRCTL_DELAY=0
    export MOCK_EVAL_STATUS=0
    export PATH="${MOCK_DIR}:${ORIGINAL_PATH}"
    : > "$MOCK_HYPRCTL_LOG"
    printf '%s\n' '{"address":"0xa","workspace":{"id":1}}' > "$MOCK_ACTIVE_JSON"
    write_standard_clients "$MOCK_CLIENTS_JSON"
}

start_controller() {
    "$SCRIPT_DIR/smart_alttab.sh" "$@" &
    CONTROLLER_PID=$!
}

# Normal release: previous MRU is selected, hidden/minimized clients are absent,
# and release commits without waiting for the hover timeout.
new_case release
export MOCK_ROFI_BEHAVIOR=wait
export ALTTAB_HOVER_DELAY=1
start_controller
wait_for_file "$MOCK_ROFI_READY"
"$SCRIPT_DIR/alttab_modifier_release.sh"
wait_for_process "$CONTROLLER_PID"
assert_contains "$MOCK_HYPRCTL_LOG" 'address:0xb' 'Alt release did not activate previous MRU window'
assert_not_contains "$MOCK_ROFI_INPUT" '0xd' 'minimized window leaked into Rofi input'
assert_not_contains "$MOCK_ROFI_INPUT" '0xe' 'hidden window leaked into Rofi input'
[ "$(< "$MOCK_ROFI_SELECTED_ROW")" = "1" ] || fail 'previous MRU row was not initially selected'
pass 'release immediately commits the previous MRU window'

# Release before client discovery and Rofi startup must be remembered.
new_case early_release
export MOCK_ROFI_BEHAVIOR=wait
export MOCK_HYPRCTL_DELAY=0.08
export ALTTAB_HOVER_DELAY=1
start_controller
wait_for_file "${ALTTAB_RUNTIME_DIR}/hypr-alttab-${UID}.active"
"$SCRIPT_DIR/alttab_modifier_release.sh"
wait_for_process "$CONTROLLER_PID"
assert_contains "$MOCK_HYPRCTL_LOG" 'address:0xb' 'early Alt release was dropped'
pass 'release during startup is latched and committed after Rofi starts'

# Hovering updates the selection but must never activate while Alt is held.
# Duplicate display labels still resolve through the unique address row value.
new_case held_hover
export MOCK_ROFI_BEHAVIOR=hover
export MOCK_ROFI_SEQUENCE='0xb:0,0xc:0.03'
start_controller
wait_for_file "$MOCK_ROFI_EVENTS_DONE"
sleep 0.15
if grep -F -- 'eval ' "$MOCK_HYPRCTL_LOG" >/dev/null; then
    fail 'hover activated a window while Alt was still held'
fi
kill -0 "$CONTROLLER_PID" 2>/dev/null || fail 'Rofi closed while Alt was still held'
"$SCRIPT_DIR/alttab_modifier_release.sh"
wait_for_process "$CONTROLLER_PID"
assert_contains "$MOCK_HYPRCTL_LOG" 'address:0xc' 'latest hovered address was not activated'
EVAL_COUNT="$(grep -c -- '^eval ' "$MOCK_HYPRCTL_LOG" || true)"
[ "$EVAL_COUNT" = "1" ] || fail 'Alt release committed more than once'
pass 'hover only highlights while held; Alt release commits the latest row'

# Escape restores the original window.
new_case cancel
export MOCK_ROFI_BEHAVIOR=cancel
export ALTTAB_HOVER_DELAY=1
start_controller
wait_for_process "$CONTROLLER_PID"
assert_contains "$MOCK_HYPRCTL_LOG" 'address:0xa' 'Escape did not restore original window'
pass 'Escape restores the original window'

# Enter/click returns an address and activates it after Rofi exits.
new_case accept
export MOCK_ROFI_BEHAVIOR=accept
export MOCK_ROFI_SELECTION=0xc
export ALTTAB_HOVER_DELAY=1
start_controller
wait_for_process "$CONTROLLER_PID"
assert_contains "$MOCK_HYPRCTL_LOG" 'address:0xc' 'accepted row was not activated'
pass 'accepted Rofi row activates the selected window'

# Direct reverse launch starts at the oldest eligible row in the displayed
# cycle, then release commits it.
new_case reverse
export MOCK_ROFI_BEHAVIOR=wait
export ALTTAB_HOVER_DELAY=1
start_controller --reverse
wait_for_file "$MOCK_ROFI_READY"
"$SCRIPT_DIR/alttab_modifier_release.sh"
wait_for_process "$CONTROLLER_PID"
assert_contains "$MOCK_HYPRCTL_LOG" 'address:0xc' 'reverse launch did not select reverse row'
pass 'Alt+Shift+Tab can launch directly in reverse order'

# A placeholder/invalid PID can never claim or kill a process group.
new_case invalid_pid
SESSION_DIR="${ALTTAB_RUNTIME_DIR}/hypr-alttab-session-${UID}.manual"
mkdir "$SESSION_DIR"
printf '%s\t%s\n' token 0xb > "${SESSION_DIR}/selection"
printf '0\n' > "${SESSION_DIR}/rofi.pid"
(
    exec 7>"${ALTTAB_RUNTIME_DIR}/hypr-alttab-${UID}.lock"
    flock 7
    : > "${CASE_DIR}/lock.ready"
    sleep 1
) &
LOCK_HOLDER_PID=$!
wait_for_file "${CASE_DIR}/lock.ready"
"$SCRIPT_DIR/alttab_release.sh" "$SESSION_DIR"
kill -TERM "$LOCK_HOLDER_PID" 2>/dev/null || true
wait "$LOCK_HOLDER_PID" 2>/dev/null || true
[ ! -e "${SESSION_DIR}/committed" ] || fail 'PID 0 incorrectly claimed the session'
pass 'PID 0 is rejected before signaling or committing'

# With only the active client there is nothing to switch to, so Rofi should not
# flash and no focus dispatch should run.
new_case one_window
printf '%s\n' '[
  {"address":"0xa","class":"Current","title":"Only window","mapped":true,"hidden":false,"workspace":{"id":1,"name":"1"},"focusHistoryID":0}
]' > "$MOCK_CLIENTS_JSON"
export MOCK_ROFI_BEHAVIOR=wait
start_controller
wait_for_process "$CONTROLLER_PID"
[ ! -e "$MOCK_ROFI_READY" ] || fail 'Rofi opened with only one eligible window'
assert_not_contains "$MOCK_HYPRCTL_LOG" 'eval ' 'one-window no-op dispatched focus'
pass 'single-window Alt-Tab is a no-op'

printf '1..%d\n' "$PASS_COUNT"
