-- Global
local theme = require("modules.colors")
hl.window_rule({name = "globalrules", match = { class = ".*",
}, animation = "slide top",})

-- Portals
hl.window_rule({ name = "portal-gtkrules", match = { class = "xdg-desktop-portal-gtk" },
float = true, size = "1000 500", center = true, opacity = "1", 
animation = "slide top", border_color = theme.color2 .. " " .. theme.color15 })

-- Nautilus
hl.window_rule({ name = "nautirules", match = { class = "org.gnome.Nautilus" },
float = true, size = "1000 500", center = true, opacity = "1", 
animation = "slide top", border_color = theme.color2 .. " " .. theme.color15 })

-- Neovim
hl.window_rule({ name = "nvimrules", match = { class = "vimpad" },float = true, size = "1200 700", 
center = true, opacity = "1", animation = "slide top",
border_color = theme.color2 .. " " .. theme.color15 })

-- Term Pad
hl.window_rule({ name = "termpadrules", match = { class = "termpad" },float = true, size = "1200 700", 
center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- HyprThemer
hl.window_rule({ name = "themerrules", match = { class = "themer.py" },float = true, size = "1200 700", 
center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- HyprBinds
hl.window_rule({ name = "bindsrules", match = { class = "binds.py" },float = true, size = "1200 700", 
center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- VSS Code
hl.window_rule({ name = "vssrules", match = { class = "code-oss" },float = true, size = "1200 700", 
center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Quran
hl.window_rule({ name = "quranrules", match = { class = "chrome-www.quranwbw.com__-Default" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Sunnan
hl.window_rule({ name = "sunnanrules", match = { class = "chrome-www.sunnah.com__-Default" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Pulse Mixer
hl.window_rule({ name = "pulserules", match = { class = "pulsepad" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- XFCE Polkit
hl.window_rule({ name = "polkitrules", match = { class = "xfce-polkit" },
float = true, size = "500 150", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Cooler Conntrol
hl.window_rule({ name = "coolerctrlrules", match = { class = "org.coolercontrol.CoolerControl" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Core Conntrol
hl.window_rule({ name = "corectrlrules", match = { class = "org.corectrl.CoreCtrl" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- AR KB Layout
hl.window_rule({ name = "arkbrules", match = { class = "ARKB" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Bluetooth Manager
hl.window_rule({ name = "bluemanrules", match = { class = "blueman-manager" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- HyprMon
hl.window_rule({ name = "hyprmonrules", match = { class = "HyprMon" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Anarchy-Installer
hl.window_rule({ name = "anarchyinstrules", match = { class = "com.anarchy.OfflineInstaller" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Anarchy-Welcome
hl.window_rule({ name = "anarchywelrules", match = { class = "com.anarchy.welcome" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- YouTube Downloader
hl.window_rule({ name = "ytdl", match = { class = "com.github.yt-dlp-gui" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- MPV
hl.window_rule({ name = "mpvrules", match = { class = "mpv" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Arch-Update
hl.window_rule({ name = "archuprules", match = { class = "arch-update" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Arch-Update
hl.window_rule({ name = "piperrules", match = { class = "piper" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Force Opaque - Audacity
hl.window_rule({ match = { class = "Audacity4" }, opaque = true, no_shadow = true,
no_blur = true })

-- Force Opaque - Portals
hl.window_rule({ match = { class = "Xdg-desktop-portal-gtk" }, opaque = true, no_shadow = true,
no_blur = true })

-- Nexus
hl.window_rule({ name = "nexusrules", match = { class = "anarchy-nexus" },
float = true, size = "1200 700", center = true, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })
