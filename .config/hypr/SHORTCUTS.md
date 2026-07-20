# Hyprland Windows-like Setup Manual

This manual covers the shortcuts and features of your Windows-inspired Hyprland environment.

**The `Super` key is the Windows key or Meta key.**

## Core Apps

| Shortcut | Action |
| :--- | :--- |
| `Super` + `Q` | Open terminal (`kitty`) |
| `Super` + `K` | Open terminal (`kitty`) |
| `Super` + `E` | Open file manager (`thunar`) |
| `Super` + `R` | Open app launcher (`rofi -show drun`) |
| `Super` + `B` | Open Brave Origin Nightly |
| `Super` + `D` | Open Discord |
| `Super` + `X` | Open power menu |
| `Super` + `L` | Lock session |

## System Tools

| Shortcut | Action |
| :--- | :--- |
| `Super` + `W` | Toggle Waybar visibility |
| `Super` + `G` | Run sleep animation |
| `Super` + `N` | Toggle night mode |
| `Super` + `P` | Open display manager |
| `Super` + `J` | Open cursor selector |
| `Super` + `Shift` + `F` | Open fan control menu |

Fan menu states:
- `Auto (BIOS)` returns fan behavior to firmware control.
- `Quiet`, `Balanced`, `Cool`, and `Max Cooling` try manual PWM and report mode, PWM, RPM, and temperatures in a notification.

## Window Management

| Shortcut | Action |
| :--- | :--- |
| `Super` + `C` | Close active window |
| `Super` + `F` | Toggle floating/tiled mode |
| `Super` + `Shift` + `Space` | Force the active window into tiled mode |
| `Super` + `M` | Toggle fullscreen |
| `Super` + `Shift` + `M` | Toggle fake fullscreen/maximize |
| `Super` + `H` | Hide active window to `special:minimized` |
| `Super` + `Shift` + `H` | Restore last hidden window |
| `Super` + `T` | Toggle scratchpad workspace |
| `Super` + `Shift` + `T` | Move active window to scratchpad |

## Focus And Movement

| Shortcut | Action |
| :--- | :--- |
| `Super` + `Left` | Focus window to the left |
| `Super` + `Right` | Focus window to the right |
| `Super` + `Up` | Focus window above |
| `Super` + `Down` | Focus window below |
| `Super` + `Shift` + `Left` | Move active window left |
| `Super` + `Shift` + `Right` | Move active window right |
| `Super` + `Shift` + `Up` | Move active window up |
| `Super` + `Shift` + `Down` | Move active window down |

## Resize Windows

| Shortcut | Action |
| :--- | :--- |
| `Super` + `Ctrl` + `H` | Shrink active window width |
| `Super` + `Ctrl` + `L` | Grow active window width |
| `Super` + `Ctrl` + `K` | Shrink active window height |
| `Super` + `Ctrl` + `J` | Grow active window height |
| `Super` + `Left Click` + Drag | Move window with mouse |
| `Super` + `Right Click` + Drag | Resize window with mouse |

## Task Switching

| Shortcut | Action |
| :--- | :--- |
| `Alt` + `Tab` | Open the Rofi switcher across all workspaces |
| `Alt` + `Shift` + `Tab` | Open the Rofi switcher in reverse order / move up |
| `Super` + `Tab` | Open the Rofi workspace selector / move down |
| `Super` + `Shift` + `Tab` | Open the Rofi workspace selector / move up |

`Alt + Tab` hides windows from `special:minimized` and initially highlights the previously focused app rather than the current one. `Alt + Shift + Tab` can also open the switcher directly in reverse order. Keep holding `Alt` and press `Tab` repeatedly to move down; use `Alt + Shift + Tab` to move upward. Hovering only changes the highlighted row and never switches while `Alt` remains held. Releasing `Alt` switches immediately to the highlighted app. Clicking or pressing `Enter` also switches immediately. `Escape` cancels and restores the original app. `Super + Tab` opens a separate Rofi selector for existing workspaces with its existing one-second timer and `Super`-release requirement.

## Workspaces

| Shortcut | Action |
| :--- | :--- |
| `Super` + `Ctrl` + `Left` | Switch to previous workspace |
| `Super` + `Ctrl` + `Right` | Switch to next workspace |
| `Super` + `Ctrl` + `D` | Switch to an empty workspace |
| `Super` + `Ctrl` + `Shift` + `D` | Move active window to an empty workspace |
| `Super` + `1` | Switch to workspace 1 |
| `Super` + `2` | Switch to workspace 2 |
| `Super` + `3` | Switch to workspace 3 |
| `Super` + `4` | Switch to workspace 4 |
| `Super` + `5` | Switch to workspace 5 |
| `Super` + `6` | Switch to workspace 6 |
| `Super` + `7` | Switch to workspace 7 |
| `Super` + `8` | Switch to workspace 8 |
| `Super` + `9` | Switch to workspace 9 |
| `Super` + `0` | Switch to workspace 10 |

## Move Window To Workspace

| Shortcut | Action |
| :--- | :--- |
| `Super` + `Shift` + `1` | Move active window to workspace 1 silently |
| `Super` + `Shift` + `2` | Move active window to workspace 2 silently |
| `Super` + `Shift` + `3` | Move active window to workspace 3 silently |
| `Super` + `Shift` + `4` | Move active window to workspace 4 silently |
| `Super` + `Shift` + `5` | Move active window to workspace 5 silently |
| `Super` + `Shift` + `6` | Move active window to workspace 6 silently |
| `Super` + `Shift` + `7` | Move active window to workspace 7 silently |
| `Super` + `Shift` + `8` | Move active window to workspace 8 silently |
| `Super` + `Shift` + `9` | Move active window to workspace 9 silently |
| `Super` + `Shift` + `0` | Move active window to workspace 10 silently |
| `Super` + `Ctrl` + `Shift` + `1` | Move active window to workspace 1 and follow |
| `Super` + `Ctrl` + `Shift` + `2` | Move active window to workspace 2 and follow |
| `Super` + `Ctrl` + `Shift` + `3` | Move active window to workspace 3 and follow |
| `Super` + `Ctrl` + `Shift` + `4` | Move active window to workspace 4 and follow |
| `Super` + `Ctrl` + `Shift` + `5` | Move active window to workspace 5 and follow |

## Grouped / Tabbed Windows

| Shortcut | Action |
| :--- | :--- |
| `Super` + `Z` | Toggle window group |
| `Alt` + `Right` | Switch to next window in group |
| `Alt` + `Left` | Switch to previous window in group |

## Audio

| Shortcut | Action |
| :--- | :--- |
| `Volume Up` | Raise volume by 2% and show OSD |
| `Volume Down` | Lower volume by 2% and show OSD |
| `Mute` | Toggle speaker mute and show OSD |
| `Mic Mute` | Toggle microphone mute |
| `Super` + `F12` | Raise volume by 2% and show OSD |
| `Super` + `F11` | Lower volume by 2% and show OSD |
| `Super` + `F10` | Toggle speaker mute and show OSD |

## Media

| Shortcut | Action |
| :--- | :--- |
| `Play/Pause` | Toggle media playback |
| `Next` | Next media track |
| `Previous` | Previous media track |
| `Super` + `F8` | Toggle media playback |
| `Super` + `F9` | Next media track |
| `Super` + `F7` | Previous media track |

## Brightness

| Shortcut | Action |
| :--- | :--- |
| `Brightness Up` | Raise brightness by 2% and show OSD |
| `Brightness Down` | Lower brightness by 2% and show OSD |
| `Super` + `F6` | Raise brightness by 2% and show OSD |
| `Super` + `F5` | Lower brightness by 2% and show OSD |

## Screenshots

| Shortcut | Action |
| :--- | :--- |
| `Super` + `U` | Select an area, save screenshot, and copy it |
| `Super` + `Shift` + `U` | Capture full screen, save screenshot, and copy it |

## Touchpad Gestures

| Gesture | Action |
| :--- | :--- |
| 3-finger horizontal swipe | Switch workspace |
| 3-finger swipe up | Toggle fullscreen |
| 3-finger swipe down | Toggle special workspace |
| 4-finger horizontal swipe | Switch workspace |

## Notes

### Hiding Windows

Hyprland does not have native minimize/hide behavior, so this setup uses `special:minimized`:

1. Press `Super + H` to hide the active window.
2. Press `Super + Shift + H` to restore the most recently hidden window.
3. Hidden windows are excluded from the custom Rofi app switcher.

### Split Screen

Normal apps open as stacked, full-work-area floating windows. Only the selected app is visible; `Alt + Tab` raises the selected app without revealing a split, and Waybar remains reserved above it. Press `Super + Shift + Space` to force the active window into Hyprland's tiled layout. `Super + F` remains a floating/tiled toggle.

### Reinstall Helpers

```bash
chmod +x ~/.config/hypr/scripts/setup.sh
~/.config/hypr/scripts/setup.sh
```
