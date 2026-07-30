#!/usr/bin/env bash
# Record Alt release and immediately commit the highlighted Rofi row.

set -u

RUNTIME_DIR="${ALTTAB_RUNTIME_DIR:-${XDG_RUNTIME_DIR:-/tmp}}"
BASE_PATH="${RUNTIME_DIR}/hypr-alttab-${UID}"
ACTIVE_FILE="${BASE_PATH}.active"
LOCK_FILE="${BASE_PATH}.lock"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_SCRIPT="${SCRIPT_DIR}/alttab_release.sh"
SESSION_DIR=""

# The controller publishes its session immediately after taking the lock. If
# release wins that tiny startup race, wait briefly for the session path rather
# than dropping the event.
exec 9>"$LOCK_FILE"
for _ in {1..40}; do
    if [ -r "$ACTIVE_FILE" ]; then
        read -r SESSION_DIR < "$ACTIVE_FILE" || true
        [ -n "$SESSION_DIR" ] && break
    fi

    # An available lock means no Alt-Tab controller is starting or running.
    flock -n 9 && exit 0
    sleep 0.005
done

case "$SESSION_DIR" in
    "${RUNTIME_DIR}/hypr-alttab-session-${UID}."*) ;;
    *) exit 0 ;;
esac
[ -d "$SESSION_DIR" ] || exit 0

rm -f -- "${SESSION_DIR}/held"
"$RELEASE_SCRIPT" "$SESSION_DIR"
