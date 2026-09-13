import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Scope {
    id: theme

    signal colorsChanged()

    property color background: "#1a1b26"
    property color foreground: "#c0caf5"
    property color color0: "#1a1b26"
    property color color1: "#f7768e"
    property color color2: "#9ece6a"
    property color color3: "#e0af68"
    property color color4: "#7aa2f7"
    property color color5: "#bb9af7"
    property color color6: "#7dcfff"
    property color color7: "#a9b1d6"
    property color color8: "#414868"
    property color color9: "#ff899d"
    property color color10: "#9fe044"
    property color color11: "#faba4a"
    property color color12: "#8db0ff"
    property color color13: "#c7a9ff"
    property color color14: "#a4daff"
    property color color15: "#c0caf5"
    property color muted: "#414868"

    readonly property string walColorsPath:
        StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.cache/wal/colors.json"

    onBackgroundChanged: {
        console.log("Anarchy-Bar: theme refreshed — bg:", background)
        colorsChanged()
    }

    function applyWalColors() {
        if (!colorFile.loaded)
            return

        try {
            const data = JSON.parse(colorFile.text())
            const newBg = Qt.lighter(data.special.background, 1)
            if (background !== newBg) {
                background = data.special.background
                foreground = data.special.foreground
                color0 = data.colors.color0
                color1 = data.colors.color1
                color2 = data.colors.color2
                color3 = data.colors.color3
                color4 = data.colors.color4
                color5 = data.colors.color5
                color6 = data.colors.color6
                color7 = data.colors.color7
                color8 = data.colors.color8
                color9 = data.colors.color9
                color10 = data.colors.color10
                color11 = data.colors.color11
                color12 = data.colors.color12
                color13 = data.colors.color13
                color14 = data.colors.color14
                color15 = data.colors.color15
                muted = data.colors.color8
            }
        } catch (e) {
            console.warn("Anarchy-Bar: failed to parse pywal colors:", e)
        }
    }

    FileView {
        id: colorFile
        path: theme.walColorsPath
        watchChanges: true
        onLoaded: theme.applyWalColors()
        onFileChanged: theme.applyWalColors()
    }

    // Polling fallback — pywal writes atomically (temp + rename) which breaks inotify
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: colorFile.reload()
    }
}
