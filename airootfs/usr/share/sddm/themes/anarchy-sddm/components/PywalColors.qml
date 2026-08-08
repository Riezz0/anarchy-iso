import QtQuick

Item {
    id: pywalColors

    property bool loaded: false
    property color background: "#1a1b26"
    property color foreground: "#c0caf5"
    property color color0: "#15161e"
    property color color1: "#f7768e"
    property color color2: "#9ece6a"
    property color color3: "#e0af68"
    property color color4: "#7aa2f7"
    property color color5: "#bb9af7"
    property color color6: "#7dcfff"
    property color color7: "#a9b1d6"
    property color color8: "#414868"
    property color color9: "#f7768e"
    property color color10: "#9ece6a"
    property color color11: "#e0af68"
    property color color12: "#7aa2f7"
    property color color13: "#bb9af7"
    property color color14: "#7dcfff"
    property color color15: "#c0caf5"

    Loader {
        id: pywalLoader
        source: "/var/local/sddm-wallpaper/PywalColors.qml"
        active: true
        onLoaded: {
            if (pywalLoader.item) {
                var item = pywalLoader.item
                pywalColors.background = item.background
                pywalColors.foreground = item.foreground
                pywalColors.color0 = item.color0
                pywalColors.color1 = item.color1
                pywalColors.color2 = item.color2
                pywalColors.color3 = item.color3
                pywalColors.color4 = item.color4
                pywalColors.color5 = item.color5
                pywalColors.color6 = item.color6
                pywalColors.color7 = item.color7
                pywalColors.color8 = item.color8
                pywalColors.color9 = item.color9
                pywalColors.color10 = item.color10
                pywalColors.color11 = item.color11
                pywalColors.color12 = item.color12
                pywalColors.color13 = item.color13
                pywalColors.color14 = item.color14
                pywalColors.color15 = item.color15
                pywalColors.loaded = true
                console.log("Pywal colors loaded from QML")
            }
        }
        onStatusChanged: {
            if (pywalLoader.status === Loader.Error) {
                console.log("Failed to load pywal colors QML:", pywalLoader.errorString)
            }
        }
    }
}