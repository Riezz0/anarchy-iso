import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    model: barSettings.popupScreens()

    PanelWindow {
        id: settingsWindow
        screen:  modelData
        visible: settingsPopup.isOpen
        required property var modelData

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: settingsPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: settingsPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        MouseArea {
            anchors.fill: parent
            onClicked:    settingsPopup.close()
        }

            property bool appearanceExpanded: false
            property bool placementExpanded: false
            property bool monitorMenuOpen: false

        Rectangle {
            anchors.right:    parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10
            width:    380
            height:   settingsCol.implicitHeight + 32
            radius:   barSettings.barRadius
            color:    theme.background
            opacity:  0.95
            border { width: 2; color: theme.color5 }

            ColumnLayout {
                id:   settingsCol
                anchors.fill: parent
                anchors.margins: 16
                spacing: 0

                // ── Header ─────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text:           "󰒓"
                        font.pixelSize: 18
                        color:          theme.color5
                    }

                    Text {
                        text:           "Settings"
                        font.pixelSize: 16
                        font.bold:      true
                        color:          theme.foreground
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: closeArea.containsMouse ? Qt.darker(theme.muted, 1.3) : theme.muted

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 12
                            color: theme.foreground
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    settingsPopup.close()
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.muted; opacity: 0.4; Layout.topMargin: 12; Layout.bottomMargin: 12 }

                // ════════════════════════════════════════════════════════
                // Appearance Section (Collapsible)
                // ════════════════════════════════════════════════════════
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 4
                    color: apprHover.containsMouse ? Qt.darker(theme.background, 1.2) : "transparent"

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Text {
                            text:           settingsWindow.appearanceExpanded ? "▼" : "▶"
                            font.pixelSize: 10
                            color:          theme.color6
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:           "󰔉"
                            font.pixelSize: 14
                            color:          theme.color6
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:           "Appearance"
                            font.pixelSize: 13
                            font.bold:      true
                            color:          theme.color6
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: apprHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    settingsWindow.appearanceExpanded = !settingsWindow.appearanceExpanded
                    }
                }

                Item { Layout.fillWidth: true; height: 8; visible: settingsWindow.appearanceExpanded }

                // ── Appearance Content ──────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: settingsWindow.appearanceExpanded
                    spacing: 0

                    // ── Bar Radius ──────────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8

                        Text {
                            text:           "Bar Radius"
                            font.pixelSize: 13
                            color:          theme.foreground
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: radiusLabel.implicitWidth + 12
                            height: 22
                            radius: 4
                            color: Qt.darker(theme.muted, 1.2)

                            Text {
                                id: radiusLabel
                                anchors.centerIn: parent
                                text:           Math.round(barSettings.barRadius) + "px"
                                font.pixelSize: 12
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.foreground
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 6
                            radius: 3
                            color: Qt.darker(theme.muted, 1.2)

                            Rectangle {
                                width: sliderMouse.sliderPos * parent.width
                                height: parent.height
                                radius: 3
                                color: theme.color5
                            }
                        }

                        Rectangle {
                            x: sliderMouse.sliderPos * (parent.width - width)
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            radius: 10
                            color: sliderMouse.pressed ? Qt.lighter(theme.color5, 1.3) : (sliderMouse.containsMouse ? Qt.lighter(theme.color5, 1.1) : theme.color5)
                            border { width: 2; color: theme.foreground }
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        MouseArea {
                            id: sliderMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            property bool pressed: false
                            property real sliderPos: barSettings.barRadius / 30

                            function updateValue(mouseX) {
                                var pos = Math.max(0, Math.min(1, mouseX / width))
                                var val = Math.round(pos * 30)
                                barSettings.setBarRadius(val)
                            }

                            onPressed: mouse => { pressed = true; updateValue(mouse.x) }
                            onReleased: pressed = false
                            onPositionChanged: mouse => { if (pressed) updateValue(mouse.x) }
                            onClicked: mouse => updateValue(mouse.x)
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Layout.bottomMargin: 12

                        Repeater {
                            model: [0, 5, 10, 15, 20, 25, 30]

                            Column {
                                required property int modelData
                                x: (modelData / 30) * (parent.width - 16) + 8
                                spacing: 2

                                Rectangle { width: 1; height: 4; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: modelData; font.pixelSize: 9; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }

                    // ── Window Radius ───────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8

                        Text {
                            text:           "Window Radius"
                            font.pixelSize: 13
                            color:          theme.foreground
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: hyprRadiusLabel.implicitWidth + 12
                            height: 22
                            radius: 4
                            color: Qt.darker(theme.muted, 1.2)

                            Text {
                                id: hyprRadiusLabel
                                anchors.centerIn: parent
                                text:           Math.round(barSettings.hyprlandRadius) + "px"
                                font.pixelSize: 12
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.foreground
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 6
                            radius: 3
                            color: Qt.darker(theme.muted, 1.2)

                            Rectangle {
                                width: hyprSliderMouse.sliderPos * parent.width
                                height: parent.height
                                radius: 3
                                color: theme.color3
                            }
                        }

                        Rectangle {
                            x: hyprSliderMouse.sliderPos * (parent.width - width)
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            radius: 10
                            color: hyprSliderMouse.pressed ? Qt.lighter(theme.color3, 1.3) : (hyprSliderMouse.containsMouse ? Qt.lighter(theme.color3, 1.1) : theme.color3)
                            border { width: 2; color: theme.foreground }
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        MouseArea {
                            id: hyprSliderMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            property bool pressed: false
                            property real sliderPos: barSettings.hyprlandRadius / 30

                            function updateValue(mouseX) {
                                var pos = Math.max(0, Math.min(1, mouseX / width))
                                var val = Math.round(pos * 30)
                                barSettings.setHyprlandRadius(val)
                            }

                            onPressed: mouse => { pressed = true; updateValue(mouse.x) }
                            onReleased: pressed = false
                            onPositionChanged: mouse => { if (pressed) updateValue(mouse.x) }
                            onClicked: mouse => updateValue(mouse.x)
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Layout.bottomMargin: 8

                        Repeater {
                            model: [0, 5, 10, 15, 20, 25, 30]

                            Column {
                                required property int modelData
                                x: (modelData / 30) * (parent.width - 16) + 8
                                spacing: 2

                                Rectangle { width: 1; height: 4; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: modelData; font.pixelSize: 9; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }
                }

                // ════════════════════════════════════════════════════════
                // Bar Placement Section (Collapsible)
                // ════════════════════════════════════════════════════════
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 4
                    color: placementHover.containsMouse ? Qt.darker(theme.background, 1.2) : "transparent"

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Text {
                            text:           settingsWindow.placementExpanded ? "▼" : "▶"
                            font.pixelSize: 10
                            color:          theme.color4
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:           "󰍹"
                            font.pixelSize: 14
                            color:          theme.color4
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:           "Bar Placement"
                            font.pixelSize: 13
                            font.bold:      true
                            color:          theme.color4
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: placementHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    settingsWindow.placementExpanded = !settingsWindow.placementExpanded
                    }
                }

                Item { Layout.fillWidth: true; height: 8; visible: settingsWindow.placementExpanded }

                // ── Placement Content ──────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: settingsWindow.placementExpanded
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:           "Show on:"
                            font.pixelSize: 13
                            color:          theme.foreground
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            id: monitorComboRect
                            implicitWidth: Math.min(monitorCombo.implicitWidth + 16, settingsCol.width * 0.5)
                            height: 28
                            radius: 4
                            color: monitorComboArea.containsMouse ? Qt.darker(theme.muted, 1.3) : Qt.darker(theme.muted, 1.2)
                            border { width: 1; color: theme.muted }

                            Text {
                                id: monitorCombo
                                anchors.centerIn: parent
                                text:           barSettings.monitorDisplayName(barSettings.barMonitor)
                                font.pixelSize: 12
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.foreground
                                elide:          Text.ElideRight
                                width:          parent.width - 16
                            }

                            MouseArea {
                                id: monitorComboArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    settingsWindow.monitorMenuOpen = !settingsWindow.monitorMenuOpen
                            }
                        }
                    }

                    // ── Bar Position ──────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8

                        Text {
                            text:           "Position:"
                            font.pixelSize: 13
                            color:          theme.foreground
                        }

                        Item { Layout.fillWidth: true }

                        Repeater {
                            model: [
                                { label: "Top",    value: "top",    icon: "󰁽" },
                                { label: "Bottom", value: "bottom", icon: "󰁼" }
                            ]

                            Rectangle {
                                required property var modelData
                                required property int index

                                width: 60
                                height: 28
                                radius: 4
                                color: barSettings.barPosition === modelData.value
                                    ? theme.color4
                                    : posArea.containsMouse
                                        ? Qt.darker(theme.muted, 1.3)
                                        : Qt.darker(theme.muted, 1.2)
                                border { width: 1; color: barSettings.barPosition === modelData.value ? theme.color4 : theme.muted }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        text:           modelData.icon
                                        font.pixelSize: 12
                                        color:          barSettings.barPosition === modelData.value ? theme.background : theme.foreground
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text:           modelData.label
                                        font.pixelSize: 11
                                        font.bold:      true
                                        color:          barSettings.barPosition === modelData.value ? theme.background : theme.foreground
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    id: posArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked:    barSettings.setBarPosition(modelData.value)
                                }

                                Behavior on color { ColorAnimation { duration: 100 } }
                            }
                        }
                    }

                    // Monitor dropdown menu
                    Rectangle {
                        id: monitorMenu
                        visible: settingsWindow.monitorMenuOpen
                        width: settingsCol.width - 32
                        height: monitorMenuCol.implicitHeight + 16
                        radius: 6
                        color: theme.background
                        border { width: 1; color: theme.color4 }
                        Layout.topMargin: 4
                        z: 100

                        ColumnLayout {
                            id: monitorMenuCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 2

                            Repeater {
                                model: barSettings.monitorList()

                                Rectangle {
                                    required property string modelData
                                    property bool isCurrent: barSettings.barMonitor === modelData
                                    property bool isHovered: monitorItemArea.containsMouse

                                    Layout.fillWidth: true
                                    height: 30
                                    radius: 4
                                    color: isHovered ? Qt.darker(theme.background, 1.3) : (isCurrent ? Qt.darker(theme.color4, 1.5) : "transparent")

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        Text {
                                            text:           barSettings.monitorDisplayName(modelData)
                                            font.pixelSize: 12
                                            font.bold:      isCurrent
                                            font.family:    "JetBrains Mono Nerd Font Mono"
                                            color:          isCurrent ? theme.color4 : theme.foreground
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Item { Layout.fillWidth: true }

                                        Text {
                                            visible: isCurrent
                                            text:           "✓"
                                            font.pixelSize: 12
                                            color:          theme.color4
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    MouseArea {
                                        id: monitorItemArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape:  Qt.PointingHandCursor
                                        onClicked: {
                                            barSettings.setBarMonitor(modelData)
                                            settingsWindow.monitorMenuOpen = false
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Close menu when clicking outside
                    Connections {
                        target: settingsWindow
                        function onVisibleChanged() {
                            if (!settingsWindow.visible)
                                settingsWindow.monitorMenuOpen = false
                        }
                    }
                }
            }
        }
    }
}
