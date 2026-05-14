-- rules.lua
---@diagnostic disable: undefined-global


-- REGLAS DE CAPAS (LAYER RULES)

-- Aplicar efecto blur en la waybar
hl.layer_rule({
    name = "waybar",
    match = { namespace = "waybar" },
    blur = true
})


-- REGLAS DE VENTANAS (WINDOW RULES)

hl.window_rule({
    name = "firefox",
    match = { class = "^([Ff]irefox)$" },
    workspace = "5 silent"
})

hl.window_rule({
    name = "steam",
    match = { class = "^([Ss]team)$" },
    workspace = "4 silent"
})

hl.window_rule({
    name = "steam-Friends",
    match = {
        class = "^([Ss]team)$",
        title = "^(Friends List)$"
    },
    float = true,
    size = "250 500",
    move = "1200 165"
})

hl.window_rule({
    name = "dolphin",
    match = { class = "^(org.kde.dolphin)$" },
    float = true,
    size = "650 400"
})
