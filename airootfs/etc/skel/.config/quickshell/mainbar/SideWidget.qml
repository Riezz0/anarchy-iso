import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Variants {
    model: barSettings.popupScreens()

    PanelWindow {
        screen:  modelData
        visible: panelVisible
        required property var modelData

        property bool panelVisible: false

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: sideWidgetOpen.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: sideWidgetOpen.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        Connections {
            target: sideWidgetOpen
            function onIsOpenChanged() {
                if (sideWidgetOpen.isOpen) { panelVisible = true }
                else { hideTimer.start() }
            }
        }

        Timer { id: hideTimer; interval: 220; onTriggered: panelVisible = false }

        Process {
            id: bluemanProc
            command: ["blueman-manager"]
            running: false
        }

        MouseArea {
            anchors.fill: parent
            onClicked:    sideWidgetOpen.close()
            opacity: sideWidgetOpen.isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Rectangle {
            id: sidePanel
            width:    320
            height:   Math.min(contentCol.implicitHeight + 32, parent.height - 20)
            radius:   barSettings.barRadius
            color:    theme.background
            opacity:  sideWidgetOpen.isOpen ? 0.95 : 0
            x:        sideWidgetOpen.isOpen ? parent.width - width - 10 : parent.width + 10
            y:        (parent.height - height) / 2
            clip:     true
            border { width: barSettings.borderThickness; color: theme.color4 }

            Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
            Behavior on x       { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id: contentCol
                anchors.fill:    parent
                anchors.margins: 16
                spacing: 0

                // ── Header ────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Layout.bottomMargin: 4

                    Text {
                        text:           "Welcome, Riezzo"
                        font.pixelSize: 16
                        font.bold:      true
                        color:          theme.foreground
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 24; height: 24
                        radius: 4
                        color: "transparent"
                        border { width: 1; color: theme.muted }

                        Text {
                            anchors.centerIn: parent
                            text:           "X"
                            font.pixelSize: 12
                            font.bold:      true
                            color:          theme.muted
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    sideWidgetOpen.close()
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: theme.muted; opacity: 0.4; Layout.bottomMargin: 12 }

                // ── Scrollable Content ────────────────────────────────
                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentSections.implicitHeight, sidePanel.parent.height - 120)
                    contentHeight: contentSections.implicitHeight
                    clip: true
                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {
                        policy: contentSections.implicitHeight > sidePanel.parent.height - 120
                                ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                        width: 6
                    }

                    ColumnLayout {
                        id: contentSections
                        width: parent.width
                        spacing: 8

                        // ════════════════════════════════════════════════
                        // 1. Clock Section
                        // ════════════════════════════════════════════════
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: clockCol.implicitHeight + 16
                            radius: barSettings.barRadius
                            color:  "transparent"
                            border { width: barSettings.borderThickness; color: theme.color4 }

                            ColumnLayout {
                                id: clockCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: 8
                                }
                                spacing: 2

                                Text {
                                    text:           root.clockTime
                                    font.pixelSize: 42
                                    font.bold:      true
                                    font.family:    "JetBrains Mono Nerd Font Mono"
                                    color:          theme.foreground
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text:           Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
                                    font.pixelSize: 12
                                    color:          theme.muted
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // ════════════════════════════════════════════════
                        // 2. Weather Section
                        // ════════════════════════════════════════════════
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: weatherSectionCol.implicitHeight + 16
                            radius: barSettings.barRadius
                            color:  "transparent"
                            border { width: barSettings.borderThickness; color: weatherSection.hovered ? theme.muted : theme.color4 }

                            property bool hovered: false

                            ColumnLayout {
                                id: weatherSectionCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: 8
                                }
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    Text {
                                        text:           weather.weatherIconText()
                                        font.pixelSize: 48
                                        color:          weatherSection.hovered ? theme.foreground : theme.color4
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    ColumnLayout {
                                        spacing: 2

                                        Text {
                                            text:           weather.loaded ? weather.tempDisplay() : "--"
                                            font.pixelSize: 28
                                            font.bold:      true
                                            font.family:    "JetBrains Mono Nerd Font Mono"
                                            color:          theme.foreground
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    ColumnLayout {
                                        spacing: 2

                                        Row {
                                            spacing: 4
                                            Text {
                                                text:           "󰈝"
                                                font.pixelSize: 11
                                                font.family:    "JetBrains Mono Nerd Font Mono"
                                                color:          theme.muted
                                            }
                                            Text {
                                                text:           weather.windSpeed || "--"
                                                font.pixelSize: 11
                                                color:          theme.muted
                                            }
                                        }

                                        Row {
                                            spacing: 4
                                            Text {
                                                text:           "󰈑"
                                                font.pixelSize: 11
                                                font.family:    "JetBrains Mono Nerd Font Mono"
                                                color:          theme.muted
                                            }
                                            Text {
                                                text:           weather.humidity || "--"
                                                font.pixelSize: 11
                                                color:          theme.muted
                                            }
                                        }

                                        Row {
                                            spacing: 4
                                            Text {
                                                text:           "󰈐"
                                                font.pixelSize: 11
                                                font.family:    "JetBrains Mono Nerd Font Mono"
                                                color:          theme.muted
                                            }
                                            Text {
                                                text:           weather.pressure || "--"
                                                font.pixelSize: 11
                                                color:          theme.muted
                                            }
                                        }
                                    }
                                }

                                Rectangle { Layout.fillWidth: true; height: 1; color: theme.muted; opacity: 0.2; Layout.topMargin: 4; Layout.bottomMargin: 4 }

                                Row {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    visible: weather.loaded

                                    Repeater {
                                        model: 6

                                        ColumnLayout {
                                            spacing: 2
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignHCenter

                                            Text {
                                                text:           {
                                                    var d = new Date()
                                                    d.setHours(d.getHours() + (index + 1))
                                                    var h = d.getHours()
                                                    var suffix = h >= 12 ? "PM" : "AM"
                                                    var h12 = h % 12 || 12
                                                    return h12 + suffix
                                                }
                                                font.pixelSize: 9
                                                color:          theme.muted
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.alignment: Qt.AlignHCenter
                                            }

                                            Text {
                                                text:           weather.weatherIconText()
                                                font.pixelSize: 14
                                                color:          theme.color4
                                                Layout.alignment: Qt.AlignHCenter
                                            }

                                            Text {
                                                text:           weather.loaded ? weather.tempDisplay() : "--"
                                                font.pixelSize: 10
                                                color:          theme.foreground
                                                font.family:    "JetBrains Mono Nerd Font Mono"
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    root.weatherPopupOpen = !root.weatherPopupOpen
                                onContainsMouseChanged: {
                                    weatherSection.hovered = containsMouse
                                }
                            }
                        }

                        // ════════════════════════════════════════════════
                        // 3. Keyboard Section
                        // ════════════════════════════════════════════════
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: kbdSectionCol.implicitHeight + 16
                            radius: barSettings.barRadius
                            color:  "transparent"
                            border { width: barSettings.borderThickness; color: kbdSection.hovered ? theme.muted : theme.color4 }

                            property bool hovered: false

                            ColumnLayout {
                                id: kbdSectionCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: 8
                                }
                                spacing: 6

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        text:           kbd.layoutIcon()
                                        font.pixelSize: 18
                                        color:          kbdSection.hovered ? theme.foreground : kbd.layoutColor()
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    Text {
                                        text:           "Keyboard"
                                        font.pixelSize: 14
                                        font.bold:      true
                                        color:          theme.foreground
                                    }

                                    Item { Layout.fillWidth: true }

                                    Rectangle {
                                        width: 28; height: 18
                                        radius: 4
                                        color: Qt.darker(theme.background, 1.3)
                                        border { width: 1; color: theme.muted }

                                        Text {
                                            anchors.centerIn: parent
                                            text:           kbd.loaded ? kbd.layoutLabel : "--"
                                            font.pixelSize: 10
                                            font.bold:      true
                                            font.family:    "JetBrains Mono Nerd Font Mono"
                                            color:          theme.foreground
                                        }
                                    }
                                }

                                Row {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Repeater {
                                        model: ["123", "abc", "网格"]

                                        Rectangle {
                                            width: 36; height: 28
                                            radius: 4
                                            color: index === 0 ? Qt.darker(theme.background, 1.2) : "transparent"
                                            border { width: 1; color: theme.muted }

                                            Text {
                                                anchors.centerIn: parent
                                                text:           modelData
                                                font.pixelSize: 11
                                                font.family:    "JetBrains Mono Nerd Font Mono"
                                                color:          index === 0 ? theme.foreground : theme.muted
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape:  Qt.PointingHandCursor
                                                onClicked:    root.runCommand("python3 ~/.config/xkb/symbols/my_ar.py")
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    root.runCommand("python3 ~/.config/xkb/symbols/my_ar.py")
                                onContainsMouseChanged: {
                                    kbdSection.hovered = containsMouse
                                }
                            }
                        }

                        // ════════════════════════════════════════════════
                        // 4. Network Monitor Section
                        // ════════════════════════════════════════════════
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: netSectionCol.implicitHeight + 16
                            radius: barSettings.barRadius
                            color:  "transparent"
                            border { width: barSettings.borderThickness; color: netSection.hovered ? theme.muted : theme.color4 }

                            property bool hovered: false

                            ColumnLayout {
                                id: netSectionCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: 8
                                }
                                spacing: 6

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        text:           net.networkIcon()
                                        font.pixelSize: 18
                                        color:          netSection.hovered ? theme.foreground : net.networkColor()
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    Text {
                                        text:           "Network Monitor"
                                        font.pixelSize: 14
                                        font.bold:      true
                                        color:          theme.foreground
                                    }

                                    Item { Layout.fillWidth: true }

                                    Rectangle {
                                        width: 28; height: 18
                                        radius: 4
                                        color: Qt.darker(theme.background, 1.3)
                                        border { width: 1; color: theme.muted }

                                        Text {
                                            anchors.centerIn: parent
                                            text:           "EN"
                                            font.pixelSize: 10
                                            font.bold:      true
                                            font.family:    "JetBrains Mono Nerd Font Mono"
                                            color:          theme.foreground
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.topMargin: 4
                                    spacing: 16
                                    Layout.alignment: Qt.AlignHCenter

                                    ColumnLayout {
                                        spacing: 2
                                        Layout.alignment: Qt.AlignHCenter

                                        Canvas {
                                            id: uploadCanvas
                                            width: 70; height: 70
                                            Layout.alignment: Qt.AlignHCenter

                                            property real progress: net.loaded ? Math.min((net.uploadSpeed || 0) / 1000, 1) : 0

                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.reset()
                                                var centerX = width / 2
                                                var centerY = height / 2
                                                var radius = 28
                                                var lineWidth = 4

                                                ctx.beginPath()
                                                ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
                                                ctx.strokeStyle = Qt.darker(theme.background, 1.3)
                                                ctx.lineWidth = lineWidth
                                                ctx.stroke()

                                                ctx.beginPath()
                                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * progress)
                                                ctx.strokeStyle = theme.color2
                                                ctx.lineWidth = lineWidth
                                                ctx.lineCap = "round"
                                                ctx.stroke()

                                                ctx.fillStyle = theme.foreground
                                                ctx.font = "bold 14px JetBrains Mono Nerd Font Mono"
                                                ctx.textAlign = "center"
                                                ctx.textBaseline = "middle"
                                                ctx.fillText(net.loaded ? (net.uploadSpeedText || "0") : "--", centerX, centerY)
                                            }

                                            Connections {
                                                target: net
                                                function onUploadSpeedChanged() { uploadCanvas.requestPaint() }
                                                function onLoadedChanged() { uploadCanvas.requestPaint() }
                                            }
                                        }

                                        Text {
                                            text:           "Upload"
                                            font.pixelSize: 10
                                            color:          theme.muted
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 2
                                        Layout.alignment: Qt.AlignHCenter

                                        Canvas {
                                            id: downloadCanvas
                                            width: 70; height: 70
                                            Layout.alignment: Qt.AlignHCenter

                                            property real progress: net.loaded ? Math.min((net.downloadSpeed || 0) / 1000, 1) : 0

                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.reset()
                                                var centerX = width / 2
                                                var centerY = height / 2
                                                var radius = 28
                                                var lineWidth = 4

                                                ctx.beginPath()
                                                ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
                                                ctx.strokeStyle = Qt.darker(theme.background, 1.3)
                                                ctx.lineWidth = lineWidth
                                                ctx.stroke()

                                                ctx.beginPath()
                                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * progress)
                                                ctx.strokeStyle = theme.color3
                                                ctx.lineWidth = lineWidth
                                                ctx.lineCap = "round"
                                                ctx.stroke()

                                                ctx.fillStyle = theme.foreground
                                                ctx.font = "bold 14px JetBrains Mono Nerd Font Mono"
                                                ctx.textAlign = "center"
                                                ctx.textBaseline = "middle"
                                                ctx.fillText(net.loaded ? (net.downloadSpeedText || "0") : "--", centerX, centerY)
                                            }

                                            Connections {
                                                target: net
                                                function onDownloadSpeedChanged() { downloadCanvas.requestPaint() }
                                                function onLoadedChanged() { downloadCanvas.requestPaint() }
                                            }
                                        }

                                        Text {
                                            text:           "Download"
                                            font.pixelSize: 10
                                            color:          theme.muted
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.topMargin: 6
                                    spacing: 6

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 36
                                        radius: 4
                                        color: Qt.darker(theme.background, 1.3)

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 0

                                            Text {
                                                text:           net.loaded ? (net.ipAddress || "--") : "--"
                                                font.pixelSize: 10
                                                font.bold:      true
                                                font.family:    "JetBrains Mono Nerd Font Mono"
                                                color:          theme.foreground
                                                Layout.alignment: Qt.AlignHCenter
                                            }

                                            Text {
                                                text:           "IP Address"
                                                font.pixelSize: 8
                                                color:          theme.muted
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 36
                                        radius: 4
                                        color: Qt.darker(theme.background, 1.3)

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 0

                                            Text {
                                                text:           net.loaded ? (net.gateway || "--") : "--"
                                                font.pixelSize: 10
                                                font.bold:      true
                                                font.family:    "JetBrains Mono Nerd Font Mono"
                                                color:          theme.foreground
                                                Layout.alignment: Qt.AlignHCenter
                                            }

                                            Text {
                                                text:           "Gateway"
                                                font.pixelSize: 8
                                                color:          theme.muted
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 36
                                        radius: 4
                                        color: Qt.darker(theme.background, 1.3)

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 0

                                            Text {
                                                text:           net.loaded ? (net.dns || "--") : "--"
                                                font.pixelSize: 10
                                                font.bold:      true
                                                font.family:    "JetBrains Mono Nerd Font Mono"
                                                color:          theme.foreground
                                                Layout.alignment: Qt.AlignHCenter
                                            }

                                            Text {
                                                text:           "DNS"
                                                font.pixelSize: 8
                                                color:          theme.muted
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    root.networkPopupOpen = !root.networkPopupOpen
                                onContainsMouseChanged: {
                                    netSection.hovered = containsMouse
                                }
                            }
                        }

                    }
                }
            }
        }
    }
}
