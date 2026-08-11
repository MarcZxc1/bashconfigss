#!/usr/bin/env bash
set -euo pipefail

find_hwmon() {
    local d name
    for d in /sys/class/hwmon/hwmon*; do
        [[ -r "$d/name" ]] || continue
        name="$(<"$d/name")"
        if [[ "$name" == "dell_smm" ]]; then
            printf '%s\n' "$d"
            return 0
        fi
    done
    return 1
}

read_status() {
    local hwmon="$1"
    local mode pwm rpm t1 t2 t3 t4
    mode="$(<"$hwmon/pwm1_enable")"
    pwm="$(<"$hwmon/pwm1")"
    rpm="$(<"$hwmon/fan1_input")"
    t1="$(<"$hwmon/temp1_input")"
    t2="$(<"$hwmon/temp2_input")"
    t3="$(<"$hwmon/temp3_input")"
    t4="$(<"$hwmon/temp4_input")"
    printf 'mode=%s pwm=%s rpm=%s temp1=%s temp2=%s temp3=%s temp4=%s\n' "$mode" "$pwm" "$rpm" "$t1" "$t2" "$t3" "$t4"
}

show_feedback() {
    local title="$1"
    local message="$2"

    if ! notify-send -a "Fan Control" "$title" "$message"; then
        rofi -e "$message"
    fi
}

if ! command -v rofi >/dev/null 2>&1; then
    echo "rofi is not installed" >&2
    exit 1
fi

hwmon="$(find_hwmon)" || {
    show_feedback "Fan Control" "Dell fan hwmon not found"
    exit 1
}

status="$(read_status "$hwmon")"
mode_value="${status%% *}"
mode_value="${mode_value#mode=}"
current_pwm="${status#*pwm=}"
current_pwm="${current_pwm%% *}"
current_rpm="${status#*rpm=}"
current_rpm="${current_rpm%% *}"

case "$mode_value" in
    0) current_mode="auto" ;;
    1) current_mode="firmware/temporary" ;;
    *) current_mode="unknown" ;;
esac

set +e
choice="$(
    printf '%s\n' \
        "Automatic (firmware default)" \
        "Quiet (temporary)" \
        "Balanced (temporary)" \
        "Cool (temporary)" \
        "Max Cooling (temporary)" \
        | rofi -dmenu -i -p "Fan: ${current_mode} ${current_pwm} / ${current_rpm} RPM" -config "$HOME/.config/rofi/config.rasi"
)"
rofi_status=$?
set -e

if (( rofi_status != 0 )); then
    exit 0
fi

case "$choice" in
    "Automatic (firmware default)") target=auto ;;
    "Quiet (temporary)") target=quiet ;;
    "Balanced (temporary)") target=balanced ;;
    "Cool (temporary)") target=cool ;;
    "Max Cooling (temporary)") target=max ;;
    *) exit 0 ;;
esac

if pkexec /usr/local/libexec/dell-fan-profile "$target"; then
    after="$(read_status "$hwmon")"
    after_mode="${after%% *}"
    after_mode="${after_mode#mode=}"
    after_pwm="${after#*pwm=}"
    after_pwm="${after_pwm%% *}"
    after_rpm="${after#*rpm=}"
    after_rpm="${after_rpm%% *}"
    after_temp1="${after#*temp1=}"
    after_temp1="${after_temp1%% *}"
    after_temp2="${after#*temp2=}"
    after_temp2="${after_temp2%% *}"
    after_temp3="${after#*temp3=}"
    after_temp3="${after_temp3%% *}"
    after_temp4="${after##*temp4=}"
    show_feedback "Fan Control" "Applied ${target}: mode=${after_mode} pwm=${after_pwm} rpm=${after_rpm} t1=${after_temp1} t2=${after_temp2} t3=${after_temp3} t4=${after_temp4}"
else
    show_feedback "Fan Control" "Fan change was cancelled or denied"
fi
