// ═══════════════════════════════════════════════════════════════════════════════
// SystemStatsPopup - System Resources Overlay
// ═══════════════════════════════════════════════════════════════════════════════
// Displays round gauge meters for GPU/CPU temperature and RAM usage,
// plus horizontal usage bars for GPU and CPU.
// Shown on the primary monitor when the system resources button is clicked.
//
// Required properties (passed from shell.qml):
//   visible       - Whether the popup is shown
//   onClose       - Signal to close the popup
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    model: [Quickshell.screens[1]]

    PanelWindow {
        screen:  modelData
        visible: statsPopup.isOpen
        required property var modelData

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: statsPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: statsPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        MouseArea {
            anchors.fill: parent
            onClicked:    statsPopup.close()
        }

        Rectangle {
            anchors.top:        parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin:  10
            width:    500
            implicitHeight: tempPopupCol.implicitHeight + 32
            height:   implicitHeight
            radius:   5
            color:    theme.background
            opacity:  0.95
            border { width: 2; color: theme.color4 }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id:        tempPopupCol
                anchors.fill:    parent
                anchors.margins: 20
                spacing: 16

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text:           "󰍛"
                        font.pixelSize: 24
                        color:          theme.color4
                    }

                    Text {
                        text:      "System Resources"
                        color:     theme.foreground
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: theme.muted
                    opacity: 0.4
                }

                // Round Meters Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    // ── GPU Meter ─────────────────────────────────────────
                    Item {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 140
                        implicitHeight: 140

                        Canvas {
                            id:           gpuRoundCanvas
                            anchors.fill: parent

                            property real temperature: stats.gpuTempRaw
                            property real maxTemp:     100

                            onPaint: draw()
                            onTemperatureChanged: requestPaint()
                            Component.onCompleted: requestPaint()

                            function getTempColor(temp) {
                                if (temp >= 80) return theme.color1
                                if (temp >= 60) return theme.color3
                                return theme.color2
                            }

                            function draw() {
                                var ctx = gpuRoundCanvas.getContext("2d")
                                var centerX = width / 2
                                var centerY = height / 2
                                var radius = Math.min(centerX, centerY) - 10
                                var lineWidth = 8

                                ctx.clearRect(0, 0, width, height)

                                // Background circle
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
                                ctx.strokeStyle = Qt.darker(theme.background, 1.5)
                                ctx.lineWidth = lineWidth
                                ctx.lineCap = "round"
                                ctx.stroke()

                                // Temperature arc
                                var fraction = Math.min(Math.max(temperature / maxTemp, 0), 1)
                                var endAngle = -Math.PI / 2 + (fraction * Math.PI * 2)

                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, endAngle)
                                ctx.strokeStyle = getTempColor(temperature)
                                ctx.lineWidth = lineWidth
                                ctx.lineCap = "round"
                                ctx.stroke()

                                // Tick marks
                                for (var i = 0; i < 12; i++) {
                                    var tickAngle = (i / 12) * Math.PI * 2 - Math.PI / 2
                                    var innerR = radius - lineWidth / 2 - 3
                                    var outerR = radius - lineWidth / 2 - 7

                                    ctx.beginPath()
                                    ctx.moveTo(
                                        centerX + Math.cos(tickAngle) * innerR,
                                        centerY + Math.sin(tickAngle) * innerR
                                    )
                                    ctx.lineTo(
                                        centerX + Math.cos(tickAngle) * outerR,
                                        centerY + Math.sin(tickAngle) * outerR
                                    )
                                    ctx.strokeStyle = theme.muted
                                    ctx.lineWidth = 1
                                    ctx.stroke()
                                }
                            }
                        }

                        // Center text
                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:           stats.gpuTempRaw > 0 ? Math.round(stats.gpuTempRaw) + "°" : "--"
                                font.pixelSize: 22
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          stats.gpuTempRaw >= 80 ? theme.color1 :
                                                (stats.gpuTempRaw >= 60 ? theme.color3 : theme.color2)
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:           "GPU"
                                font.pixelSize: 12
                                font.bold:      true
                                color:          theme.muted
                            }
                        }
                    }

                    // ── CPU Meter ─────────────────────────────────────────
                    Item {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 140
                        implicitHeight: 140

                        Canvas {
                            id:           cpuRoundCanvas
                            anchors.fill: parent

                            property real temperature: stats.cpuTempRaw
                            property real maxTemp:     100

                            onPaint: draw()
                            onTemperatureChanged: requestPaint()
                            Component.onCompleted: requestPaint()

                            function getTempColor(temp) {
                                if (temp >= 80) return theme.color1
                                if (temp >= 60) return theme.color3
                                return theme.color6
                            }

                            function draw() {
                                var ctx = cpuRoundCanvas.getContext("2d")
                                var centerX = width / 2
                                var centerY = height / 2
                                var radius = Math.min(centerX, centerY) - 10
                                var lineWidth = 8

                                ctx.clearRect(0, 0, width, height)

                                // Background circle
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
                                ctx.strokeStyle = Qt.darker(theme.background, 1.5)
                                ctx.lineWidth = lineWidth
                                ctx.lineCap = "round"
                                ctx.stroke()

                                // Temperature arc
                                var fraction = Math.min(Math.max(temperature / maxTemp, 0), 1)
                                var endAngle = -Math.PI / 2 + (fraction * Math.PI * 2)

                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, endAngle)
                                ctx.strokeStyle = getTempColor(temperature)
                                ctx.lineWidth = lineWidth
                                ctx.lineCap = "round"
                                ctx.stroke()

                                // Tick marks
                                for (var i = 0; i < 12; i++) {
                                    var tickAngle = (i / 12) * Math.PI * 2 - Math.PI / 2
                                    var innerR = radius - lineWidth / 2 - 3
                                    var outerR = radius - lineWidth / 2 - 7

                                    ctx.beginPath()
                                    ctx.moveTo(
                                        centerX + Math.cos(tickAngle) * innerR,
                                        centerY + Math.sin(tickAngle) * innerR
                                    )
                                    ctx.lineTo(
                                        centerX + Math.cos(tickAngle) * outerR,
                                        centerY + Math.sin(tickAngle) * outerR
                                    )
                                    ctx.strokeStyle = theme.muted
                                    ctx.lineWidth = 1
                                    ctx.stroke()
                                }
                            }
                        }

                        // Center text
                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:           stats.cpuTempRaw > 0 ? Math.round(stats.cpuTempRaw) + "°" : "--"
                                font.pixelSize: 22
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          stats.cpuTempRaw >= 80 ? theme.color1 :
                                                (stats.cpuTempRaw >= 60 ? theme.color3 : theme.color6)
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:           "CPU"
                                font.pixelSize: 12
                                font.bold:      true
                                color:          theme.muted
                            }
                        }
                    }

                    // ── RAM Meter ─────────────────────────────────────────
                    Item {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 140
                        implicitHeight: 140

                        Canvas {
                            id:           ramRoundCanvas
                            anchors.fill: parent

                            property real usage: stats.ramUsage
                            property real maxUsage: 100

                            onPaint: draw()
                            onUsageChanged: requestPaint()
                            Component.onCompleted: requestPaint()

                            function getUsageColor(usage) {
                                if (usage >= 80) return theme.color1
                                if (usage >= 60) return theme.color3
                                return theme.color4
                            }

                            function draw() {
                                var ctx = ramRoundCanvas.getContext("2d")
                                var centerX = width / 2
                                var centerY = height / 2
                                var radius = Math.min(centerX, centerY) - 10
                                var lineWidth = 8

                                ctx.clearRect(0, 0, width, height)

                                // Background circle
                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
                                ctx.strokeStyle = Qt.darker(theme.background, 1.5)
                                ctx.lineWidth = lineWidth
                                ctx.lineCap = "round"
                                ctx.stroke()

                                // Usage arc
                                var fraction = Math.min(Math.max(usage / maxUsage, 0), 1)
                                var endAngle = -Math.PI / 2 + (fraction * Math.PI * 2)

                                ctx.beginPath()
                                ctx.arc(centerX, centerY, radius, -Math.PI / 2, endAngle)
                                ctx.strokeStyle = getUsageColor(usage)
                                ctx.lineWidth = lineWidth
                                ctx.lineCap = "round"
                                ctx.stroke()

                                // Tick marks
                                for (var i = 0; i < 12; i++) {
                                    var tickAngle = (i / 12) * Math.PI * 2 - Math.PI / 2
                                    var innerR = radius - lineWidth / 2 - 3
                                    var outerR = radius - lineWidth / 2 - 7

                                    ctx.beginPath()
                                    ctx.moveTo(
                                        centerX + Math.cos(tickAngle) * innerR,
                                        centerY + Math.sin(tickAngle) * innerR
                                    )
                                    ctx.lineTo(
                                        centerX + Math.cos(tickAngle) * outerR,
                                        centerY + Math.sin(tickAngle) * outerR
                                    )
                                    ctx.strokeStyle = theme.muted
                                    ctx.lineWidth = 1
                                    ctx.stroke()
                                }
                            }
                        }

                        // Center text
                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:           stats.ramTotalGB > 0 ? stats.ramUsedGB.toFixed(1) + "G" : "--"
                                font.pixelSize: 22
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          stats.ramUsage >= 80 ? theme.color1 :
                                                (stats.ramUsage >= 60 ? theme.color3 : theme.color4)
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:           "RAM"
                                font.pixelSize: 12
                                font.bold:      true
                                color:          theme.muted
                            }
                        }
                    }
                }

                // Usage bars
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // GPU Usage bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "GPU"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "JetBrains Mono Nerd Font Mono"
                            color: theme.color2
                            Layout.preferredWidth: 35
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 8
                            radius: 4
                            color: Qt.darker(theme.background, 1.3)

                            Rectangle {
                                anchors {
                                    left:   parent.left
                                    top:    parent.top
                                    bottom: parent.bottom
                                }
                                width:  parent.width * Math.min(Math.max(stats.gpuUsage / 100, 0), 1)
                                radius: 4
                                color:  stats.gpuUsage >= 80 ? theme.color1 :
                                        (stats.gpuUsage >= 60 ? theme.color3 : theme.color2)
                                Behavior on width { NumberAnimation { duration: 200 } }
                            }
                        }

                        Text {
                            text:           Math.round(stats.gpuUsage) + "%"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "JetBrains Mono Nerd Font Mono"
                            color: theme.foreground
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // CPU Usage bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "CPU"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "JetBrains Mono Nerd Font Mono"
                            color: theme.color3
                            Layout.preferredWidth: 35
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 8
                            radius: 4
                            color: Qt.darker(theme.background, 1.3)

                            Rectangle {
                                anchors {
                                    left:   parent.left
                                    top:    parent.top
                                    bottom: parent.bottom
                                }
                                width:  parent.width * Math.min(Math.max(stats.cpuUsage / 100, 0), 1)
                                radius: 4
                                color:  stats.cpuUsage >= 80 ? theme.color1 :
                                        (stats.cpuUsage >= 60 ? theme.color3 : theme.color6)
                                Behavior on width { NumberAnimation { duration: 200 } }
                            }
                        }

                        Text {
                            text:           Math.round(stats.cpuUsage) + "%"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "JetBrains Mono Nerd Font Mono"
                            color: theme.foreground
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                // Close button
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: 5
                    color:  "transparent"
                    border { width: 2; color: theme.color4 }

                    Text {
                        anchors.centerIn: parent
                        text:  "Close"
                        color: theme.color4
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    statsPopup.close()
                    }
                }
            }
        }
    }
}