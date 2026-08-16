-- Global
local theme = require("modules.colors")
hl.window_rule({name = "globalrules", match = { class = ".*",
}, animation = "slide top",})

-- Portals
hl.window_rule({ name = "portal-gtkrules", match = { class = "xdg-desktop-portal-gtk" },
float = true, size = "1000 500", center = true, border_size = 2, opacity = "1", 
animation = "slide top", border_color = theme.color2 .. " " .. theme.color15 })

-- Nautilus
hl.window_rule({ name = "nautilusrules", match = { class = "org.gnome.Nautilus" },float = true, size = "1200 700", 
center = true, border_size = 2, opacity = "1", animation = "slide top",
border_color = theme.color2 .. " " .. theme.color15 })

-- Neovim
hl.window_rule({ name = "nvimrules", match = { class = "vimpad" },float = true, size = "1200 700", 
center = true, border_size = 2, opacity = "1", animation = "slide top",
border_color = theme.color2 .. " " .. theme.color15 })

-- Term Pad
hl.window_rule({ name = "termpadrules", match = { class = "termpad" },float = true, size = "1200 700", 
center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Quran
hl.window_rule({ name = "quranrules", match = { class = "chrome-www.quranwbw.com__-Default" },
float = true, size = "1200 700", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Sunnan
hl.window_rule({ name = "sunnanrules", match = { class = "chrome-www.sunnah.com__-Default" },
float = true, size = "1200 700", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Pulse Mixer
hl.window_rule({ name = "pulserules", match = { class = "pulsepad" },
float = true, size = "1200 700", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- XFCE Polkit
hl.window_rule({ name = "polkitrules", match = { class = "xfce-polkit" },
float = true, size = "500 150", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- AR KB Layout
hl.window_rule({ name = "kbrules", match = { class = "com.layout.viewer" },
float = true, size = "1200 700", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- HyprMon
hl.window_rule({ name = "hyprmonrules", match = { class = "HyprMon" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Anarchy-Installer
hl.window_rule({ name = "anarchyinstrules", match = { class = "Anarchy-Installer" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })
