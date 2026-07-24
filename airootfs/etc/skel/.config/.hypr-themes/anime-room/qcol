import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Scope {
    id: theme

    property color background: "#090b15"
    property color foreground: "#c1c2c4"
    property color color1: "#981C71"
    property color color2: "#096B94"
    property color color3: "#EA58B4"
    property color color4: "#CA4AA7"
    property color color5: "#614D93"
    property color color6: "#29ACCC"
    property color muted: "#585b6c"

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
