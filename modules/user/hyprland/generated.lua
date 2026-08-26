-- Converted from hyprland.conf via hyprlang2lua, hand-reviewed.
-- Loaded by modules/user/hyprland/hyprland.nix via extraConfig.
-- To change binds/rules/animations/monitors: edit this file directly (Lua),
-- not a Nix attrset — this is the migration off configType = "hyprlang".

local mod = "SUPER"
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 7,
    bezier = "myBezier",
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 7,
    bezier = "default",
    style = "popin 80%",
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 10,
    bezier = "default",
})
hl.animation({
    leaf = "borderangle",
    enabled = true,
    speed = 8,
    bezier = "default",
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 7,
    bezier = "default",
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 6,
    bezier = "default",
})

hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("[float] kitty"))
hl.bind(mod .. " + Z", hl.dsp.exec_cmd("zen-beta"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("kitty -e bluetui"))
hl.bind(mod .. " + W", hl.dsp.exec_cmd("kitty -e wifitui"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd("codium"))
hl.bind(mod .. " + M", hl.dsp.exec_cmd("spotify"))
hl.bind(mod .. " + I", hl.dsp.exec_cmd("thunderbird"))
hl.bind(mod .. " + T", hl.dsp.exec_cmd("kitty -e btop"))
hl.bind(mod .. " + S", hl.dsp.exec_cmd("kitty -e wiremix"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind(mod .. " + EQUAL", hl.dsp.exec_cmd("kitty -e qalc"))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + R", hl.dsp.exec_cmd("fuzzel"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu -p '  Clipboard' | cliphist decode | wl-copy"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist wipe"))
hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("kitty --class wallpaper-picker -T 'Wallpaper Picker' -e wallpaper-picker"))
hl.bind(mod .. " + A", hl.dsp.exec_cmd("pypr expose"))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd("wlogout -b 5"))
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("hl-kb-switch"))
hl.bind(mod .. " + CTRL + ALT + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind("Print", hl.dsp.exec_cmd("hl-screenshot-area"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hl-screenshot-full"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hl-screenrec-toggle"))
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
hl.bind(mod .. " + ALT + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(mod .. " + ALT + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(mod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind(mod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))
hl.bind(mod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mod .. " + comma", hl.dsp.focus({ monitor = "l" }))
hl.bind(mod .. " + period", hl.dsp.focus({ monitor = "r" }))
hl.bind(mod .. " + SHIFT + comma", function() local w = hl.get_active_workspace(); if not w then return end; hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "l" })) end)
hl.bind(mod .. " + SHIFT + period", function() local w = hl.get_active_workspace(); if not w then return end; hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "r" })) end)

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ && notify-send -t 1000 -h string:x-canonical-private-synchronous:audio '󰕾 Volume' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@)\""), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send -t 1000 -h string:x-canonical-private-synchronous:audio '󰕾 Volume' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@)\""), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+ && notify-send -t 1000 -h string:x-canonical-private-synchronous:brightness '󰃠 Brightness' \"$(brightnessctl -m | cut -d, -f4)\""), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%- && notify-send -t 1000 -h string:x-canonical-private-synchronous:brightness '󰃟 Brightness' \"$(brightnessctl -m | cut -d, -f4)\""), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set 10%+"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set 10%-"), { locked = true, repeating = true })

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify-send -t 1000 -h string:x-canonical-private-synchronous:audio '󰝟 Audio' 'Mute toggled'"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize())

hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true,
})

hl.layer_rule({
    match = { namespace = "swaync-notification-window" },
    blur = false,
})

hl.layer_rule({
    match = { namespace = "swaync-control-center" },
    blur = true,
})

hl.layer_rule({
    match = { namespace = "wlogout" },
    blur = true,
})

hl.monitor({
    output = "eDP-1",
    mode = "3200x2000@120",
    position = "0x0",
    scale = "2",
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "preferred",
    position = "auto",
    scale = "1",
})

hl.monitor({
    output = "Unknown-1",
    disabled = true,
})

hl.window_rule({
    match = {
        class = "wallpaper-picker",
    },
    float = true,
    size = "1200 700",
    center = true,
})

hl.window_rule({
    match = {
        class = "clipboard-picker",
    },
    float = true,
    size = "600 400",
    center = true,
})

-- sioyek (LaTeX preview via VimTeX): always open tiled on the active
-- workspace so it lands beside nvim for the dual-window edit+preview layout.
-- Dwindle splits it right of the focused window automatically.
hl.window_rule({
    match = {
        class = "sioyek",
    },
    open_on = "active",
    float = false,
})

hl.window_rule({
    match = {
        class = "gsimplecal",
    },
    float = true,
    move = "45.5% 48",
})

hl.window_rule({
    match = {
        fullscreen = true,
    },
    idle_inhibit = "always",
})

hl.window_rule({
    match = {
        title = "Picture-in-Picture",
    },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    move = "72% 7%",
})

hl.window_rule({
    match = {
        class = "zen-beta",
        title = "^$",
    },
    stay_focused = true,
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.config({
    animations = {
        enabled = true,
    },
    binds = {
        allow_workspace_cycles = true,
        workspace_back_and_forth = true,
    },
    debug = {
        vfr = true,
    },
    decoration = {
        blur = {
            enabled = true,
            noise = 0.050000,
            passes = 1,
            size = 4,
            xray = false,
        },
        shadow = {
            enabled = true,
            range = 20,
            render_power = 4,
        },
        inactive_opacity = 0.850000,
        rounding = 12,
    },
    dwindle = {
        preserve_split = true,
    },
    general = {
        border_size = 2,
        gaps_in = 5,
        gaps_out = 10,
        layout = "dwindle",
        resize_on_border = true,
    },
    -- general.col, group.col, group.groupbar, decoration.shadow.color, and
    -- misc.background_color are intentionally omitted: stylix's hyprland
    -- target (modules/hyprland/hm.nix upstream) injects those via its own
    -- separate settings.config contribution, re-evaluated from the active
    -- theme on every rebuild. Hardcoding them here would freeze today's
    -- catppuccin-mocha values and break `theme = "..."` re-theming.
    input = {
        touchpad = {
            disable_while_typing = true,
            natural_scroll = true,
            tap_to_click = true,
        },
        follow_mouse = 1,
        kb_layout = "us,br",
        numlock_by_default = true,
        repeat_delay = 300,
        repeat_rate = 50,
        sensitivity = 0,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        focus_on_activate = false,
        force_default_wallpaper = 0,
        mouse_move_enables_dpms = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
})

-- exec-once entries (dbus activation, pyprland, awww-daemon, wallpaper-init,
-- hyprpolkitagent) are generated separately by home-manager's systemd.enable
-- default plus per-module extraConfig fragments (pyprland.nix, hyprpaper.nix,
-- hyprland.nix) so their nix store paths stay live instead of frozen here.
