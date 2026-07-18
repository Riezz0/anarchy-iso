// ═══════════════════════════════════════════════════════════════════════════════
// KeybindsPopup - Keybinds Reference Overlay
// ═══════════════════════════════════════════════════════════════════════════════
// Displays Hyprland and Kitty keybinds organized by category.
// Reads from ~/.config/hypr/modules/binds.lua and ~/.config/kitty/kitty.conf
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: keybindsRoot

    // ── Data Model ────────────────────────────────────────────────────────
    property bool   isOpen: root.keybindsPopupOpen
    property var    hyprCategories: []
    property var    kittyBinds: []

    function close() { root.keybindsPopupOpen = false }

    onIsOpenChanged: {
        if (isOpen) {
            loadBinds()
        }
    }

    function loadBinds() {
        hyprCategories = []
        kittyBinds = []

        hyprReadProc.buffer = ""
        hyprReadProc.command = ["sh", "-c", "cat ~/.config/hypr/modules/binds.lua"]
        hyprReadProc.running = true

        kittyReadProc.buffer = ""
        kittyReadProc.command = ["sh", "-c", "cat ~/.config/kitty/kitty.conf"]
        kittyReadProc.running = true
    }

    function parseHyprBinds(content) {
        var categories = {
            "Session Management": [],
            "Scratchpads": [],
            "App Launch": [],
            "Window Management": [],
            "Workspace Management": [],
            "Volume Control": [],
            "Testing": []
        }

        var lines = content.split("\n")
        var currentCategory = "Other"

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()

            if (line.startsWith("--")) {
                var catMatch = line.match(/^--\s*(.+?)(?:\s*-+)?$/)
                if (catMatch) {
                    var catName = catMatch[1].trim()
                    if (categories.hasOwnProperty(catName)) {
                        currentCategory = catName
                    } else if (catName !== "Main Mod Variable") {
                        currentCategory = catName
                        if (!categories.hasOwnProperty(currentCategory)) {
                            categories[currentCategory] = []
                        }
                    }
                }
                continue
            }

            var bindMatch = line.match(/hl\.bind\(\s*["'](.*?)["']/)
            var concatMatch = line.match(/hl\.bind\(\s*mainMod\s*\.\.\s*["'](.*?)["']/)

            var bind = null
            if (concatMatch) {
                bind = "SUPER" + concatMatch[1]
            } else if (bindMatch) {
                bind = bindMatch[1]
            }

            if (bind) {
                var descMatch = line.match(/description\s*=\s*["'](.*?)["']/)
                var desc = descMatch ? descMatch[1] : bind

                // Skip incomplete binds from for-loop concatenation
                if (bind.endsWith(" + ") || bind.endsWith(" +")) continue

                if (!categories.hasOwnProperty(currentCategory)) {
                    categories[currentCategory] = []
                }
                categories[currentCategory].push({bind: bind, description: desc})
            }
        }

        var result = []
        var order = ["Session Management", "App Launch", "Window Management",
                    "Workspace Management", "Scratchpads", "Volume Control", "Testing"]

        for (var j = 0; j < order.length; j++) {
            if (categories[order[j]] && categories[order[j]].length > 0) {
                result.push({name: order[j], binds: categories[order[j]]})
            }
        }

        for (var cat in categories) {
            if (categories[cat].length > 0 && order.indexOf(cat) === -1) {
                result.push({name: cat, binds: categories[cat]})
            }
        }

        return result
    }

    function parseKittyBinds(content) {
        var binds = []
        var lines = content.split("\n")
        var inBindsSection = false

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()

            if (line === "#Binds") {
                inBindsSection = true
                continue
            }

            if (inBindsSection && line.startsWith("#") && line !== "#Binds") {
                break
            }

            if (inBindsSection && line.startsWith("map ")) {
                var parts = line.split(/\s+/)
                if (parts.length >= 3) {
                    var bind = parts[1]
                    var action = parts.slice(2).join(" ")

                    var desc = action.replace(/_/g, " ").replace(/\b\w/g, function(l) {
                        return l.toUpperCase()
                    })

                    binds.push({bind: bind, description: desc})
                }
            }
        }

        return binds
    }

    // ── File Reading Processes ─────────────────────────────────────────────
    Process {
        id:      hyprReadProc
        running: false
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => hyprReadProc.buffer += data + "\n"
        }
        onRunningChanged: {
            if (!running && buffer.length > 0) {
                keybindsRoot.hyprCategories = keybindsRoot.parseHyprBinds(buffer)
                buffer = ""
            }
        }
    }

    Process {
        id:      kittyReadProc
        running: false
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => kittyReadProc.buffer += data + "\n"
        }
        onRunningChanged: {
            if (!running && buffer.length > 0) {
                keybindsRoot.kittyBinds = keybindsRoot.parseKittyBinds(buffer)
                buffer = ""
            }
        }
    }

    // ── Popup Windows ─────────────────────────────────────────────────────
    Variants {
        model: [Quickshell.screens[1]]

        PanelWindow {
            screen:  modelData
            visible: keybindsRoot.isOpen
            required property var modelData

            anchors { top: true; bottom: true; left: true; right: true }

            color:     "transparent"
            focusable: keybindsRoot.isOpen

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: keybindsRoot.isOpen
                ? WlrKeyboardFocus.OnDemand
                : WlrKeyboardFocus.None

            // Dim backdrop
            Rectangle {
                anchors.fill: parent
                color:        Qt.rgba(theme.background.r, theme.background.g, theme.background.b, 0.72)

                MouseArea {
                    anchors.fill: parent
                    onClicked:    keybindsRoot.close()
                }
            }

            // Dialog
            Item {
                anchors.fill: parent
                focus:        keybindsRoot.isOpen
                Keys.onEscapePressed: keybindsRoot.close()

                Rectangle {
                    anchors.centerIn: parent
                    width:            1200
                    height:           700
                    radius:           5
                    color:            theme.background
                    border { color: theme.color2; width: 2 }

                    MouseArea {
                        anchors.fill: parent
                        onClicked:    mouse => mouse.accepted = true
                    }

                    ColumnLayout {
                        id:               keybindsColumn
                        anchors.fill:     parent
                        anchors.margins:  16
                        spacing:          8

                        // Header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text:             "󰌌"
                                font.pixelSize:   22
                                color:            theme.color2
                            }

                            Text {
                                text:             "Keybinds"
                                color:            theme.foreground
                                font.pixelSize:   16
                                font.bold:        true
                                Layout.fillWidth: true
                            }

                            Text {
                                text:             "ESC"
                                color:            theme.muted
                                font.pixelSize:   12
                                font.bold:        true
                                font.family:      "JetBrains Mono Nerd Font Mono"
                                Layout.alignment: Qt.AlignVCenter

                                Rectangle {
                                    anchors.fill:    parent
                                    anchors.margins: -4
                                    radius:          3
                                    color:           "transparent"
                                    border { color: theme.muted; width: 2 }
                                    z:               -1
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight:   2
                            color:            theme.color2
                            opacity:          0.3
                        }
                        ScrollView {
                            Layout.fillWidth:  true
                            Layout.fillHeight: true
                            clip:              true

                            ColumnLayout {
                                width:           parent.width
                                spacing:          12

                                // Hyprland section header
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight:   1
                                        color:            theme.color2
                                        opacity:          0.3
                                    }

                                    Text {
                                        text:             "HYPRLAND"
                                        color:            theme.color2
                                        font.pixelSize:   12
                                        font.bold:        true
                                        font.family:      "JetBrains Mono Nerd Font Mono"
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight:   1
                                        color:            theme.color2
                                        opacity:          0.3
                                    }
                                }

                                // Hyprland categories
                                Repeater {
                                    model: keybindsRoot.hyprCategories

                                    ColumnLayout {
                                        required property var modelData
                                        required property int index
                                        spacing: 4

                                        Text {
                                            text:             modelData.name.toUpperCase()
                                            color:            theme.color4
                                            font.pixelSize:   13
                                            font.bold:        true
                                            font.family:      "JetBrains Mono Nerd Font Mono"
                                            Layout.topMargin: index > 0 ? 8 : 0
                                        }

                                Repeater {
                                    model: modelData.binds

                                    RowLayout {
                                        required property var modelData
                                        spacing: 16

                                        Rectangle {
                                            Layout.preferredWidth: 260
                                            implicitHeight:   bindText.implicitHeight + 10
                                            radius:           3
                                            color:            Qt.darker(theme.background, 1.2)

                                            Text {
                                                id:               bindText
                                                anchors.left:     parent.left
                                                anchors.leftMargin: 8
                                                anchors.verticalCenter: parent.verticalCenter
                                                text:             modelData.bind
                                                color:            theme.color2
                                                font.pixelSize:   12
                                                font.bold:        true
                                                font.family:      "JetBrains Mono Nerd Font Mono"
                                            }
                                        }

                                        Text {
                                            text:             modelData.description
                                            color:            theme.muted
                                            font.pixelSize:   12
                                            horizontalAlignment: Text.AlignLeft
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                                    }
                                }

                                // Kitty section header
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    Layout.topMargin: 8

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight:   2
                                        color:            theme.color3
                                        opacity:          0.3
                                    }

                                    Text {
                                        text:             "KITTY"
                                        color:            theme.color3
                                        font.pixelSize:   12
                                        font.bold:        true
                                        font.family:      "JetBrains Mono Nerd Font Mono"
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight:   2
                                        color:            theme.color3
                                        opacity:          0.3
                                    }
                                }

                                // Kitty binds
                                Repeater {
                                    model: keybindsRoot.kittyBinds

                                    RowLayout {
                                        required property var modelData
                                        spacing: 16

                                        Rectangle {
                                            Layout.preferredWidth: 260
                                            implicitHeight:   kittyBindText.implicitHeight + 10
                                            radius:           3
                                            color:            Qt.darker(theme.background, 1.2)

                                            Text {
                                                id:               kittyBindText
                                                anchors.left:     parent.left
                                                anchors.leftMargin: 8
                                                anchors.verticalCenter: parent.verticalCenter
                                                text:             modelData.bind
                                                color:            theme.color3
                                                font.pixelSize:   12
                                                font.bold:        true
                                                font.family:      "JetBrains Mono Nerd Font Mono"
                                            }
                                        }

                                        Text {
                                            text:             modelData.description
                                            color:            theme.muted
                                            font.pixelSize:   12
                                            horizontalAlignment: Text.AlignLeft
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}