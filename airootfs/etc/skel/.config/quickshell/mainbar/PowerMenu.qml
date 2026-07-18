// ═══════════════════════════════════════════════════════════════════════════════
// PowerMenu - Power Options Overlay
// ═══════════════════════════════════════════════════════════════════════════════
// Displays shutdown, reboot, and lock buttons with a cancel option.
// Shown on all screens when the power button is clicked.
//
// Required properties (passed from shell.qml):
//   visible       - Whether the popup is shown
//   onClose       - Signal to close the popup
//   onRunCommand  - Function to execute a shell command
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        screen:  modelData
        visible: powerMenu.isOpen
        required property var modelData

        anchors { top: true; bottom: true; left: true; right: true }

        color:    "transparent"
        focusable: powerMenu.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: powerMenu.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // Dim backdrop
        Rectangle {
            anchors.fill: parent
            color:        Qt.rgba(theme.background.r, theme.background.g, theme.background.b, 0.72)

            MouseArea {
                anchors.fill: parent
                onClicked:    powerMenu.close()
            }
        }

        // Dialog
        Item {
            anchors.fill: parent
            focus:        powerMenu.isOpen
            Keys.onEscapePressed: powerMenu.close()

            Rectangle {
                anchors.centerIn: parent
                width:        Math.min(420, parent.width - 48)
                height:       powerColumn.implicitHeight + 40
                radius: 5
                color:        theme.background
                border { color: theme.color2; width: 2 }

                MouseArea {
                    anchors.fill: parent
                    onClicked:    mouse => mouse.accepted = true
                }

                ColumnLayout {
                    id:               powerColumn
                    anchors.centerIn: parent
                    spacing:          22

                    Text {
                        text:             "Power Menu"
                        color:            theme.foreground
                        font.pixelSize:   20
                        font.bold:        true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        spacing:          20
                        Layout.alignment: Qt.AlignHCenter

                        PowerButton {
                            icon:        "󰐥"
                            label:       "Shutdown"
                            bgColor:     theme.color1
                            textColor:   theme.background
                            onActivated: powerMenu.runCmd("systemctl poweroff")
                        }

                        PowerButton {
                            icon:        "󰜉"
                            label:       "Reboot"
                            bgColor:     theme.color2
                            textColor:   theme.background
                            onActivated: powerMenu.runCmd("systemctl reboot")
                        }

                        PowerButton {
                            icon:        "󰍀"
                            label:       "Lock"
                            bgColor:     theme.color4
                            textColor:   theme.background
                            onActivated: powerMenu.runCmd("hyprlock")
                        }
                    }

                    Rectangle {
                        width:            90
                        height:           32
                        radius: 5
                        color:            theme.color1
                        opacity:          cancelMouse.containsMouse ? 0.6 : 1.0
                        Layout.alignment: Qt.AlignHCenter

                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text:             "Cancel"
                            color:            theme.background
                            font.bold:        true
                        }

                        MouseArea {
                            id:               cancelMouse
                            anchors.fill:     parent
                            cursorShape:      Qt.PointingHandCursor
                            hoverEnabled:     true
                            onClicked:        powerMenu.close()
                        }
                    }
                }
            }
        }
    }

    // ── PowerButton Component ─────────────────────────────────────────────
    component PowerButton: ColumnLayout {
        id: powerButtonRoot

        property string icon
        property string label
        property color  bgColor
        property color  textColor

        signal activated()

        spacing: 8

        Rectangle {
            width:            58
            height:           58
            radius: 5
            color:            powerButtonRoot.bgColor
            opacity:          buttonMouse.containsMouse ? 0.6 : 1.0
            Layout.alignment: Qt.AlignHCenter

            Behavior on opacity { NumberAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text:             powerButtonRoot.icon
                font.pixelSize:   40
                color:            powerButtonRoot.textColor
            }

            MouseArea {
                id:               buttonMouse
                anchors.fill:     parent
                cursorShape:      Qt.PointingHandCursor
                hoverEnabled:     true
                onClicked:        powerButtonRoot.activated()
            }
        }

        Text {
            text:             powerButtonRoot.label
            color:            powerButtonRoot.textColor
            font.pixelSize:   11
            font.bold:        true
            Layout.alignment: Qt.AlignHCenter
        }
    }
}