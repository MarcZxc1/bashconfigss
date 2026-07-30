#!/usr/bin/env bash
# Mark Super as released; the one-second stable-selection timer may then commit.

set -u

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
active_session="${runtime_dir}/hypr-workspace-active-${UID}"

[ -r "$active_session" ] || exit 0
IFS=$'\t' read -r _ hold_file < "$active_session" || exit 0
[ -n "$hold_file" ] || exit 0
rm -f "$hold_file"
