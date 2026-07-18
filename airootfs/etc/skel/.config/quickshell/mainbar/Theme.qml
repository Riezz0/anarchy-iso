import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Scope {
    id: theme

    property color background: "#1a1b26"
    property color foreground: "#c0caf5"
    property color color1: "#f7768e"
    property color color2: "#9ece6a"
    property color color3: "#e0af68"
    property color color4: "#7aa2f7"
    property color color5: "#bb9af7"
    property color color6: "#7dcfff"
    property color muted: "#414868"

    readonly property string walColorsPath:
        StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.cache/wal/colors.json"

    function applyWalColors() {
        if (!colorFile.loaded)
            return

        try {
            const data = JSON.parse(colorFile.text())
            background = data.special.background
            foreground = data.special.foreground
            accent = data.colors.color4
            red = data.colors.color1
            green = data.colors.color2
            yellow = data.colors.color3
            blue = data.colors.color4
            magenta = data.colors.color5
            cyan = data.colors.color6
            muted = data.colors.color8
        } catch (e) {
            console.warn("powerbar: failed to parse pywal colors:", e)
        }
    }

    FileView {
        id: colorFile
        path: theme.walColorsPath
        watchChanges: true
        onLoaded: theme.applyWalColors()
        onFileChanged: theme.applyWalColors()
    }
}
