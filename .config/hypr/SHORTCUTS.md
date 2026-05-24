# Hyprland Windows-like Setup Manual

This manual covers the shortcuts and features of your Windows-inspired Hyprland environment (v0.55.2).

**The `Super` key is the Windows key or Meta key.**

## 🚀 Core Applications
| Shortcut | Action |
| :--- | :--- |
| `Super` + `Q` | Open Terminal (Alacritty) |
| `Super` + `E` | Open File Manager (Thunar) |
| `Super` + `R` | Open App Launcher (Rofi) |
| `Super` + `C` | Close Active Window |

## 🪟 Window Management & Snapping
| Shortcut | Action |
| :--- | :--- |
| `Super` + `Up` | Maximize Window |
| `Super` + `Down` | Restore / Unmaximize Window |
| `Super` + `Left` / `Right` | Snap Window to Left/Right half |
| `Super` + `Left Click` + Drag | **Move Window** (with mouse) |
| `Super` + `Right Click` + Drag | **Resize Window** (with mouse) |
| `Super` + `H` | **Minimize** (Moves window to hidden workspace) |
| `Super` + `Shift` + `H` | Show All Minimized Windows (Toggle) |

## 🔄 Task Switching (Alt + Tab)
| Shortcut | Action |
| :--- | :--- |
| `Alt` + `Tab` | Cycle forward through windows (MRU order) |
| `Alt` + `Shift` + `Tab` | Cycle backward through windows |
| `Super` + `Tab` | Task View (Rofi window switcher) |

## 🖥️ Workspaces (Virtual Desktops)
| Shortcut | Action |
| :--- | :--- |
| `Super` + `Ctrl` + `Left` / `Right` | Switch to Previous / Next Workspace |
| `Super` + `[1-0]` | Jump directly to Workspace 1-10 |
| `Super` + `Shift` + `[1-0]` | Move Window to Workspace 1-10 (Silent) |
| `Super` + `Shift` + `Ctrl` + `1-5`| Move Window AND follow to workspace |

## 🛠️ Usage Instructions

### The Taskbar (Waybar)
- **Left Click** on a window button: Raise or Restore the window.
- **Right Click** on a window button: Close the window.
- **Scroll** over the workspace dots: Cycle through active desktops.
- **Icons**: Minimized windows appear semi-transparent in the taskbar.

### Minimizing Windows
Since Hyprland doesn't have a "native" minimize, we use a **Special Workspace**:
1. Press `Super + H` to send a window to the "minimized void".
2. It remains visible in the **Waybar Taskbar**.
3. Click the taskbar button to bring it back to your current workspace.

### Alt+Tab Overlays
We use `hyprswitch` for the Alt+Tab behavior. It shows a floating GUI with window previews and titles, similar to the Windows 10/11 switcher.

## 📦 Setup & Installation
If you need to reinstall these components, run the setup script:
```bash
chmod +x ~/.config/hypr/scripts/setup.sh
~/.config/hypr/scripts/setup.sh
```
