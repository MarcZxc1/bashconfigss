#!/usr/bin/env bash

set -u

SIZE=24
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

theme_exists() {
    local theme="$1"
    [ -d "$HOME/.icons/$theme/cursors" ] ||
        [ -d "$HOME/.local/share/icons/$theme/cursors" ] ||
        [ -d "/usr/share/icons/$theme/cursors" ]
}

add_option() {
    local label="$1"
    local theme="$2"

    theme_exists "$theme" || return 0
    printf '%s\t%s\n' "$label" "$theme"
}

OPTIONS="$(
    add_option "󰆿  Bibata Ice (Modern)" "Bibata-Modern-Ice"
    add_option "󰆿  Bibata Amber" "Bibata-Modern-Amber"
    add_option "󰆿  Bibata Classic" "Bibata-Modern-Classic"
    add_option "󰆿  Adwaita" "Adwaita"
    add_option "󰆿  Breeze" "breeze_cursors"
)"

[ -n "$OPTIONS" ] || {
    notify-send -a "System" "Cursor Selector" "No cursor themes found."
    exit 1
}

chosen="$(
    printf '%s\n' "$OPTIONS" |
        cut -f1 |
        rofi -dmenu -i -p "Select Cursor" -config "$HOME/.config/rofi/config.rasi"
)"

[ -n "$chosen" ] || exit 0

theme="$(
    printf '%s\n' "$OPTIONS" |
        awk -F '\t' -v label="$chosen" '$1 == label {print $2; exit}'
)"

[ -n "$theme" ] || exit 1

gsettings set org.gnome.desktop.interface cursor-theme "$theme" >/dev/null 2>&1 || true
gsettings set org.gnome.desktop.interface cursor-size "$SIZE" >/dev/null 2>&1 || true

for gtk_settings in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
    [ -f "$gtk_settings" ] || continue
    if grep -q '^gtk-cursor-theme-name=' "$gtk_settings"; then
        sed -i "s/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$theme/" "$gtk_settings"
    else
        printf 'gtk-cursor-theme-name=%s\n' "$theme" >> "$gtk_settings"
    fi

    if grep -q '^gtk-cursor-theme-size=' "$gtk_settings"; then
        sed -i "s/^gtk-cursor-theme-size=.*/gtk-cursor-theme-size=$SIZE/" "$gtk_settings"
    else
        printf 'gtk-cursor-theme-size=%s\n' "$SIZE" >> "$gtk_settings"
    fi
done

hyprctl setcursor "$theme" "$SIZE" >/dev/null 2>&1 || true
hyprctl keyword env "XCURSOR_THEME,$theme" >/dev/null 2>&1 || true
hyprctl keyword env "XCURSOR_SIZE,$SIZE" >/dev/null 2>&1 || true
hyprctl keyword env "HYPRCURSOR_THEME,$theme" >/dev/null 2>&1 || true
hyprctl keyword env "HYPRCURSOR_SIZE,$SIZE" >/dev/null 2>&1 || true

if [ -w "$HYPR_CONF" ]; then
    sed -i \
        -e "s/^env = XCURSOR_THEME,.*/env = XCURSOR_THEME,$theme/" \
        -e "s/^env = XCURSOR_SIZE,.*/env = XCURSOR_SIZE,$SIZE/" \
        -e "s/^env = HYPRCURSOR_THEME,.*/env = HYPRCURSOR_THEME,$theme/" \
        -e "s/^env = HYPRCURSOR_SIZE,.*/env = HYPRCURSOR_SIZE,$SIZE/" \
        "$HYPR_CONF"
fi

notify-send -a "System" "Cursor Updated" "Theme set to $theme."
