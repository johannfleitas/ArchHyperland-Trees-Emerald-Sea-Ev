-- hyprland.lua: Archivo principal de configuración
---@diagnostic disable: undefined-global

-- Modulos:
require("autostart")
require("theme")
require("animations")
require("rules")
require("keybinds")

-- Variables de Entorno
hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_SIZE", "16")

-- Monitores (Monitor por defecto)
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "1.25"
})

-- XWayland
hl.config({
    xwayland = {
        force_zero_scaling = true
    }
})
