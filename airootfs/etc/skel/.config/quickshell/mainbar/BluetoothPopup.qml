// ═══════════════════════════════════════════════════════════════════════════════
// BluetoothPopup - Bluetooth Device Management Overlay
// ═══════════════════════════════════════════════════════════════════════════════
// Displays Bluetooth adapter status, toggle, and device list with connect/disconnect.
// Shown on the primary monitor when the Bluetooth button is clicked.
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
        visible: btPopup.isOpen
        required property var modelData

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: btPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: btPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked:    btPopup.close()
        }

        Rectangle {
            id: btPanel
            anchors.top:        parent.top
            anchors.horizontalCenter:  parent.horizontalCenter
            anchors.topMargin:  10
            width:    500
            implicitHeight: btColumn.implicitHeight + 32
            height:   implicitHeight
            radius: 5
            color:    theme.background
            opacity:  0.95
            border { width: 2; color: theme.color2 }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id: btColumn
                anchors.fill:    parent
                anchors.margins: 16
                spacing: 0

                // ── Header ─────────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 16
                    spacing: 12

                    Text {
                        text:           bt.btIcon()
                        font.pixelSize: 24
                        color:          bt.enabled ? theme.color2 : theme.muted
                    }

                    Text {
                        text:      "Bluetooth"
                        color:     theme.foreground
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        text:           bt.stateLabel()
                        color:          theme.muted
                        font.pixelSize: 14
                        font.bold:      true
                        font.family:    "JetBrains Mono Nerd Font Mono"
                    }
                }

                // ── Toggle Button ──────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 16
                    implicitHeight: 32
                    radius: 5
                    color:  bt.enabled ? theme.color2 : "transparent"
                    border { width: 2; color: theme.color4 }

                    Text {
                        anchors.centerIn: parent
                        text:  bt.enabled ? "Disable" : "Enable"
                        color: bt.enabled ? theme.background : theme.color2
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    bt.toggle()
                    }
                }

                // ── Device List Header ─────────────────────────────────────────
                Text {
                    text:      "Devices (" + bt.deviceCount + ")"
                    color:     theme.foreground
                    font.pixelSize: 14
                    font.bold: true
                    Layout.bottomMargin: 10
                }

                // ── Device List ────────────────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: bt.adapterValid ? bt.adapter.devices : []

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 48
                            radius: 5
                            color:  modelData.connected ? Qt.darker(theme.background, 1.2) : "transparent"
                            border { width: 2; color: modelData.connected ? theme.color2 : theme.color4 }

                            RowLayout {
                                anchors.fill:         parent
                                anchors.leftMargin:   12
                                anchors.rightMargin:  12
                                anchors.topMargin:    0
                                anchors.bottomMargin: 0
                                spacing: 12

                                // Device Name
                                Text {
                                    text:             modelData.name || modelData.address
                                    color:            modelData.connected ? theme.color2 : theme.foreground
                                    font.pixelSize:   13
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    elide:            Text.ElideRight
                                }

                                // Connection Status
                                Text {
                                    text:               modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "")
                                    color:              modelData.connected ? theme.color2 : theme.muted
                                    font.pixelSize:     11
                                    font.family:        "JetBrains Mono Nerd Font Mono"
                                    Layout.rightMargin: 8
                                    Layout.alignment:   Qt.AlignVCenter
                                }

                                // Connect/Disconnect Button
                                Rectangle {
                                    width:  90
                                    height: 30
                                    radius: 5
                                    color:  modelData.connected ? theme.color1 : "transparent"
                                    border { width: 2; color: theme.color4 }
                                    Layout.alignment:   Qt.AlignVCenter
                                    Layout.rightMargin: 4

                                    Text {
                                        anchors.fill:        parent
                                        text:                modelData.connected ? "Disconnect" : "Connect"
                                        color:               modelData.connected ? theme.background : theme.color2
                                        font.pixelSize:      12
                                        font.bold:           true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment:   Text.AlignVCenter
                                        renderType:          Text.NativeRendering
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape:  Qt.PointingHandCursor
                                        onClicked:    bt.connectDevice(modelData)
                                    }
                                }
                            }
                        }
                    }
                }

                // ── No Devices Message ─────────────────────────────────────────
                Text {
                    visible: bt.deviceCount === 0
                    text:      "No devices found"
                    color:     theme.muted
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 16
                }
            }
        }
    }
}