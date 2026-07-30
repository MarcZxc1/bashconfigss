#!/usr/bin/env bash
# Regression checks for nested save/overwrite dialog focus behavior.

set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
RULES_FILE="${DIALOG_RULES_FILE:-${CONFIG_HOME}/hypr/lua/rules.lua}"
FOCUS_SCRIPT="${DIALOG_FOCUS_SCRIPT:-${CONFIG_HOME}/hypr/scripts/window_open_focus.sh}"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

rule_block() {
    local rule_name="$1"

    awk -v rule_name="$rule_name" '
        index($0, "name = \"" rule_name "\"") { found = 1 }
        found { print }
        found && /^})$/ { exit }
    ' "$RULES_FILE"
}

modal_rule="$(rule_block "modal-dialog-front")"
overwrite_rule="$(rule_block "file-overwrite-confirmation-front")"

[ -n "$modal_rule" ] || fail "modal dialog rule is missing"
[ -n "$overwrite_rule" ] || fail "overwrite confirmation rule is missing"

if grep -q 'stay_focused' <<<"$modal_rule"; then
    fail "the parent modal rule must not lock focus away from nested prompts"
fi

grep -q 'focus_on_activate = true' <<<"$modal_rule" \
    || fail "modal dialogs must still activate above their app"
grep -q 'Confirm Save' <<<"$overwrite_rule" \
    || fail "overwrite confirmation title fallback is missing"
if grep -q 'stay_focused' <<<"$overwrite_rule"; then
    fail "the overwrite confirmation must not trap pointer focus"
fi
grep -q 'focus_on_activate = true' <<<"$overwrite_rule" \
    || fail "the overwrite confirmation must honor activation"

grep -q '^is_file_dialog()' "$FOCUS_SCRIPT" \
    || fail "file-dialog detection is missing from the open-window listener"
grep -q 'move_dialog_to_workspace "$address" "$active_workspace"' "$FOCUS_SCRIPT" \
    || fail "file dialogs are not routed to their parent workspace"

printf 'PASS: nested save/overwrite dialog focus rules\n'
