local home = assert(os.getenv("HOME"), "HOME is not set")
local scripts = home .. "/.config/hypr/scripts/"
local main = "SUPER"

local function described(options, description)
    local result = {}
    for key, value in pairs(options or {}) do
        result[key] = value
    end
    result.description = description
    return result
end

local function run(keys, command, description, options)
    hl.bind(
        keys,
        hl.dsp.exec_cmd(command),
        described(options, description)
    )
end

local function bind(keys, dispatcher, description, options)
    hl.bind(keys, dispatcher, described(options, description))
end

-- Core applications and desktop actions.
run(main .. " + Q", "kitty", "Open terminal")
run(main .. " + E", "thunar", "Open file manager")
run(main .. " + R", "rofi -show drun", "Open application launcher")
bind(main .. " + F", hl.dsp.window.float(), "Toggle floating")
bind(main .. " + SHIFT + P", hl.dsp.window.pin(), "Pin or unpin window")
bind(main .. " + C", hl.dsp.window.close(), "Close active window")
run(main .. " + B", "brave-origin-nightly", "Open browser")
run(main .. " + W", "pkill -SIGUSR1 -x waybar", "Toggle Waybar")
run(main .. " + K", "kitty", "Open another terminal")
run(main .. " + D", "discord", "Open Discord")
run(main .. " + G", scripts .. "sleep_animation.sh", "Suspend with animation")
run(main .. " + N", scripts .. "toggle_night.sh", "Toggle night-light shader")
run(main .. " + X", scripts .. "power_menu.sh", "Open power menu")
run(main .. " + SHIFT + F", scripts .. "fan_control.sh", "Open fan control")
run(main .. " + P", scripts .. "display_manager.sh", "Open display manager")
run(main .. " + J", scripts .. "cursor_selector.sh", "Choose cursor theme")
run(main .. " + L", "loginctl lock-session", "Lock the session")

-- Minimize/restore stack.
run(main .. " + H", scripts .. "minimize_toggle.sh minimize", "Minimize active window")
run(main .. " + SHIFT + H", scripts .. "minimize_toggle.sh restore", "Restore last minimized window")

-- Scratchpad.
bind(
    main .. " + T",
    hl.dsp.workspace.toggle_special("scratchpad"),
    "Toggle scratchpad"
)
bind(
    main .. " + SHIFT + T",
    hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }),
    "Move window to scratchpad"
)

-- Focus and window movement.
local directions = {
    Left = "l",
    Right = "r",
    Up = "u",
    Down = "d",
}

for key, direction in pairs(directions) do
    bind(
        main .. " + " .. key,
        hl.dsp.focus({ direction = direction }),
        "Focus " .. direction
    )
    bind(
        main .. " + SHIFT + " .. key,
        hl.dsp.window.move({ direction = direction }),
        "Move window " .. direction
    )
end

run(main .. " + M", scripts .. "fullscreen_raise.sh 0", "Toggle fullscreen")
run(main .. " + SHIFT + M", scripts .. "fullscreen_raise.sh 1", "Toggle maximize")

-- MRU Alt-Tab. Non-consuming presses reach the already-open Rofi selector;
-- releasing either Alt key commits the highlighted row.
run(
    "ALT + Tab",
    scripts .. "smart_alttab.sh",
    "Next window",
    { non_consuming = true }
)
run(
    "ALT + SHIFT + Tab",
    scripts .. "smart_alttab.sh --reverse",
    "Previous window",
    { non_consuming = true }
)
run(
    "ALT + Alt_L",
    scripts .. "alttab_modifier_release.sh",
    "Commit Alt-Tab",
    { release = true, locked = true }
)
run(
    "ALT + Alt_R",
    scripts .. "alttab_modifier_release.sh",
    "Commit Alt-Tab",
    { release = true, locked = true }
)

run(
    main .. " + SHIFT + Space",
    scripts .. "force_tile.sh",
    "Force active window into tiling"
)

-- Workspaces.
bind(main .. " + CTRL + Left", hl.dsp.focus({ workspace = "-1" }), "Previous workspace")
bind(main .. " + CTRL + Right", hl.dsp.focus({ workspace = "+1" }), "Next workspace")
bind(main .. " + CTRL + D", hl.dsp.focus({ workspace = "empty" }), "Open empty workspace")
bind(
    main .. " + CTRL + SHIFT + D",
    hl.dsp.window.move({ workspace = "empty", follow = true }),
    "Move window to empty workspace"
)

for workspace = 1, 10 do
    local key = workspace % 10
    bind(
        main .. " + " .. key,
        hl.dsp.focus({ workspace = workspace }),
        "Open workspace " .. workspace
    )
    bind(
        main .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = workspace, follow = false }),
        "Move window silently to workspace " .. workspace
    )

    if workspace <= 5 then
        bind(
            main .. " + SHIFT + CTRL + " .. key,
            hl.dsp.window.move({ workspace = workspace, follow = true }),
            "Move window and follow to workspace " .. workspace
        )
    end
end

run(
    main .. " + Tab",
    scripts .. "workspace_switcher.sh",
    "Open workspace selector",
    { non_consuming = true }
)
run(
    main .. " + SHIFT + Tab",
    scripts .. "workspace_switcher.sh",
    "Open reverse workspace selector",
    { non_consuming = true }
)
run(
    main .. " + Super_L",
    scripts .. "workspace_modifier_release.sh",
    "Commit workspace selection",
    { release = true, locked = true }
)
run(
    main .. " + Super_R",
    scripts .. "workspace_modifier_release.sh",
    "Commit workspace selection",
    { release = true, locked = true }
)

-- Groups.
bind(main .. " + Z", hl.dsp.group.toggle(), "Toggle window group")
bind("ALT + Right", hl.dsp.group.next(), "Next grouped window")
bind("ALT + Left", hl.dsp.group.prev(), "Previous grouped window")

-- Audio, media, and brightness.
local locked = { locked = true }
local repeat_locked = { locked = true, repeating = true }
local volume_up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
    .. " && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0"
    .. " && " .. scripts .. "volume_osd.sh"
local volume_down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
    .. " && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0"
    .. " && " .. scripts .. "volume_osd.sh"
local volume_mute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    .. " && " .. scripts .. "volume_osd.sh"
local brightness_up = "brightnessctl s 2%+ && " .. scripts .. "brightness_osd.sh"
local brightness_down = "brightnessctl s 2%- && " .. scripts .. "brightness_osd.sh"

run("XF86AudioRaiseVolume", volume_up, "Raise volume", repeat_locked)
run("XF86AudioLowerVolume", volume_down, "Lower volume", repeat_locked)
run("XF86AudioMute", volume_mute, "Toggle audio mute", locked)
run(
    "XF86AudioMicMute",
    "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
    "Toggle microphone mute",
    locked
)
run("XF86AudioPlay", "playerctl play-pause", "Play or pause media", locked)
run("XF86AudioNext", "playerctl next", "Next media track", locked)
run("XF86AudioPrev", "playerctl previous", "Previous media track", locked)
run("XF86MonBrightnessUp", brightness_up, "Raise brightness", repeat_locked)
run("XF86MonBrightnessDown", brightness_down, "Lower brightness", repeat_locked)

run(main .. " + F12", volume_up, "Raise volume", repeat_locked)
run(main .. " + F11", volume_down, "Lower volume", repeat_locked)
run(main .. " + F10", volume_mute, "Toggle audio mute", locked)
run(main .. " + F6", brightness_up, "Raise brightness", repeat_locked)
run(main .. " + F5", brightness_down, "Lower brightness", repeat_locked)
run(main .. " + F8", "playerctl play-pause", "Play or pause media", locked)
run(main .. " + F9", "playerctl next", "Next media track", locked)
run(main .. " + F7", "playerctl previous", "Previous media track", locked)

-- Screenshots. The output directory is created on demand.
run(
    main .. " + U",
    [[mkdir -p "$HOME/Pictures/Screenshots" && grim -g "$(slurp)" - | tee "$HOME/Pictures/Screenshots/screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png" | wl-copy]],
    "Capture a selected region"
)
run(
    main .. " + SHIFT + U",
    [[mkdir -p "$HOME/Pictures/Screenshots" && grim - | tee "$HOME/Pictures/Screenshots/screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png" | wl-copy]],
    "Capture the full screen"
)

bind(
    main .. " + mouse:272",
    hl.dsp.window.drag(),
    "Drag active window",
    { mouse = true }
)
bind(
    main .. " + mouse:273",
    hl.dsp.window.resize(),
    "Resize active window",
    { mouse = true }
)

bind(
    main .. " + CTRL + H",
    hl.dsp.window.resize({ x = -40, y = 0, relative = true }),
    "Shrink window horizontally"
)
bind(
    main .. " + CTRL + L",
    hl.dsp.window.resize({ x = 40, y = 0, relative = true }),
    "Grow window horizontally"
)
bind(
    main .. " + CTRL + K",
    hl.dsp.window.resize({ x = 0, y = -40, relative = true }),
    "Shrink window vertically"
)
bind(
    main .. " + CTRL + J",
    hl.dsp.window.resize({ x = 0, y = 40, relative = true }),
    "Grow window vertically"
)
