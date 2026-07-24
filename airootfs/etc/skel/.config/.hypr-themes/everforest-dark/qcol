import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Scope {
    id: theme

    property color background: "#272e33"
    property color foreground: "#d8caac"
    property color color1: "#e67e80"
    property color color2: "#a7c080"
    property color color3: "#dbbc7f"
    property color color4: "#7fbbb3"
    property color color5: "#d39bb6"
    property color color6: "#83c092"
    property color muted: "#868d80"

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
