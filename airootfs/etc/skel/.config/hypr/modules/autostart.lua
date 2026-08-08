-- Autostart

hl.on("hyprland.start", function () 
hl.exec_cmd("pypr")
hl.exec_cmd("awww-daemon")
hl.exec_cmd("~/.local/share/themes/hypr-theme-active.sh")
hl.exec_cmd("wal --theme ~/.config/pywal/themes/active.json")
hl.exec_cmd("/usr/local/bin/awww.sh")
hl.exec_cmd("/usr/local/bin/qbarmain.sh")
hl.exec_cmd("/usr/local/bin/welcome.sh")
hl.exec_cmd("python3 /usr/local/bin/anarchy-gui.py")
hl.exec_cmd("arch-update --tray")
end)
