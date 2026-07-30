#!/usr/bin/env bash
# Track Rofi's highlighted row without switching while Alt remains held.

set -u

SESSION_DIR="${1:-}"
SELECTION="${2:-}"
RUNTIME_DIR="${ALTTAB_RUNTIME_DIR:-${XDG_RUNTIME_DIR:-/tmp}}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_SCRIPT="${SCRIPT_DIR}/alttab_release.sh"

case "$SESSION_DIR" in
    "${RUNTIME_DIR}/hypr-alttab-session-${UID}."*) ;;
    *) exit 0 ;;
esac
[ -d "$SESSION_DIR" ] || exit 0

# Rofi normally expands {entry} to the original row value (the address). The
# info field is a safe fallback and remains unique even for duplicate titles.
if [[ "$SELECTION" != 0x* ]] && [[ "${ROFI_INFO:-}" == 0x* ]]; then
    SELECTION="$ROFI_INFO"
fi
[[ "$SELECTION" == 0x* ]] || exit 0

SELECTION_FILE="${SESSION_DIR}/selection"
HELD_FILE="${SESSION_DIR}/held"
LOCK_FILE="${SESSION_DIR}/hover.lock"

# Serialize rapid keyboard/pointer changes and atomically publish only the
# latest highlighted address.
exec 9>"$LOCK_FILE"
flock 9
TOKEN="${BASHPID}-${RANDOM}"
SELECTION_TMP="${SESSION_DIR}/selection.tmp.${BASHPID}"
printf '%s\t%s\n' "$TOKEN" "$SELECTION" > "$SELECTION_TMP"
mv -f -- "$SELECTION_TMP" "$SELECTION_FILE"
flock -u 9

# Release normally commits through the modifier binding. This fallback covers
# a selection callback that arrives just after the held marker was removed.
if [ ! -f "$HELD_FILE" ]; then
    "$RELEASE_SCRIPT" "$SESSION_DIR"
fi

exit 0
