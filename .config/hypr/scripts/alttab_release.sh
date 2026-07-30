#!/usr/bin/env bash
# Atomically commit the current Alt-Tab selection and close its Rofi session.

set -u

SESSION_DIR="${1:-}"
RUNTIME_DIR="${ALTTAB_RUNTIME_DIR:-${XDG_RUNTIME_DIR:-/tmp}}"
BASE_PATH="${RUNTIME_DIR}/hypr-alttab-${UID}"
ACTIVE_FILE="${BASE_PATH}.active"
LOCK_FILE="${BASE_PATH}.lock"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ACTIVATE_SCRIPT="${SCRIPT_DIR}/alttab_activate.sh"

# A live controller owns this lock. Refuse stale session directories and PIDs
# left behind by an interrupted compositor/session instead of risking PID reuse.
exec 8>"$LOCK_FILE"
flock -n 8 && exit 0

if [ -z "$SESSION_DIR" ] && [ -r "$ACTIVE_FILE" ]; then
    read -r SESSION_DIR < "$ACTIVE_FILE" || true
fi
case "$SESSION_DIR" in
    "${RUNTIME_DIR}/hypr-alttab-session-${UID}."*) ;;
    *) exit 0 ;;
esac
[ -d "$SESSION_DIR" ] || exit 0

SELECTION_FILE="${SESSION_DIR}/selection"
PID_FILE="${SESSION_DIR}/rofi.pid"
COMMITTED_FILE="${SESSION_DIR}/committed"
CLAIM_DIR="${SESSION_DIR}/commit.claim"

[ -r "$SELECTION_FILE" ] || exit 0
[ -r "$PID_FILE" ] || exit 0
IFS=$'\t' read -r _ ADDRESS < "$SELECTION_FILE" || exit 0
read -r ROFI_PID < "$PID_FILE" || exit 0
[[ "$ADDRESS" == 0x* ]] || exit 0
[[ "$ROFI_PID" =~ ^[0-9]+$ ]] || exit 0
(( ROFI_PID > 1 )) || exit 0
kill -0 "$ROFI_PID" 2>/dev/null || exit 0

# mkdir is the atomic claim: Alt release and hover timeout cannot both win.
mkdir -- "$CLAIM_DIR" 2>/dev/null || exit 0
: > "$COMMITTED_FILE"

ACTIVE_SESSION=""
if [ -r "$ACTIVE_FILE" ]; then
    read -r ACTIVE_SESSION < "$ACTIVE_FILE" || true
    [ "$ACTIVE_SESSION" = "$SESSION_DIR" ] && rm -f -- "$ACTIVE_FILE"
fi

ORIGINAL_ADDRESS=""
[ -r "${SESSION_DIR}/original" ] && read -r ORIGINAL_ADDRESS < "${SESSION_DIR}/original" || true

kill -TERM "$ROFI_PID" 2>/dev/null || true
for _ in {1..100}; do
    kill -0 "$ROFI_PID" 2>/dev/null || break
    sleep 0.005
done

"$ACTIVATE_SCRIPT" "$ADDRESS" \
    || { [[ "$ORIGINAL_ADDRESS" == 0x* ]] && [ "$ORIGINAL_ADDRESS" != "$ADDRESS" ] \
        && "$ACTIVATE_SCRIPT" "$ORIGINAL_ADDRESS"; }

: > "${SESSION_DIR}/finished"
