import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    model: barSettings.popupScreens()

    PanelWindow {
        id: settingsWindow
        screen:  modelData
        visible: panelVisible
        required property var modelData

        property bool panelVisible: false

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: settingsPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: settingsPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        Connections {
            target: settingsPopup
            function onIsOpenChanged() {
                if (settingsPopup.isOpen) { panelVisible = true }
                else { hideTimer.start() }
            }
        }

        Timer { id: hideTimer; interval: 220; onTriggered: panelVisible = false }

        MouseArea {
            anchors.fill: parent
            onClicked:    settingsPopup.close()
            opacity: settingsPopup.isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

            property bool appearanceExpanded: false
            property bool displayExpanded: false
            property bool placementExpanded: false
            property bool monitorMenuOpen: false

        Rectangle {
            id: settingsPanel
            anchors.right:    parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10
            width:    380
            height:   settingsCol.implicitHeight + 32
            radius:   barSettings.barRadius
            color:    theme.background
            opacity:  settingsPopup.isOpen ? 0.95 : 0
            scale:    settingsPopup.isOpen ? 1.0 : 0.95
            x:        settingsPopup.isOpen ? 0 : 20
            border { width: barSettings.borderThickness; color: theme.color5 }

            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on x       { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

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
                        font.pixelSize: 20
                        font.family:    "JetBrains Mono Nerd Font Mono"
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
                            text:           "󰏘"
                            font.pixelSize: 14
                            font.family:    "JetBrains Mono Nerd Font Mono"
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
                            text:           "Hyprland Window Radius"
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

                    // ── Border Thickness ──────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8

                        Text {
                            text:           "Bar Border Thickness"
                            font.pixelSize: 13
                            color:          theme.foreground
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: borderThicknessLabel.implicitWidth + 12
                            height: 22
                            radius: 4
                            color: Qt.darker(theme.muted, 1.2)

                            Text {
                                id: borderThicknessLabel
                                anchors.centerIn: parent
                                text:           Math.round(barSettings.borderThickness) + "px"
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
                                width: borderThicknessSliderMouse.sliderPos * parent.width
                                height: parent.height
                                radius: 3
                                color: theme.color1
                            }
                        }

                        Rectangle {
                            x: borderThicknessSliderMouse.sliderPos * (parent.width - width)
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            radius: 10
                            color: borderThicknessSliderMouse.pressed ? Qt.lighter(theme.color1, 1.3) : (borderThicknessSliderMouse.containsMouse ? Qt.lighter(theme.color1, 1.1) : theme.color1)
                            border { width: 2; color: theme.foreground }
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        MouseArea {
                            id: borderThicknessSliderMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            property bool pressed: false
                            property real sliderPos: barSettings.borderThickness / 5

                            function updateValue(mouseX) {
                                var pos = Math.max(0, Math.min(1, mouseX / width))
                                var val = Math.round(pos * 5)
                                barSettings.setBorderThickness(val)
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
                            model: [0, 1, 2, 3, 4, 5]

                            Column {
                                required property int modelData
                                x: (modelData / 5) * parent.width
                                spacing: 2

                                Rectangle { width: 1; height: 4; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: modelData; font.pixelSize: 9; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }

                    // ── Hyprland Window Border Thickness ────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8

                        Text {
                            text:           "Hyprland Window Border Thickness"
                            font.pixelSize: 13
                            color:          theme.foreground
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: hyprBorderThicknessLabel.implicitWidth + 12
                            height: 22
                            radius: 4
                            color: Qt.darker(theme.muted, 1.2)

                            Text {
                                id: hyprBorderThicknessLabel
                                anchors.centerIn: parent
                                text:           Math.round(barSettings.hyprlandBorderThickness) + "px"
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
                                width: hyprBorderThicknessSliderMouse.sliderPos * parent.width
                                height: parent.height
                                radius: 3
                                color: theme.color3
                            }
                        }

                        Rectangle {
                            x: hyprBorderThicknessSliderMouse.sliderPos * (parent.width - width)
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            radius: 10
                            color: hyprBorderThicknessSliderMouse.pressed ? Qt.lighter(theme.color3, 1.3) : (hyprBorderThicknessSliderMouse.containsMouse ? Qt.lighter(theme.color3, 1.1) : theme.color3)
                            border { width: 2; color: theme.foreground }
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        MouseArea {
                            id: hyprBorderThicknessSliderMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            property bool pressed: false
                            property real sliderPos: barSettings.hyprlandBorderThickness / 5

                            function updateValue(mouseX) {
                                var pos = Math.max(0, Math.min(1, mouseX / width))
                                var val = Math.round(pos * 5)
                                barSettings.setHyprlandBorderThickness(val)
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
                            model: [0, 1, 2, 3, 4, 5]

                            Column {
                                required property int modelData
                                x: (modelData / 5) * parent.width
                                spacing: 2

                                Rectangle { width: 1; height: 4; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: modelData; font.pixelSize: 9; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }

                    // ── Bar Opacity ──────────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8

                        Text {
                            text:           "Bar Opacity"
                            font.pixelSize: 13
                            color:          theme.foreground
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: barOpacityLabel.implicitWidth + 12
                            height: 22
                            radius: 4
                            color: Qt.darker(theme.muted, 1.2)

                            Text {
                                id: barOpacityLabel
                                anchors.centerIn: parent
                                text:           Math.round(barSettings.barOpacity * 100) + "%"
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
                                width: barOpacitySliderMouse.sliderPos * parent.width
                                height: parent.height
                                radius: 3
                                color: theme.color4
                            }
                        }

                        Rectangle {
                            x: barOpacitySliderMouse.sliderPos * (parent.width - width)
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            radius: 10
                            color: barOpacitySliderMouse.pressed ? Qt.lighter(theme.color4, 1.3) : (barOpacitySliderMouse.containsMouse ? Qt.lighter(theme.color4, 1.1) : theme.color4)
                            border { width: 2; color: theme.foreground }
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        MouseArea {
                            id: barOpacitySliderMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            property bool pressed: false
                            property real sliderPos: barSettings.barOpacity

                            function updateValue(mouseX) {
                                var pos = Math.max(0, Math.min(1, mouseX / width))
                                var val = Math.round(pos * 20) / 20
                                barSettings.setBarOpacity(val)
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
                            model: [0, 25, 50, 75, 100]

                            Column {
                                required property int modelData
                                x: (modelData / 100) * parent.width
                                spacing: 2

                                Rectangle { width: 1; height: 4; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: modelData + "%"; font.pixelSize: 9; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }

                    // ── Hyprland Window Transparency ────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8

                        Text {
                            text:           "Hyprland Window Transparency"
                            font.pixelSize: 13
                            color:          theme.foreground
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: hyprOpacityLabel.implicitWidth + 12
                            height: 22
                            radius: 4
                            color: Qt.darker(theme.muted, 1.2)

                            Text {
                                id: hyprOpacityLabel
                                anchors.centerIn: parent
                                text:           Math.round(barSettings.hyprlandWindowOpacity * 100) + "%"
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
                                width: hyprOpacitySliderMouse.sliderPos * parent.width
                                height: parent.height
                                radius: 3
                                color: theme.color5
                            }
                        }

                        Rectangle {
                            x: hyprOpacitySliderMouse.sliderPos * (parent.width - width)
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            radius: 10
                            color: hyprOpacitySliderMouse.pressed ? Qt.lighter(theme.color5, 1.3) : (hyprOpacitySliderMouse.containsMouse ? Qt.lighter(theme.color5, 1.1) : theme.color5)
                            border { width: 2; color: theme.foreground }
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        MouseArea {
                            id: hyprOpacitySliderMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            property bool pressed: false
                            property real sliderPos: barSettings.hyprlandWindowOpacity

                            function updateValue(mouseX) {
                                var pos = Math.max(0, Math.min(1, mouseX / width))
                                var val = Math.round(pos * 20) / 20
                                barSettings.setHyprlandWindowOpacity(val)
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
                            model: [0, 25, 50, 75, 100]

                            Column {
                                required property int modelData
                                x: (modelData / 100) * parent.width
                                spacing: 2

                                Rectangle { width: 1; height: 4; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: modelData + "%"; font.pixelSize: 9; color: theme.muted; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }
                }

                // ════════════════════════════════════════════════════════
                // Display Settings Section (Collapsible)
                // ════════════════════════════════════════════════════════
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 4
                    color: displayHover.containsMouse ? Qt.darker(theme.background, 1.2) : "transparent"

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Text {
                            text:           settingsWindow.displayExpanded ? "▼" : "▶"
                            font.pixelSize: 10
                            color:          theme.color2
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:           "󰍹"
                            font.pixelSize: 14
                            font.family:    "JetBrains Mono Nerd Font Mono"
                            color:          theme.color2
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:           "Display Settings"
                            font.pixelSize: 13
                            font.bold:      true
                            color:          theme.color2
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: displayHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    settingsWindow.displayExpanded = !settingsWindow.displayExpanded
                    }
                }

                Item { Layout.fillWidth: true; height: 8; visible: settingsWindow.displayExpanded }

                // ── Display Settings Content ────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: settingsWindow.displayExpanded
                    spacing: 0

                    // ── Nightlight Toggle ──────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text:           "Night Light"
                                font.pixelSize: 13
                                color:          theme.foreground
                            }

                            Text {
                                text:           "Reduce blue light for better sleep"
                                font.pixelSize: 10
                                color:          theme.muted
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: 44
                            height: 24
                            radius: 12
                            color: barSettings.nightlightEnabled ? theme.color2 : Qt.darker(theme.muted, 1.2)
                            border { width: 1; color: barSettings.nightlightEnabled ? theme.color2 : theme.muted }

                            Rectangle {
                                x: barSettings.nightlightEnabled ? parent.width - width - 2 : 2
                                anchors.verticalCenter: parent.verticalCenter
                                width: 20
                                height: 20
                                radius: 10
                                color: theme.foreground
                                Behavior on x { NumberAnimation { duration: 120 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    barSettings.setNightlight(!barSettings.nightlightEnabled)
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
                            font.family:    "JetBrains Mono Nerd Font Mono"
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
