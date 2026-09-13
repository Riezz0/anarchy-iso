import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: infoPopupWindow

    visible: panelVisible
    screen: powerMenu.targetScreen

    property bool panelVisible: false

    anchors { top: true; bottom: true; left: true; right: true }

    color: "transparent"
    focusable: infoPopup.isOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: infoPopup.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    property int hwTab: 0

    Connections {
        target: infoPopup
        function onIsOpenChanged() {
            if (infoPopup.isOpen) panelVisible = true
            else hideTimer.start()
        }
    }

    Timer { id: hideTimer; interval: 300; onTriggered: if (!infoPopup.isOpen) panelVisible = false }

    MouseArea {
        anchors.fill: parent
        onClicked: infoPopup.close()
        opacity: infoPopup.isOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Rectangle {
        id: infoPanel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.rightMargin: infoPopup.isOpen ? 10 : -(width + 20)
        width: 400
        radius: root.barRadius
        color: theme.background
        opacity: infoPopup.isOpen ? root.popupOpacity : 0
        clip: true
        border.color: theme.muted
        border.width: root.popupBorderThickness
        layer.enabled: true
        layer.effect: OpacityMask { maskSource: Rectangle { width: infoPanel.width; height: infoPanel.height; radius: root.barRadius; color: "white" } }

        Behavior on anchors.rightMargin { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; onClicked: mouse => mouse.accepted = true }

        Flickable {
            anchors.fill: parent
            anchors.margins: 20
            clip: true
            contentHeight: popupCol.implicitHeight
            contentWidth: width
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            ColumnLayout {
                id: popupCol
                width: parent.width
                spacing: 0

                // Close
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 16
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 28; height: 28; radius: root.barRadius
                        color: closeH.containsMouse ? theme.color1 : Qt.darker(theme.background, 1.2)
                        Text { anchors.centerIn: parent; text: "\u2715"; font.pixelSize: 11; color: closeH.containsMouse ? theme.background : theme.foreground }
                        MouseArea { id: closeH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: infoPopup.close() }
                    }
                }

                // Weather card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    radius: root.barRadius
                    color: Qt.darker(theme.background, 1.08)
                    border.color: theme.muted; border.width: root.popupBorderThickness

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 16; spacing: 12

                        Text { text: infoWidget.weatherIcon || "\u{F0590}"; font.pixelSize: 22; font.family: "JetBrainsMono Nerd Font"; color: theme.foreground }

                        ColumnLayout { spacing: 2
                            Text { text: infoWidget.loaded ? infoWidget.condition : "Loading..."; font.pixelSize: 15; font.bold: true; color: theme.foreground }
                            Text { text: infoWidget.loaded ? infoWidget.city + ", " + infoWidget.country : ""; font.pixelSize: 11; color: theme.muted }
                        }

                        Item { Layout.fillWidth: true }

                        Text { text: infoWidget.loaded ? infoWidget.tempC + "\u00B0C" : "--"; font.pixelSize: 28; font.family: "JetBrainsMono Nerd Font"; font.bold: true; color: theme.foreground; Layout.alignment: Qt.AlignVCenter }
                    }
                }

                // Network
                ColumnLayout {
                    Layout.fillWidth: true; Layout.topMargin: 12; spacing: 12

                    // Ethernet info card
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: ethContent.implicitHeight + 20
                        radius: root.barRadius
                        color: Qt.darker(theme.background, 1.08)
                        border.color: theme.muted; border.width: root.popupBorderThickness

                        ColumnLayout {
                            id: ethContent
                            anchors.fill: parent; anchors.margins: 12; spacing: 6

                            RowLayout { spacing: 8
                                Text { text: "\u{F0AC}"; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"; color: theme.color4 }
                                Text { text: "Ethernet"; font.pixelSize: 14; font.bold: true; color: theme.foreground }
                            }

                            Text { text: infoWidget.netInterface || "--"; font.pixelSize: 11; color: theme.muted }

                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: theme.muted; opacity: 0.3; Layout.topMargin: 4; Layout.bottomMargin: 4 }

                            RowLayout { Layout.fillWidth: true
                                Text { text: "IP"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: theme.muted; Layout.preferredWidth: 50 }
                                Text { text: infoWidget.localIp || "--"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: theme.foreground }
                            }

                            RowLayout { Layout.fillWidth: true
                                Text { text: "GW"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: theme.muted; Layout.preferredWidth: 50 }
                                Text { text: infoWidget.gateway || "--"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: theme.foreground }
                            }

                            RowLayout { Layout.fillWidth: true
                                Text { text: "DNS"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: theme.muted; Layout.preferredWidth: 50 }
                                Text { text: infoWidget.dns || "--"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: theme.foreground }
                            }
                        }
                    }

                    // Traffic card
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: trafficContent.implicitHeight + 20
                        radius: root.barRadius
                        color: Qt.darker(theme.background, 1.08)
                        border.color: theme.muted; border.width: root.popupBorderThickness

                        ColumnLayout {
                            id: trafficContent
                            anchors.fill: parent; anchors.margins: 12; spacing: 6

                            Text { text: "Traffic"; font.pixelSize: 13; font.bold: true; color: theme.foreground; Layout.bottomMargin: 2 }

                            RowLayout { Layout.fillWidth: true
                                RowLayout { spacing: 6
                                    Text { text: "\u{F019}"; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; color: theme.color2 }
                                    Text { text: "Download"; font.pixelSize: 12; color: theme.foreground }
                                }
                                Item { Layout.fillWidth: true }
                                Text { text: infoWidget.downloadSpeed > 0 ? infoWidget.formatSpeed(infoWidget.downloadSpeed) : "0 B/s"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; font.bold: true; color: theme.foreground }
                            }

                            RowLayout { Layout.fillWidth: true
                                RowLayout { spacing: 6
                                    Text { text: "\u{F093}"; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; color: theme.color4 }
                                    Text { text: "Upload"; font.pixelSize: 12; color: theme.foreground }
                                }
                                Item { Layout.fillWidth: true }
                                Text { text: infoWidget.uploadSpeed > 0 ? infoWidget.formatSpeed(infoWidget.uploadSpeed) : "0 B/s"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; font.bold: true; color: theme.foreground }
                            }

                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: theme.muted; opacity: 0.3; Layout.topMargin: 4; Layout.bottomMargin: 4 }

                            RowLayout { Layout.fillWidth: true
                                Text { text: "Total RX / TX"; font.pixelSize: 11; color: theme.muted }
                                Item { Layout.fillWidth: true }
                                Text { text: infoWidget.downloadTotal + " / " + infoWidget.uploadTotal; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; color: theme.foreground }
                            }
                        }
                    }

                    // Interfaces card
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: ifacesContent.implicitHeight + 20
                        radius: root.barRadius
                        color: Qt.darker(theme.background, 1.08)
                        border.color: theme.muted; border.width: root.popupBorderThickness

                        ColumnLayout {
                            id: ifacesContent
                            anchors.fill: parent; anchors.margins: 12; spacing: 6

                            Text { text: "Interfaces"; font.pixelSize: 13; font.bold: true; color: theme.foreground; Layout.bottomMargin: 2 }

                            Repeater {
                                model: infoWidget.netInterfaces

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 28
                                    radius: 4
                                    color: modelData.name === infoWidget.netInterface ? Qt.darker(theme.color4, 1.3) : "transparent"

                                    RowLayout {
                                        anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                        Text { text: "\u{F0C9}"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: theme.muted }
                                        Text { text: modelData.name; font.pixelSize: 12; color: theme.foreground }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: modelData.state === "up" ? "connected" : "disconnected"
                                            font.pixelSize: 11
                                            color: modelData.state === "up" ? theme.color2 : theme.muted
                                        }
                                    }
                                }
                            }

                            Text { visible: infoWidget.netInterfaces.length === 0; text: "No interfaces found"; font.pixelSize: 12; color: theme.muted }
                        }
                    }
                }

                // Divider
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; Layout.topMargin: 16; Layout.bottomMargin: 16; color: theme.muted; opacity: 0.45 }

                // Hardware Monitor
                Text { text: "Hardware Monitor"; font.pixelSize: 16; font.bold: true; color: theme.foreground; Layout.bottomMargin: 12 }

                // Tabs
                RowLayout {
                    Layout.fillWidth: true; Layout.bottomMargin: 16; spacing: 8
                    Repeater {
                        model: ["CPU", "RAM", "GPU"]
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 32; radius: root.barRadius
                            color: hwTab === index ? theme.color4 : "transparent"
                            border.color: hwTab === index ? theme.color4 : theme.muted; border.width: root.popupBorderThickness
                            Text { anchors.centerIn: parent; text: modelData; font.pixelSize: 12; font.bold: hwTab === index; color: hwTab === index ? theme.background : theme.foreground }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: hwTab = index }
                        }
                    }
                }

                // CPU / GPU view: circular gauge
                Item {
                    id: gaugeItem
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    visible: hwTab === 0 || hwTab === 2

                    property real gaugeTemp: hwTab === 0 ? infoWidget.cpuTemp : infoWidget.gpuTemp

                    property color gaugeColor: {
                        if (gaugeTemp >= 80) return theme.color1
                        if (gaugeTemp >= 60) return theme.color3
                        return theme.color2
                    }

                    Canvas {
                        id: gaugeCanvas
                        anchors.centerIn: parent
                        width: 180; height: 180

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var cx = width / 2, cy = height / 2, r = 70, lw = 8

                            ctx.beginPath()
                            ctx.arc(cx, cy, r, 0, Math.PI * 2)
                            ctx.strokeStyle = Qt.darker(theme.background, 1.5)
                            ctx.lineWidth = lw
                            ctx.lineCap = "round"
                            ctx.stroke()

                            var frac = Math.min(Math.max(gaugeItem.gaugeTemp / 100, 0), 1)
                            ctx.beginPath()
                            ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * frac)
                            ctx.strokeStyle = gaugeItem.gaugeColor
                            ctx.lineWidth = lw
                            ctx.lineCap = "round"
                            ctx.stroke()

                            for (var i = 0; i < 12; i++) {
                                var tickAngle = (i / 12) * Math.PI * 2 - Math.PI / 2
                                var innerR = r - lw / 2 - 3
                                var outerR = r - lw / 2 - 7
                                ctx.beginPath()
                                ctx.moveTo(cx + Math.cos(tickAngle) * innerR, cy + Math.sin(tickAngle) * innerR)
                                ctx.lineTo(cx + Math.cos(tickAngle) * outerR, cy + Math.sin(tickAngle) * outerR)
                                ctx.strokeStyle = theme.muted
                                ctx.lineWidth = 1
                                ctx.stroke()
                            }
                        }

                        Connections {
                            target: gaugeItem
                            function onGaugeTempChanged() { gaugeCanvas.requestPaint() }
                        }
                    }

                    Column {
                        anchors.centerIn: parent; spacing: 2; z: 1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: gaugeItem.gaugeTemp + "\u00B0C"
                            font.pixelSize: 28; font.family: "JetBrainsMono Nerd Font"; font.bold: true
                            color: gaugeItem.gaugeColor
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: hwTab === 0
                                ? infoWidget.cpuUsage + "% Usage"
                                : (infoWidget.gpuUsage > 0 ? infoWidget.gpuUsage + "% Usage" : infoWidget.gpuName)
                            font.pixelSize: 12; color: theme.muted
                        }
                    }
                }

                // RAM view
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    visible: hwTab === 1

                    Canvas {
                        id: ramGauge
                        anchors.centerIn: parent
                        width: 180; height: 180

                        property color gaugeColor: {
                            if (infoWidget.ramUsage >= 80) return theme.color1
                            if (infoWidget.ramUsage >= 60) return theme.color3
                            return theme.color2
                        }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var cx = width / 2, cy = height / 2, r = 70, lw = 8

                            ctx.beginPath()
                            ctx.arc(cx, cy, r, 0, Math.PI * 2)
                            ctx.strokeStyle = Qt.darker(theme.background, 1.5)
                            ctx.lineWidth = lw
                            ctx.lineCap = "round"
                            ctx.stroke()

                            var frac = infoWidget.ramUsage / 100
                            ctx.beginPath()
                            ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * frac)
                            ctx.strokeStyle = gaugeColor
                            ctx.lineWidth = lw
                            ctx.lineCap = "round"
                            ctx.stroke()

                            for (var i = 0; i < 12; i++) {
                                var tickAngle = (i / 12) * Math.PI * 2 - Math.PI / 2
                                var innerR = r - lw / 2 - 3
                                var outerR = r - lw / 2 - 7
                                ctx.beginPath()
                                ctx.moveTo(cx + Math.cos(tickAngle) * innerR, cy + Math.sin(tickAngle) * innerR)
                                ctx.lineTo(cx + Math.cos(tickAngle) * outerR, cy + Math.sin(tickAngle) * outerR)
                                ctx.strokeStyle = theme.muted
                                ctx.lineWidth = 1
                                ctx.stroke()
                            }
                        }

                        Connections {
                            target: infoWidget
                            function onRamUsageChanged() { ramGauge.requestPaint() }
                        }
                    }

                    Column {
                        anchors.centerIn: parent; spacing: 2; z: 1
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: infoWidget.ramUsage + "%"; font.pixelSize: 28; font.family: "JetBrainsMono Nerd Font"; font.bold: true; color: theme.foreground }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(infoWidget.ramUsed) + "G / " + Math.round(infoWidget.ramTotal) + "G"; font.pixelSize: 12; color: theme.muted }
                    }
                }
            }
        }

        Rectangle { anchors.fill: parent; radius: root.barRadius; color: "transparent"; border.color: theme.muted; border.width: root.popupBorderThickness; z: 10 }
    }

    Item { anchors.fill: parent; focus: infoPopup.isOpen; Keys.onEscapePressed: infoPopup.close() }
}
