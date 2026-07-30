-- Smart gaps retained for the occasional tiled window.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

hl.layer_rule({
    name = "animate-mako",
    match = { namespace = "^(mako)$" },
    animation = "popin",
})
hl.layer_rule({
    name = "no-animation-rofi",
    match = { namespace = "^(rofi)$" },
    no_anim = true,
})
hl.layer_rule({
    name = "no-animation-waybar",
    match = { namespace = "^(waybar)$" },
    no_anim = true,
})
hl.layer_rule({
    name = "no-animation-awww",
    match = { namespace = "^(awww-daemon)$" },
    no_anim = true,
})

-- Windows/Zorin-style stacking: ordinary applications fill the work area as
-- floating windows. window_open_focus.sh trims large windows around Waybar.
hl.window_rule({
    name = "windows-like-default",
    match = { class = ".*" },
    float = true,
    size = "100% 100%",
    center = true,
})

-- Let modal dialogs activate above their parent without permanently locking
-- focus to the first dialog. A global stay_focused rule breaks nested flows:
-- the Save dialog can otherwise steal focus back from its own overwrite
-- confirmation and push that confirmation behind the parent.
hl.window_rule({
    name = "modal-dialog-front",
    match = { modal = true },
    float = true,
    center = true,
    focus_on_activate = true,
    dim_around = true,
})

-- GTK/portal overwrite prompts are not consistently exposed as modal
-- toplevels. Match their English window titles as a dynamic fallback so the
-- destructive confirmation is raised without trapping pointer focus.
hl.window_rule({
    name = "file-overwrite-confirmation-front",
    match = {
        title = "^(Confirm Save( As)?|Replace File|File Already Exists)$",
    },
    focus_on_activate = true,
    dim_around = true,
})

hl.window_rule({
    name = "common-dialog-size",
    match = {
        class = "^(pavucontrol|blueman-manager|gnome-calculator|org.gnome.Calculator)$",
    },
    size = "70% 70%",
    center = true,
})

hl.window_rule({
    name = "about-dialog",
    match = { title = "^(About).*$" },
    size = "55% 55%",
    center = true,
})

hl.window_rule({
    name = "steam-friends",
    match = {
        class = "^(Steam)$",
        title = "^(Friends List)$",
    },
    float = true,
})

hl.window_rule({
    name = "imv-size",
    match = { class = "^(imv)$" },
    size = "800 600",
    center = true,
})

hl.window_rule({
    name = "mpv-aspect-ratio",
    match = { class = "^(mpv)$" },
    keep_aspect_ratio = true,
})

hl.window_rule({
    name = "scratchpad",
    match = { workspace = "^(special:scratchpad)$" },
    float = true,
    size = "80% 85%",
    center = true,
})

hl.window_rule({
    name = "clock-popup",
    match = { class = "^(org.gnome.clocks)$" },
    workspace = "special:clock_popup",
    float = true,
    size = "500 400",
    move = "31.7% 35",
    animation = "popin",
})

hl.workspace_rule({
    workspace = "1",
    persistent = true,
    default_name = "Desktop 1",
})
hl.workspace_rule({
    workspace = "2",
    persistent = true,
    default_name = "Desktop 2",
})
