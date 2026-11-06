-- Hyprland config (Lua), migrated from hyprland.conf on 2026-11-04.
-- Wiki: https://wiki.hypr.land/configuring/
-- API reference for this exact version: /usr/share/hypr/stubs/hl.meta.lua

local HOME = os.getenv("HOME")


------------------
---- MONITORS ----
------------------

-- Catch-all for anything else that gets plugged in.
hl.monitor({ output = "", mode = "highres", position = "auto", scale = "auto" })

-- Main screen, 240Hz.
hl.monitor({ output = "DP-4", mode = "1920x1080@239.76", position = "0x0", scale = 1 })

-- HDMI-A-1 comes from monitor-state.conf, which ~/.local/scripts/monitor-orientation.sh
-- rewrites (SUPER+SHIFT+O). SDDM's /usr/local/bin/sddm-xsetup reads the same file,
-- so it keeps its old one-line format:
--   monitor = HDMI-A-1, 1920x1080@74.97, 1920x0, 1, transform, 1
local function hdmi_from_state_file()
    local hdmi = { output = "HDMI-A-1", mode = "1920x1080@74.97", position = "1920x0", scale = 1, transform = 0 }

    local f = io.open(HOME .. "/.config/hypr/monitor-state.conf", "r")
    if not f then return hdmi end
    local line = f:read("l") or ""
    f:close()

    local fields = {}
    for part in line:gsub("^%s*monitor%s*=%s*", ""):gmatch("[^,]+") do
        fields[#fields + 1] = part:match("^%s*(.-)%s*$")
    end

    if fields[1] == "HDMI-A-1" and #fields >= 4 then
        hdmi.mode      = fields[2]
        hdmi.position  = fields[3]
        hdmi.scale     = tonumber(fields[4]) or 1
        hdmi.transform = (fields[5] == "transform" and tonumber(fields[6])) or 0
    end
    return hdmi
end

hl.monitor(hdmi_from_state_file())

-- Make DP-4 the XWayland primary so Wine/Proton games use it (and its 240Hz).
-- Top-level code runs on every load/reload, so the orientation toggle keeps it too.
hl.exec_cmd("xrandr --output DP-4 --primary")

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
    cursor = {
        default_monitor = "DP-4", -- cursor (and focus) start on the main screen
    },
})

-- DP-4 is the main screen: workspace 1 always lives there.
-- HDMI-A-1 is the second screen: workspace 2 always lives there.
-- Other workspaces open wherever you are when you switch to them.
hl.workspace_rule({ workspace = "1", monitor = "DP-4",     default = true })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", default = true })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "thunar"
local editor      = "cursor"

-- Windows 95 sound theme: ~/.local/share/sounds/Windows95/
local SOUNDS = HOME .. "/.local/share/sounds/Windows95/stereo/"


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- Was env_var.conf plus the two env lines at the bottom of hyprland.conf.

hl.env("XCURSOR_THEME", "Chicago95_Standard_Cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")


-------------------
---- AUTOSTART ----
-------------------

-- Was exec-once: runs once when Hyprland starts.
hl.on("hyprland.start", function()
    hl.exec_cmd(HOME .. "/.config/hypr/xdg-portal-hyprland")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("sh -c 'while true; do waybar -s " .. HOME .. "/.local/share/waybar/style.css; sleep 1; done'")
    hl.exec_cmd("awww img " .. HOME .. "/.cache/current-wallpaper")
    hl.exec_cmd("mako")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("libinput-gestures")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprctl setcursor Chicago95_Standard_Cursors 24")
    hl.exec_cmd("pw-play '" .. SOUNDS .. "desktop-login.wav'") -- The Microsoft Sound
end)

-- Was exec: runs on every load/reload.
hl.exec_cmd([[gsettings set org.gnome.desktop.interface gtk-theme "Chicago95"]])
hl.exec_cmd([[gsettings set org.gnome.desktop.interface icon-theme "SE98"]])
hl.exec_cmd([[gsettings set org.gnome.desktop.interface cursor-theme "Chicago95_Standard_Cursors"]])
hl.exec_cmd([[gsettings set org.gnome.desktop.sound theme-name "Windows95"]])


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        -- Alt/Super swap is per-connection via keyd (USB-C only).
        -- The 2.4G dongle reports the opposite mapping from USB-C.
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
            scroll_factor  = 0.5,
        },
    },

    gestures = {
        workspace_swipe_distance = 150,
        workspace_swipe_invert   = false,
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 3,
        gaps_out    = 7,
        border_size = 2,
        col = {
            active_border   = "rgba(d4d0c8ff)",
            inactive_border = "rgba(c0c0c0ff)",
        },
        layout = "dwindle",
    },

    cursor = {
        inactive_timeout = 5,
    },

    misc = {
        disable_hyprland_logo = true,
    },

    decoration = {
        rounding = 0,

        blur = {
            enabled        = true,
            size           = 10,
            passes         = 2,
            ignore_opacity = true,
        },

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },
})

hl.layer_rule({ match = { namespace = "lockscreen" }, blur = true })
hl.layer_rule({ match = { namespace = "waybar" },     blur = true })

hl.curve("myBezier", { type = "bezier", points = { {0.10, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 7,  bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7,  bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "default" })


----------------------
---- WINDOW RULES ----
----------------------

hl.window_rule({ match = { class = "^(pavucontrol)$" },          float = true, opacity = "1.0 1.0" })
hl.window_rule({ match = { class = "^(blueman-manager)$" },      float = true, opacity = "1.0 1.0" })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
hl.window_rule({ match = { class = "^(chromium)$" },             float = true, animation = "popin" })
hl.window_rule({ match = { class = "^(thunar)$" },               float = true, animation = "popin", opacity = "1.0 1.0" })
hl.window_rule({ match = { title = "^(btop)$" },                 float = true })
hl.window_rule({ match = { title = "^(update-sys)$" },           float = true })
hl.window_rule({ match = { class = "^(Code)$" },                 opacity = "1.0 1.0" })

-- Windows 98 style for kitty: tiled, no rounded corners, no transparency.
hl.window_rule({ match = { class = "^(kitty)$" }, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { class = "^(kitty)$" }, rounding = 0 })
hl.window_rule({ match = { class = "^(kitty)$", focus = true },  border_color = "rgb(000080)" })
hl.window_rule({ match = { class = "^(kitty)$", focus = false }, border_color = "rgb(808080)" })
-- Don't honor kitty's saved maximize request (looks like fullscreen).
hl.window_rule({ match = { class = "^(kitty)$" }, suppress_event = "maximize" })

hl.window_rule({
    match   = { class = "^(wofi)$" },
    move    = { "cursor_x+(-(monitor_w*0.03))", "cursor_y+(-(monitor_h*1.05))" },
    no_anim = true,
})

hl.window_rule({ match = { class = "^(org.qbittorrent.qBittorrent)$" }, opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(Spotify)$" },     opacity = "1.0 1.0" })
hl.window_rule({ match = { class = "^(thunderbird)$" }, opacity = "1.0 1.0" })

hl.window_rule({ match = { class = "^(Steam)$", title = "^(Steam)$" }, pin = true })

-- Steam XWayland toasts (friend online, etc). Top-left on DP-4.
hl.window_rule({
    match            = { class = "^(steam)$", title = "^notificationtoasts_.*_desktop$" },
    float            = true,
    border_size      = 0,
    no_shadow        = true,
    no_initial_focus = true,
    pin              = true,
    monitor          = "DP-4",
    move             = { 20, 20 },
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

local function bind(keys, action, opts)
    return hl.bind(mainMod .. " + " .. keys, action, opts)
end

bind("K",         hl.dsp.exec_cmd(terminal))
bind("Q",         hl.dsp.window.close())
bind("L",         hl.dsp.exec_cmd("hyprlock"))
bind("SHIFT + H", hl.dsp.exec_cmd("systemctl hibernate"))
bind("SHIFT + M", hl.dsp.exec_cmd(HOME .. "/.local/scripts/win95-session.sh logout"))
bind("E",         hl.dsp.exec_cmd(fileManager))
bind("C",         hl.dsp.exec_cmd(editor))
bind("V",         hl.dsp.window.float({ action = "toggle" }))
bind("SPACE",     hl.dsp.exec_cmd(HOME .. "/.local/scripts/win95-start.sh"))
bind("P",         hl.dsp.window.pseudo())
bind("S",         hl.dsp.exec_cmd([[grim -g "$(slurp)" - | swappy -f -]]))
bind("U",         hl.dsp.exec_cmd("cliphist list | wofi -dmenu | cliphist decode | wl-copy"))
bind("W",         hl.dsp.exec_cmd(HOME .. "/.config/hypr/scripts/wallpaper.sh"))

bind("F",         hl.dsp.window.fullscreen({ mode = "maximized" }))
bind("SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Second monitor orientation toggle.
bind("SHIFT + O", hl.dsp.exec_cmd(HOME .. "/.local/scripts/monitor-orientation.sh"))

-- Move focus / move windows with arrow keys.
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    bind(dir,             hl.dsp.focus({ direction = dir }))
    bind("SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

-- Switch workspaces with mainMod + [0-9], move window with mainMod + SHIFT + [0-9].
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    bind(tostring(key),             hl.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. key,         hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll.
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging.
bind("mouse:272", hl.dsp.window.drag(),   { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize submap: SUPER+R enters, releasing SUPER+R (or Escape) leaves.
bind("R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    local function resize(x, y)
        return hl.dsp.window.resize({ x = x, y = y, relative = true })
    end
    hl.bind("right",         resize(30, 0),   { repeating = true })
    hl.bind("SHIFT + right", resize(10, 0),   { repeating = true })
    hl.bind("left",          resize(-30, 0),  { repeating = true })
    hl.bind("SHIFT + left",  resize(-10, 0),  { repeating = true })
    hl.bind("up",            resize(0, -30),  { repeating = true })
    hl.bind("SHIFT + up",    resize(0, -10),  { repeating = true })
    hl.bind("down",          resize(0, 30),   { repeating = true })
    hl.bind("SHIFT + down",  resize(0, 10),   { repeating = true })
    bind("R", hl.dsp.submap("reset"), { release = true, transparent = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)


-----------------
---- PLUGINS ----
-----------------
-- Plugins are loaded by `hyprpm reload -n` in autostart, so they don't exist
-- on the very first config pass. The checks keep that from being an error.

if hl.plugin.hyprbars ~= nil then
    hl.config({
        plugin = {
            hyprbars = {
                enabled                    = true,
                bar_height                 = 20,
                bar_color                  = "rgba(000080ff)",
                col = { text = "rgb(ffffff)" },
                bar_text_size              = 11,
                bar_text_font              = "Courier New",
                bar_precedence_over_border = true,
            },
        },
    })

    -- Buttons are added right to left.
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(c0c0c0)", fg_color = "rgb(000000)", size = 14, icon = "🗙",
        action = [[hyprctl dispatch 'hl.dsp.window.close()']],
    })
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(c0c0c0)", fg_color = "rgb(000000)", size = 14, icon = "🗖",
        action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized" })']],
    })
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(c0c0c0)", fg_color = "rgb(000000)", size = 14, icon = "🗕",
        action = HOME .. "/.config/hypr/scripts/minimize.sh",
    })
end

-- borders-plus-plus is disabled in hyprpm (`hyprpm list`). If you enable it,
-- uncomment this. Option names are from the plugin's Lua README.
-- if hl.plugin.borders_plus_plus ~= nil then
--     hl.config({
--         plugin = {
--             borders_plus_plus = {
--                 add_borders      = 2,
--                 col              = { border_1 = "rgb(ffffff)", border_2 = "rgb(404040)" },
--                 border_size_1    = 1,
--                 border_size_2    = 1,
--                 natural_rounding = false,
--             },
--         },
--     })
-- end
