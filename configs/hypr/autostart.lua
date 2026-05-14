---@diagnostic disable: undefined-global

-- Inicio Automático
hl.on("hyprland.start", function()
    hl.exec_cmd("XDG_MENU_PREFIX=arch- kbuildsycoca6 --noincremental")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/gnome-keyring/gnome-keyring-daemon --start --components=secrets")
end)
