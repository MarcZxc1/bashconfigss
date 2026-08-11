local home = assert(os.getenv("HOME"), "HOME is not set")
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local scripts = config_home .. "/hypr/scripts/"
local hotplug_timers = {}

local function run_after(storage, timeout, command)
    storage[#storage + 1] = hl.timer(function()
        hl.exec_cmd(command)
    end, {
        timeout = timeout,
        type = "oneshot",
    })
end

hl.on("hyprland.start", function()
    hl.exec_cmd(scripts .. "set_theme.sh")
end)

-- Native monitor events replace monitor_daemon.sh and its permanent
-- bash+socat pipeline. The original script remains available as a rollback.
hl.on("monitor.added", function(monitor)
    if monitor ~= nil and not monitor.name:match("^eDP") then
        run_after(
            hotplug_timers,
            2000,
            scripts .. "display_manager.sh --auto-extend"
        )
    end
end)

hl.on("monitor.removed", function(monitor)
    if monitor ~= nil and not monitor.name:match("^eDP") then
        hl.exec_cmd(scripts .. "display_manager.sh --auto-internal")
    end
end)

-- A compositor timer replaces the permanent battery_notify.sh loop. It keeps
-- the same 20%/10% thresholds and reminder intervals without another process.
local battery_path = "/sys/class/power_supply/BAT0/"
local last_battery_level = ""
local last_battery_notice = 0

local function read_line(path)
    local file = io.open(path, "r")
    if file == nil then
        return nil
    end

    local value = file:read("*l")
    file:close()
    return value
end

local function check_battery()
    local status = read_line(battery_path .. "status")
    local capacity = tonumber(read_line(battery_path .. "capacity") or "")

    if status ~= "Discharging" or capacity == nil then
        last_battery_level = ""
        return
    end

    local level = ""
    local interval = 0
    local command = ""

    if capacity <= 10 then
        level = "critical"
        interval = 60
        command = string.format(
            "notify-send -u critical 'CRITICAL BATTERY' "
                .. "'Laptop will die soon! (%d%%)' -i battery-empty",
            capacity
        )
    elseif capacity <= 20 then
        level = "low"
        interval = 300
        command = string.format(
            "notify-send -u normal 'Low Battery' "
                .. "'Battery is at %d%%. Please plug in the charger.' -i battery-low",
            capacity
        )
    end

    if level == "" then
        last_battery_level = ""
        return
    end

    local now = os.time()
    if level ~= last_battery_level or now - last_battery_notice >= interval then
        hl.exec_cmd(command)
        last_battery_level = level
        last_battery_notice = now
    end
end

local battery_timer = nil

local function start_battery_timer()
    if battery_timer ~= nil then
        battery_timer:set_enabled(false)
    end

    check_battery()
    battery_timer = hl.timer(check_battery, {
        timeout = 60000,
        type = "repeat",
    })
end

hl.on("hyprland.start", start_battery_timer)
