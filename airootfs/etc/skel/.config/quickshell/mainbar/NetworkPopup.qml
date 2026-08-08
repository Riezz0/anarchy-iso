// ═══════════════════════════════════════════════════════════════════════════════
// NetworkPopup - Network Settings Overlay
// ═══════════════════════════════════════════════════════════════════════════════
// Displays network details, interface switching, DNS config, and traffic stats.
// Shown on the primary monitor when the network button is clicked.
//
// Required properties (passed from shell.qml):
//   visible       - Whether the popup is shown
//   onClose       - Signal to close the popup
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
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
        focusable: networkPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: networkPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        Connections {
            target: networkPopup
            function onIsOpenChanged() {
                if (networkPopup.isOpen) { panelVisible = true }
                else { hideTimer.start() }
            }
        }

        Timer { id: hideTimer; interval: 220; onTriggered: panelVisible = false }

        MouseArea {
            anchors.fill: parent
            onClicked:    networkPopup.close()
            opacity: networkPopup.isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Rectangle {
            id: netPanel
            anchors.top:        parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin:  10
            width:    520
            implicitHeight: netColumn.implicitHeight + 32
            height:   implicitHeight
            radius:   barSettings.barRadius
            color:    theme.background
            opacity:  networkPopup.isOpen ? 0.95 : 0
            scale:    networkPopup.isOpen ? 1.0 : 0.95
            y:        networkPopup.isOpen ? 0 : -20
            border { width: barSettings.borderThickness; color: theme.color4 }

            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on y       { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            opacity:  0.95
            border { width: barSettings.borderThickness; color: theme.color2 }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id: netColumn
                anchors.fill:    parent
                anchors.margins: 16
                spacing: 0

                // ── Header ─────────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 16
                    spacing: 12

                    Text {
                        text:           net.networkIcon()
                        font.pixelSize: 24
                        font.family:    "JetBrains Mono Nerd Font Mono"
                        color:          net.networkColor()
                    }

                    Text {
                        text:      "Network"
                        color:     theme.foreground
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        text:           net.connectionName()
                        color:          theme.muted
                        font.pixelSize: 14
                        font.bold:      true
                        font.family:    "JetBrains Mono Nerd Font Mono"
                    }
                }

                // ── Connection Details ──────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 12
                    implicitHeight: detailsColumn.implicitHeight + 20
                    radius:   barSettings.barRadius
                    color:  Qt.darker(theme.background, 1.2)
                    border { width: barSettings.borderThickness; color: theme.color4 }

                    ColumnLayout {
                        id: detailsColumn
                        anchors.fill:    parent
                        anchors.margins: 10
                        spacing: 6

                        // Interface
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Interface"; color: theme.muted; font.pixelSize: 12; Layout.preferredWidth: 100 }
                            Text { text: net.interfaceName; color: theme.foreground; font.pixelSize: 12; font.family: "JetBrains Mono Nerd Font Mono"; Layout.fillWidth: true }
                        }

                        // IP Address
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "IPv4"; color: theme.muted; font.pixelSize: 12; Layout.preferredWidth: 100 }
                            Text { text: net.ipAddress; color: theme.foreground; font.pixelSize: 12; font.family: "JetBrains Mono Nerd Font Mono"; Layout.fillWidth: true }
                        }

                        // Gateway
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Gateway"; color: theme.muted; font.pixelSize: 12; Layout.preferredWidth: 100 }
                            Text { text: net.gateway; color: theme.foreground; font.pixelSize: 12; font.family: "JetBrains Mono Nerd Font Mono"; Layout.fillWidth: true }
                        }

                        // DNS
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "DNS"; color: theme.muted; font.pixelSize: 12; Layout.preferredWidth: 100 }
                            Text { text: net.dns; color: theme.foreground; font.pixelSize: 12; font.family: "JetBrains Mono Nerd Font Mono"; Layout.fillWidth: true }
                        }

                        // MAC
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "MAC"; color: theme.muted; font.pixelSize: 12; Layout.preferredWidth: 100 }
                            Text { text: net.macAddress; color: theme.foreground; font.pixelSize: 12; font.family: "JetBrains Mono Nerd Font Mono"; Layout.fillWidth: true }
                        }

                        // Wi-Fi specific
                        RowLayout {
                            visible: net.connectionType === "wifi"
                            Layout.fillWidth: true
                            Text { text: "SSID"; color: theme.muted; font.pixelSize: 12; Layout.preferredWidth: 100 }
                            Text { text: net.ssid || "--"; color: theme.foreground; font.pixelSize: 12; font.family: "JetBrains Mono Nerd Font Mono"; Layout.fillWidth: true }
                        }

                        RowLayout {
                            visible: net.connectionType === "wifi"
                            Layout.fillWidth: true
                            Text { text: "Signal"; color: theme.muted; font.pixelSize: 12; Layout.preferredWidth: 100 }
                            Text { text: net.signalStrength + "%"; color: theme.foreground; font.pixelSize: 12; font.family: "JetBrains Mono Nerd Font Mono"; Layout.fillWidth: true }
                        }
                    }
                }

                // ── Traffic Stats ───────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 12
                    implicitHeight: trafficRow.implicitHeight + 20
                    radius:   barSettings.barRadius
                    color:  Qt.darker(theme.background, 1.2)
                    border { width: barSettings.borderThickness; color: theme.color4 }

                    RowLayout {
                        id: trafficRow
                        anchors.fill:    parent
                        anchors.margins: 10
                        spacing: 20

                        // Download
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text:      "↓ Download"
                                color:     theme.muted
                                font.pixelSize: 11
                            }
                            Text {
                                text:           net.rxRate
                                color:          theme.color6
                                font.pixelSize: 14
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                            }
                            Text {
                                text:           net.rxBytes + " total"
                                color:          theme.muted
                                font.pixelSize: 10
                                font.family:    "JetBrains Mono Nerd Font Mono"
                            }
                        }

                        // Upload
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text:      "↑ Upload"
                                color:     theme.muted
                                font.pixelSize: 11
                            }
                            Text {
                                text:           net.txRate
                                color:          theme.color4
                                font.pixelSize: 14
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                            }
                            Text {
                                text:           net.txBytes + " total"
                                color:          theme.muted
                                font.pixelSize: 10
                                font.family:    "JetBrains Mono Nerd Font Mono"
                            }
                        }
                    }
                }

                // ── Interface Switcher ──────────────────────────────────────────
                Text {
                    text:      "Interfaces"
                    color:     theme.foreground
                    font.pixelSize: 14
                    font.bold: true
                    Layout.bottomMargin: 8
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 12
                    spacing: 6

                    Repeater {
                        model: net.interfaces

                        Rectangle {
                            required property var modelData
                            property bool isActive: modelData.device === net.interfaceName
                            Layout.fillWidth: true
                            implicitHeight: 40
                            radius:   barSettings.barRadius
                            color:  isActive ? Qt.darker(theme.background, 1.3) : "transparent"
                            border { width: barSettings.borderThickness; color: isActive ? theme.color2 : theme.color4 }

                            RowLayout {
                                anchors.fill:         parent
                                anchors.leftMargin:   12
                                anchors.rightMargin:  12
                                spacing: 10

                                // Status dot
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: modelData.state === "connected" ? theme.color6 : theme.muted
                                }

                                // Device name
                                Text {
                                    text:             modelData.device
                                    color:            isActive ? theme.color2 : theme.foreground
                                    font.pixelSize:   13
                                    font.bold:        isActive
                                    font.family:      "JetBrains Mono Nerd Font Mono"
                                    Layout.fillWidth: true
                                }

                                // Type badge
                                Rectangle {
                                    implicitWidth: typeLabel.implicitWidth + 12
                                    implicitHeight: 22
                                    radius: 3
                                    color:  modelData.type === "wifi" ? Qt.rgba(theme.color4.r, theme.color4.g, theme.color4.b, 0.2) : Qt.rgba(theme.color6.r, theme.color6.g, theme.color6.b, 0.2)

                                    Text {
                                        id: typeLabel
                                        anchors.centerIn: parent
                                        text:   modelData.type === "wifi" ? "Wi-Fi" : "Ethernet"
                                        color:  modelData.type === "wifi" ? theme.color4 : theme.color6
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }

                                // State badge
                                Text {
                                    text:  modelData.state
                                    color: modelData.state === "connected" ? theme.color6 : theme.muted
                                    font.pixelSize: 11
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                }

                                // Connect button
                                Rectangle {
                                    visible: !isActive
                                    width: 70; height: 26; radius: 4
                                    color:  "transparent"
                                    border { width: barSettings.borderThickness; color: theme.color4 }

                                    Text {
                                        anchors.centerIn: parent
                                        text:      "Switch"
                                        color:     theme.color2
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape:  Qt.PointingHandCursor
                                        onClicked:    net.switchInterface(modelData.device)
                                    }
                                }
                            }
                        }
                    }
                }

                // ── DNS Settings ────────────────────────────────────────────────
                Text {
                    text:      "DNS Settings"
                    color:     theme.foreground
                    font.pixelSize: 14
                    font.bold: true
                    Layout.bottomMargin: 8
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 12
                    implicitHeight: dnsRow.implicitHeight + 20
                    radius:   barSettings.barRadius
                    color:  Qt.darker(theme.background, 1.2)
                    border { width: barSettings.borderThickness; color: theme.color4 }

                    RowLayout {
                        id: dnsRow
                        anchors.fill:    parent
                        anchors.margins: 10
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 32
                            radius: 4
                            color:  Qt.darker(theme.background, 1.5)
                            border { width: barSettings.borderThickness; color: theme.color4 }

                            TextInput {
                                id: dnsInput
                                anchors.fill:    parent
                                anchors.margins: 8
                                color:           theme.foreground
                                font.pixelSize:  12
                                font.family:     "JetBrains Mono Nerd Font Mono"
                                clip:            true
                                verticalAlignment: TextInput.AlignVCenter
                                selectByMouse:   true
                                selectionColor:   theme.color2

                                property string placeholderText: "Custom DNS (e.g. 1.1.1.1)"

                                Text {
                                    visible:   !dnsInput.text && !dnsInput.activeFocus
                                    text:      dnsInput.placeholderText
                                    color:     theme.muted
                                    font:      dnsInput.font
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                onAccepted: {
                                    if (text.length >= 7)
                                        net.setDns(text)
                                }
                            }
                        }

                        // Set DNS button
                        Rectangle {
                            implicitWidth: 60; implicitHeight: 32
                            radius: 4
                            color:  "transparent"
                            border { width: barSettings.borderThickness; color: theme.color4 }

                            Text {
                                anchors.centerIn: parent
                                text:      "Set"
                                color:     theme.color2
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    if (dnsInput.text.length >= 7)
                                        net.setDns(dnsInput.text)
                                }
                            }
                        }

                        // Reset DNS button
                        Rectangle {
                            implicitWidth: 60; implicitHeight: 32
                            radius: 4
                            color:  "transparent"
                            border { width: barSettings.borderThickness; color: theme.color1 }

                            Text {
                                anchors.centerIn: parent
                                text:      "Reset"
                                color:     theme.color1
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    net.resetDns()
                                    dnsInput.text = ""
                                }
                            }
                        }
                    }
                }

                // ── Refresh Button ──────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius:   barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: theme.color4 }

                    Text {
                        anchors.centerIn: parent
                        text:      "Refresh"
                        color:     theme.color2
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    net.refresh()
                    }
                }
            }
        }
    }
}
