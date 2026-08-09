// ═══════════════════════════════════════════════════════════════════════════════
// Widget2 - Right-side slide-in widget (Widget 2)
// ═══════════════════════════════════════════════════════════════════════════════
// Displays network information: connection status, IP, traffic, interfaces.
// Opened via right-click on the widgets button.
//
// Required properties (passed from shell.qml):
//   widget2.isOpen - Whether the widget is shown
//   widget2.close  - Function to close the widget
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Variants {
    model: barSettings.popupScreens()

    PanelWindow {
        id: widget2Window
        screen:  modelData
        visible: panelVisible
        required property var modelData

        property bool panelVisible: false
        readonly property int panelMargin: 10
        readonly property int panelBottomMargin: 60
        readonly property int panelWidth: 340
        readonly property int slideDuration: 300

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: widget2.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: widget2.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        Connections {
            target: widget2
            function onIsOpenChanged() {
                if (widget2.isOpen) {
                    panelVisible = true
                    // Ensure panel is rendered at off-screen position first
                    networkPanel.x = modelData.width + 20
                    networkPanel.opacity = 0
                    Qt.callLater(animateIn)
                } else {
                    animateOut()
                    hideTimer.start()
                }
            }

            function animateIn() {
                slideInAnim.from = modelData.width + 20
                slideInAnim.to   = modelData.width - networkPanel.width - widget2Window.panelMargin
                slideInAnim.start()
                fadeInAnim.start()
            }

            function animateOut() {
                fadeOutAnim.start()
                slideOutAnim.from = modelData.width - networkPanel.width - widget2Window.panelMargin
                slideOutAnim.to   = modelData.width + 20
                slideOutAnim.start()
            }
        }

        Timer {
            id: hideTimer
            interval: widget2Window.slideDuration + 50
            onTriggered: panelVisible = false
        }

        // Backdrop (click outside to close)
        MouseArea {
            anchors.fill: parent
            onClicked:    widget2.close()
            opacity:      widget2.isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        // ── Network Panel Rectangle ─────────────────────────────────────
        Rectangle {
            id: networkPanel
            width:  widget2Window.panelWidth
            height: Math.min(contentCol.implicitHeight + 32, parent.height - widget2Window.panelMargin - widget2Window.panelBottomMargin)
            y:      widget2Window.panelMargin

            // Start off-screen right, invisible
            x:       modelData.width + 20
            opacity: 0

            radius: barSettings.barRadius
            color:  theme.background
            border { width: barSettings.borderThickness; color: theme.color4 }

            // ── Animations ───────────────────────────────────────────────
            NumberAnimation {
                id: slideInAnim
                target:   networkPanel
                property: "x"
                duration: 300
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                id: slideOutAnim
                target:   networkPanel
                property: "x"
                duration: 300
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                id: fadeInAnim
                target:   networkPanel
                property: "opacity"
                from:     0
                to:       0.95
                duration: 200
            }

            NumberAnimation {
                id: fadeOutAnim
                target:   networkPanel
                property: "opacity"
                from:     0.95
                to:       0
                duration: 200
            }

            // Absorb clicks so backdrop doesn't fire
            MouseArea {
                anchors.fill: parent
                onClicked: mouse => mouse.accepted = true
            }

            // ── Scrollable Content ───────────────────────────────────────
            Flickable {
                anchors.fill: parent
                anchors.margins: 16
                contentHeight: contentCol.implicitHeight
                clip:           true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: contentCol
                    width: parent.width
                    spacing: 16

                    // ═══════════════════════════════════════════════════════
                    // SECTION 1: Connection Status
                    // ═══════════════════════════════════════════════════════
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: statusCol.implicitHeight + 24
                        radius:   barSettings.barRadius
                        color:    Qt.darker(theme.background, 1.2)
                        border { width: barSettings.borderThickness; color: Qt.darker(theme.muted, 1.5) }

                        ColumnLayout {
                            id: statusCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text:           net.networkIcon()
                                    font.pixelSize: 32
                                    font.family:    "JetBrains Mono Nerd Font Mono"
                                    color:          net.networkColor()
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text:      net.connectionName()
                                        color:     theme.foreground
                                        font.pixelSize: 16
                                        font.bold: true
                                    }

                                    Text {
                                        text:      net.interfaceName
                                        color:     theme.muted
                                        font.pixelSize: 12
                                        font.family: "JetBrains Mono Nerd Font Mono"
                                    }
                                }
                            }

                            // IP Address
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:      "IP"
                                    color:     theme.muted
                                    font.pixelSize: 11
                                    Layout.preferredWidth: 40
                                }

                                Text {
                                    text:      net.loaded ? net.ipAddress : "--"
                                    color:     theme.foreground
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                    Layout.fillWidth: true
                                }
                            }

                            // Gateway
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:      "GW"
                                    color:     theme.muted
                                    font.pixelSize: 11
                                    Layout.preferredWidth: 40
                                }

                                Text {
                                    text:      net.loaded ? net.gateway : "--"
                                    color:     theme.foreground
                                    font.pixelSize: 12
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                    Layout.fillWidth: true
                                    elide:     Text.ElideRight
                                }
                            }

                            // DNS
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:      "DNS"
                                    color:     theme.muted
                                    font.pixelSize: 11
                                    Layout.preferredWidth: 40
                                }

                                Text {
                                    text:      net.loaded ? net.dns : "--"
                                    color:     theme.foreground
                                    font.pixelSize: 12
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                    Layout.fillWidth: true
                                    elide:     Text.ElideRight
                                }
                            }
                        }
                    }

                    // ═══════════════════════════════════════════════════════
                    // SECTION 2: Wi-Fi Info (shown only when on wifi)
                    // ═══════════════════════════════════════════════════════
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: wifiCol.implicitHeight + 24
                        visible: net.connectionType === "wifi"
                        radius:   barSettings.barRadius
                        color:    Qt.darker(theme.background, 1.2)
                        border { width: barSettings.borderThickness; color: Qt.darker(theme.muted, 1.5) }

                        ColumnLayout {
                            id: wifiCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text:      "Wi-Fi"
                                color:     theme.foreground
                                font.pixelSize: 14
                                font.bold: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:      "SSID"
                                    color:     theme.muted
                                    font.pixelSize: 11
                                    Layout.preferredWidth: 50
                                }

                                Text {
                                    text:      net.ssid || "--"
                                    color:     theme.foreground
                                    font.pixelSize: 12
                                    font.bold: true
                                    Layout.fillWidth: true
                                    elide:     Text.ElideRight
                                }
                            }

                            // Signal strength bar
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:      "Signal"
                                    color:     theme.muted
                                    font.pixelSize: 11
                                    Layout.preferredWidth: 50
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 8
                                    radius: 4
                                    color: Qt.darker(theme.background, 1.5)

                                    Rectangle {
                                        anchors {
                                            left: parent.left
                                            top: parent.top
                                            bottom: parent.bottom
                                        }
                                        width: parent.width * (parseInt(net.signalStrength) || 0) / 100
                                        radius: 4
                                        color: {
                                            const s = parseInt(net.signalStrength) || 0
                                            if (s >= 60) return theme.color6
                                            if (s >= 30) return theme.color3
                                            return theme.color1
                                        }
                                    }
                                }

                                Text {
                                    text:      (net.signalStrength || "0") + "%"
                                    color:     theme.foreground
                                    font.pixelSize: 11
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                    Layout.preferredWidth: 35
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }

                    // ═══════════════════════════════════════════════════════
                    // SECTION 3: Network Traffic
                    // ═══════════════════════════════════════════════════════
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: trafficCol.implicitHeight + 24
                        radius:   barSettings.barRadius
                        color:    Qt.darker(theme.background, 1.2)
                        border { width: barSettings.borderThickness; color: Qt.darker(theme.muted, 1.5) }

                        ColumnLayout {
                            id: trafficCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text:      "Traffic"
                                color:     theme.foreground
                                font.pixelSize: 14
                                font.bold: true
                            }

                            // Download
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:           "󰇚"
                                    font.pixelSize: 14
                                    font.family:    "JetBrains Mono Nerd Font Mono"
                                    color:          theme.color4
                                }

                                Text {
                                    text:      "Download"
                                    color:     theme.muted
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text:      net.rxRate
                                    color:     theme.foreground
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                }
                            }

                            // Upload
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:           "󰕒"
                                    font.pixelSize: 14
                                    font.family:    "JetBrains Mono Nerd Font Mono"
                                    color:          theme.color6
                                }

                                Text {
                                    text:      "Upload"
                                    color:     theme.muted
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text:      net.txRate
                                    color:     theme.foreground
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                }
                            }

                            // Total
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:      "Total RX / TX"
                                    color:     theme.muted
                                    font.pixelSize: 11
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text:      net.rxBytes + " / " + net.txBytes
                                    color:     theme.muted
                                    font.pixelSize: 11
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                }
                            }
                        }
                    }

                    // ═══════════════════════════════════════════════════════
                    // SECTION 4: Interfaces
                    // ═══════════════════════════════════════════════════════
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: ifaceCol.implicitHeight + 24
                        visible: net.interfaces.length > 0
                        radius:   barSettings.barRadius
                        color:    Qt.darker(theme.background, 1.2)
                        border { width: barSettings.borderThickness; color: Qt.darker(theme.muted, 1.5) }

                        ColumnLayout {
                            id: ifaceCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Text {
                                text:      "Interfaces"
                                color:     theme.foreground
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Repeater {
                                model: net.interfaces

                                Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 28
                                    radius: 3
                                    color: modelData.device === net.interfaceName
                                        ? Qt.darker(theme.color4, 1.5)
                                        : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 8

                                        Text {
                                            text: modelData.type === "wifi" ? "󰤨" : "󰈀"
                                            font.pixelSize: 13
                                            font.family: "JetBrains Mono Nerd Font Mono"
                                            color: modelData.device === net.interfaceName
                                                ? theme.color4 : theme.muted
                                        }

                                        Text {
                                            text: modelData.device
                                            color: modelData.device === net.interfaceName
                                                ? theme.color4 : theme.foreground
                                            font.pixelSize: 12
                                            font.bold: modelData.device === net.interfaceName
                                            font.family: "JetBrains Mono Nerd Font Mono"
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: modelData.state
                                            color: modelData.state === "connected"
                                                ? theme.color6 : theme.muted
                                            font.pixelSize: 10
                                            font.family: "JetBrains Mono Nerd Font Mono"
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: modelData.state === "connected" && modelData.device !== net.interfaceName
                                        onClicked: net.switchInterface(modelData.device)
                                    }
                                }
                            }
                        }
                    }
                    // ═══════════════════════════════════════════════════════
                    // SECTION 5: Hardware Monitor
                    // ═══════════════════════════════════════════════════════
                    Rectangle {
                        id: hwMonitor
                        Layout.fillWidth: true
                        implicitHeight: hwCol.implicitHeight + 24
                        radius:   barSettings.barRadius
                        color:    Qt.darker(theme.background, 1.2)
                        border { width: barSettings.borderThickness; color: Qt.darker(theme.muted, 1.5) }

                        property string selectedTab: "CPU"

                        ColumnLayout {
                            id: hwCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            // Title
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text:      "Hardware Monitor"
                                color:     theme.foreground
                                font.pixelSize: 16
                                font.bold: true
                            }

                            // Tab buttons
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Repeater {
                                    model: ["CPU", "RAM", "GPU", "Disk"]

                                    Rectangle {
                                        id: tabBtn
                                        required property string modelData
                                        Layout.fillWidth: true
                                        implicitHeight: 40
                                        radius: barSettings.barRadius
                                        color: hwMonitor.selectedTab === modelData
                                            ? theme.color4
                                            : Qt.darker(theme.background, 1.5)
                                        border {
                                            width: hwMonitor.selectedTab === modelData ? 0 : barSettings.borderThickness
                                            color: hwMonitor.selectedTab === modelData
                                                ? theme.color4
                                                : Qt.darker(theme.muted, 1.5)
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: tabBtn.modelData
                                            color: hwMonitor.selectedTab === tabBtn.modelData
                                                ? theme.background : theme.muted
                                            font.pixelSize: 13
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: hwMonitor.selectedTab = tabBtn.modelData
                                        }
                                    }
                                }
                            }

                            // Tab content: circular gauge
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 180

                                // CPU tab
                                ColumnLayout {
                                    anchors.fill: parent
                                    visible: hwMonitor.selectedTab === "CPU"
                                    spacing: 8

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        Canvas {
                                            id: cpuGauge
                                            anchors.fill: parent
                                            anchors.margins: 8

                                            property real value: stats.cpuTempRaw
                                            property color arcColor: stats.cpuTempRaw >= 80 ? theme.color1
                                                : (stats.cpuTempRaw >= 60 ? theme.color3 : theme.color2)

                                            onPaint: {
                                                var ctx = getContext("2d")
                                                var w = width, h = height
                                                var cx = w / 2, cy = h / 2
                                                var r = Math.min(cx, cy) - 6
                                                var lw = 8

                                                ctx.clearRect(0, 0, w, h)

                                                ctx.beginPath()
                                                ctx.arc(cx, cy, r, 0, Math.PI * 2)
                                                ctx.strokeStyle = Qt.darker(theme.background, 1.5)
                                                ctx.lineWidth = lw
                                                ctx.lineCap = "round"
                                                ctx.stroke()

                                                var frac = Math.min(Math.max(value / 100, 0), 1)
                                                ctx.beginPath()
                                                ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + frac * Math.PI * 2)
                                                ctx.strokeStyle = arcColor
                                                ctx.lineWidth = lw
                                                ctx.lineCap = "round"
                                                ctx.stroke()
                                            }

                                            onValueChanged: requestPaint()
                                            Component.onCompleted: requestPaint()
                                        }

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 2

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: stats.cpuTempRaw > 0 ? Math.round(stats.cpuTempRaw) + "°C" : "--"
                                                font.pixelSize: 26
                                                font.bold: true
                                                font.family: "JetBrains Mono Nerd Font Mono"
                                                color: stats.cpuTempRaw >= 80 ? theme.color1
                                                    : (stats.cpuTempRaw >= 60 ? theme.color3 : theme.color2)
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: Math.round(stats.cpuUsage) + "% Usage"
                                                font.pixelSize: 12
                                                color: theme.muted
                                                font.family: "JetBrains Mono Nerd Font Mono"
                                            }
                                        }
                                    }
                                }

                                // RAM tab
                                ColumnLayout {
                                    anchors.fill: parent
                                    visible: hwMonitor.selectedTab === "RAM"
                                    spacing: 8

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        Canvas {
                                            id: ramGauge
                                            anchors.fill: parent
                                            anchors.margins: 8

                                            property real value: stats.ramUsage
                                            property color arcColor: stats.ramUsage >= 80 ? theme.color1
                                                : (stats.ramUsage >= 60 ? theme.color3 : theme.color4)

                                            onPaint: {
                                                var ctx = getContext("2d")
                                                var w = width, h = height
                                                var cx = w / 2, cy = h / 2
                                                var r = Math.min(cx, cy) - 6
                                                var lw = 8

                                                ctx.clearRect(0, 0, w, h)

                                                ctx.beginPath()
                                                ctx.arc(cx, cy, r, 0, Math.PI * 2)
                                                ctx.strokeStyle = Qt.darker(theme.background, 1.5)
                                                ctx.lineWidth = lw
                                                ctx.lineCap = "round"
                                                ctx.stroke()

                                                var frac = Math.min(Math.max(value / 100, 0), 1)
                                                ctx.beginPath()
                                                ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + frac * Math.PI * 2)
                                                ctx.strokeStyle = arcColor
                                                ctx.lineWidth = lw
                                                ctx.lineCap = "round"
                                                ctx.stroke()
                                            }

                                            onValueChanged: requestPaint()
                                            Component.onCompleted: requestPaint()
                                        }

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 2

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: Math.round(stats.ramUsage) + "%"
                                                font.pixelSize: 24
                                                font.bold: true
                                                font.family: "JetBrains Mono Nerd Font Mono"
                                                color: stats.ramUsage >= 80 ? theme.color1
                                                    : (stats.ramUsage >= 60 ? theme.color3 : theme.color4)
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: stats.ramTotalGB > 0
                                                    ? stats.ramUsedGB.toFixed(1) + "G / " + stats.ramTotalGB.toFixed(1) + "G"
                                                    : "--"
                                                font.pixelSize: 12
                                                color: theme.muted
                                                font.family: "JetBrains Mono Nerd Font Mono"
                                            }
                                        }
                                    }
                                }

                                // GPU tab
                                ColumnLayout {
                                    anchors.fill: parent
                                    visible: hwMonitor.selectedTab === "GPU"
                                    spacing: 8

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        Canvas {
                                            id: gpuGauge
                                            anchors.fill: parent
                                            anchors.margins: 8

                                            property real value: stats.gpuTempRaw
                                            property color arcColor: stats.gpuTempRaw >= 80 ? theme.color1
                                                : (stats.gpuTempRaw >= 60 ? theme.color3 : theme.color2)

                                            onPaint: {
                                                var ctx = getContext("2d")
                                                var w = width, h = height
                                                var cx = w / 2, cy = h / 2
                                                var r = Math.min(cx, cy) - 6
                                                var lw = 8

                                                ctx.clearRect(0, 0, w, h)

                                                ctx.beginPath()
                                                ctx.arc(cx, cy, r, 0, Math.PI * 2)
                                                ctx.strokeStyle = Qt.darker(theme.background, 1.5)
                                                ctx.lineWidth = lw
                                                ctx.lineCap = "round"
                                                ctx.stroke()

                                                var frac = Math.min(Math.max(value / 100, 0), 1)
                                                ctx.beginPath()
                                                ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + frac * Math.PI * 2)
                                                ctx.strokeStyle = arcColor
                                                ctx.lineWidth = lw
                                                ctx.lineCap = "round"
                                                ctx.stroke()
                                            }

                                            onValueChanged: requestPaint()
                                            Component.onCompleted: requestPaint()
                                        }

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 2

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: stats.gpuTempRaw > 0 ? Math.round(stats.gpuTempRaw) + "°C" : "--"
                                                font.pixelSize: 26
                                                font.bold: true
                                                font.family: "JetBrains Mono Nerd Font Mono"
                                                color: stats.gpuTempRaw >= 80 ? theme.color1
                                                    : (stats.gpuTempRaw >= 60 ? theme.color3 : theme.color2)
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: Math.round(stats.gpuUsage) + "% Usage"
                                                font.pixelSize: 12
                                                color: theme.muted
                                                font.family: "JetBrains Mono Nerd Font Mono"
                                            }
                                        }
                                    }
                                }

                                // Disk tab
                                ColumnLayout {
                                    id: diskTab
                                    anchors.fill: parent
                                    visible: hwMonitor.selectedTab === "Disk"
                                    spacing: 6

                                    Flickable {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        contentHeight: drivesList.implicitHeight
                                        clip: true
                                        boundsBehavior: Flickable.StopAtBounds
                                        flickableDirection: Flickable.VerticalFlick

                                        ColumnLayout {
                                            id: drivesList
                                            width: parent.width
                                            spacing: 6

                                            Repeater {
                                                model: stats.drives.length

                                                Rectangle {
                                                    required property int index
                                                    property var d: stats.drives[index]

                                                    Layout.fillWidth: true
                                                    implicitHeight: driveContent.implicitHeight + 12
                                                    radius: barSettings.barRadius
                                                    color: Qt.darker(theme.background, 1.3)
                                                    border { width: 1; color: Qt.darker(theme.muted, 1.5) }

                                                    ColumnLayout {
                                                        id: driveContent
                                                        anchors.fill: parent
                                                        anchors.margins: 8
                                                        spacing: 4

                                                        // Name and size
                                                        RowLayout {
                                                            Layout.fillWidth: true

                                                            Text {
                                                                text: d.name
                                                                font.pixelSize: 12
                                                                font.bold: true
                                                                font.family: "JetBrains Mono Nerd Font Mono"
                                                                color: theme.color4
                                                            }

                                                            Item { Layout.fillWidth: true }

                                                            Text {
                                                                text: d.size || ""
                                                                font.pixelSize: 13
                                                                font.family: "JetBrains Mono Nerd Font Mono"
                                                                color: theme.muted
                                                            }
                                                        }

                                                        // Usage bar (only if mounted)
                                                        RowLayout {
                                                            Layout.fillWidth: true
                                                            spacing: 6
                                                            visible: d.total !== "--"

                                                            Rectangle {
                                                                Layout.fillWidth: true
                                                                implicitHeight: 6
                                                                radius: 3
                                                                color: Qt.darker(theme.background, 1.5)

                                                                Rectangle {
                                                                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                                                    width: {
                                                                        if (!d.totalBytes || d.totalBytes <= 0) return 0
                                                                        return parent.width * Math.min(d.usedBytes / d.totalBytes, 1)
                                                                    }
                                                                    radius: 3
                                                                    color: {
                                                                        if (!d.totalBytes || d.totalBytes <= 0) return theme.muted
                                                                        var p = d.usedBytes / d.totalBytes
                                                                        if (p >= 0.9) return theme.color1
                                                                        if (p >= 0.7) return theme.color3
                                                                        return theme.color2
                                                                    }
                                                                }
                                                            }

                                                            Text {
                                                                text: {
                                                                    if (!d.totalBytes || d.totalBytes <= 0) return "--"
                                                                    return Math.round(d.usedBytes / d.totalBytes * 100) + "%"
                                                                }
                                                                font.pixelSize: 13
                                                                font.bold: true
                                                                font.family: "JetBrains Mono Nerd Font Mono"
                                                                color: theme.foreground
                                                                Layout.preferredWidth: 35
                                                                horizontalAlignment: Text.AlignRight
                                                            }
                                                        }

                                                        // Used / Free (only if mounted)
                                                        RowLayout {
                                                            Layout.fillWidth: true
                                                            visible: d.total !== "--"

                                                            Text {
                                                                text: "Used: " + (d.used || "--")
                                                                font.pixelSize: 12
                                                                color: theme.muted
                                                                font.family: "JetBrains Mono Nerd Font Mono"
                                                            }

                                                            Item { Layout.fillWidth: true }

                                                            Text {
                                                                text: "Free: " + (d.avail || "--")
                                                                font.pixelSize: 12
                                                                font.family: "JetBrains Mono Nerd Font Mono"
                                                                color: theme.color2
                                                            }
                                                        }

                                                        // Unmounted label
                                                        Text {
                                                            visible: d.total === "--"
                                                            text: "Not mounted"
                                                            font.pixelSize: 12
                                                            font.italic: true
                                                            color: theme.muted
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

                    // Bottom padding
                    Item { Layout.fillHeight: true; Layout.preferredHeight: 20 }
                }
            }
        }
    }
}
