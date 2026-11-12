-- Autostart

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("/usr/bin/hyprscratch init")
    hl.exec_cmd("coolercontrol")
    hl.exec_cmd("/usr/local/bin/awww.sh")
    hl.exec_cmd("/usr/local/bin/Anarchy-Launcher")
    hl.exec_cmd("~/.local/share/themes/hypr-theme-active.sh")
    hl.exec_cmd("wal --theme ~/.config/pywal/themes/active.json")
    hl.exec_cmd("sleep 3 && arch-update --tray")
end)
