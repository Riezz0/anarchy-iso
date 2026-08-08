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

-- HyprThemer
hl.window_rule({ name = "themerrules", match = { class = "themer.py" },float = true, size = "1200 700", 
center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- HyprBinds
hl.window_rule({ name = "bindsrules", match = { class = "binds.py" },float = true, size = "1200 700", 
center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- VSS Code
hl.window_rule({ name = "vssrules", match = { class = "codium" },float = true, size = "1200 700", 
center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Piper GUI
hl.window_rule({ name = "pyprrules", match = { title = "pypr-gui" },float = true, size = "1200 700", 
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

-- Cooler Conntrol
hl.window_rule({ name = "coolerctrlrules", match = { class = "org.coolercontrol.CoolerControl" },
float = true, size = "1200 700", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- Core Conntrol
hl.window_rule({ name = "corectrlrules", match = { class = "org.corectrl.CoreCtrl" },
float = true, size = "1200 700", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- AR KB Layout
hl.window_rule({ name = "kbrules", match = { class = "com.layout.viewer" },
float = true, size = "1200 700", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- SCRCPY
hl.window_rule({ name = "scrcpyrules", match = { class = "scrcpy" },
float = true, size = "374 851", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- ARCH UPDATE
hl.window_rule({ name = "archupdaterules", match = { class = "kitty", title = "arch-update" },
opacity = "1", animation = "slide top", border_color = theme.color2 .. " " .. theme.color15 })
hl.on("window.title", function(w)
  if w ~= nil and w.class == "kitty" and w.title == "arch-update" then
    hl.dispatch(hl.dsp.window.float({ action = "set", window = "address:" .. w.address }))
    hl.dispatch(hl.dsp.window.resize({ x = 1200, y = 700, window = "address:" .. w.address }))
    hl.dispatch(hl.dsp.window.move({ workspace = 3, window = "address:" .. w.address }))
    hl.dispatch(hl.dsp.window.move({ x = 2280, y = 190, window = "address:" .. w.address }))
  end
end)

-- YTDL-PY
hl.window_rule({ name = "ytdlpyrules", match = { class = "yt-dlp-gui.py" },
float = true, size = "1200 700", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

-- ANARCHY GUI INSTALLER
hl.window_rule({ name = "anarchinst", match = { class = "com.anarchy.installer" },
float = true, size = "1200 700", center = true, border_size = 2, opacity = "1", animation = "slide top", 
border_color = theme.color2 .. " " .. theme.color15 })

