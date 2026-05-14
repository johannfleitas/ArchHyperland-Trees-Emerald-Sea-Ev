-- theme.lua
-- Configuración visual y de comportamiento del sistema
---@diagnostic disable: undefined-global


hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 10,
        border_size = 2,
        ["col.active_border"] = { colors = { "rgba(3cfa62c2)", "rgba(00ff99ee)" }, angle = 90 },
        ["col.inactive_border"] = "rgba(595959aa)",
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle"
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a
        },
        blur = {
            enabled = true,
            size = 8,
            passes = 1,
            vibrancy = 0.1696
        }
    },
    animations = {
        enabled = true
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            scroll_factor = 0.3
        }
    },
    dwindle = {
        preserve_split = true
    },
    master = {
        new_status = "master"
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true
    },
    xwayland = {
        force_zero_scaling = true
    }
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5
})
