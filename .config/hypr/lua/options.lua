-- Display fallback: prefer the monitor's native mode and let Hyprland place it.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 1,
        col = {
            active_border = "rgba(888888ee)",
            inactive_border = "rgba(444444aa)",
        },
        -- Monocle is Hyprland's native full-work-area window stack. It keeps
        -- the familiar maximized-window workflow without per-window IPC.
        layout = "monocle",
    },

    decoration = {
        rounding = 0,
        shadow = {
            enabled = false,
        },
        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = true,
    },

    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            middle_button_emulation = true,
            disable_while_typing = true,
            drag_lock = true,
            clickfinger_behavior = true,
            scroll_factor = 1.0,
            tap_and_drag = true,
        },
    },

    cursor = {
        no_warps = true,
        warp_on_change_workspace = 0,
        warp_on_toggle_special = 0,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        background_color = "0x1a1b26",
        focus_on_activate = true,
        on_focus_under_fullscreen = 2,
        exit_window_retains_fullscreen = false,
    },
})

-- Keep normal windows/workspaces instant while retaining lightweight OSD and
-- notification layer animations.
hl.curve("lightning", {
    type = "bezier",
    points = {
        { 0.1, 2.0 },
        { 0.1, -0.5 },
    },
})

hl.animation({ leaf = "windows", enabled = false })
hl.animation({ leaf = "border", enabled = false })
hl.animation({ leaf = "fade", enabled = false })
hl.animation({ leaf = "workspaces", enabled = false })
hl.animation({ leaf = "specialWorkspace", enabled = false })
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 2,
    bezier = "lightning",
    style = "popin 80%",
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 3,
    bezier = "default",
    style = "slide",
})

-- Touchpad gestures.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "down", action = "special" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
