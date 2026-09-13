import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: powerMenuWindow
        screen: modelData
        required property var modelData

        visible: panelVisible

        property bool panelVisible: false
        property bool isTargetScreen: powerMenu.targetScreen === modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        focusable: powerMenu.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: powerMenu.isOpen && isTargetScreen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        Connections {
            target: powerMenu
            function onIsOpenChanged() {
                if (powerMenu.isOpen) { panelVisible = true }
                else { hideTimer.start() }
            }
        }

        Timer { id: hideTimer; interval: 220; onTriggered: panelVisible = false }

        // Dim backdrop on all screens
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(theme.background.r, theme.background.g, theme.background.b, powerMenu.isOpen ? 0.72 : 0)

            Behavior on color { ColorAnimation { duration: 200 } }

            MouseArea {
                anchors.fill: parent
                onClicked: powerMenu.close()
            }
        }

        // Dialog only on target screen
        Item {
            anchors.fill: parent
            visible: isTargetScreen
            focus: powerMenu.isOpen
            Keys.onEscapePressed: powerMenu.close()

            Rectangle {
                id: powerDialog
                anchors.centerIn: parent
                width: Math.min(420, parent.width - 48)
                height: powerColumn.implicitHeight + 40
                radius: root.barRadius
                color: theme.background
                opacity: powerMenu.isOpen ? root.popupOpacity : 0
                scale: powerMenu.isOpen ? 1.0 : 0.95
                border.color: theme.muted
                border.width: root.popupBorderThickness

                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => mouse.accepted = true
                }

                ColumnLayout {
                    id: powerColumn
                    anchors.centerIn: parent
                    spacing: 22

                    Text {
                        text: "Power Menu"
                        color: theme.foreground
                        font.pixelSize: 20
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        spacing: 20
                        Layout.alignment: Qt.AlignHCenter

                        // Shutdown
                        ColumnLayout {
                            spacing: 8

                            Rectangle {
                                width: 58
                                height: 58
                                radius: root.barRadius
                                color: theme.color1
                                opacity: shutdownMouse.containsMouse ? 0.6 : 1.0
                                Layout.alignment: Qt.AlignHCenter
                                border.color: theme.muted
                                border.width: root.moduleBorderThickness

                                Behavior on opacity { NumberAnimation { duration: 150 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰐥"
                                    font.pixelSize: 32
                                    color: theme.background
                                }

                                MouseArea {
                                    id: shutdownMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: powerMenu.runCmd("systemctl poweroff")
                                }
                            }

                            Text {
                                text: "Shutdown"
                                color: theme.foreground
                                font.pixelSize: 11
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        // Reboot
                        ColumnLayout {
                            spacing: 8

                            Rectangle {
                                width: 58
                                height: 58
                                radius: root.barRadius
                                color: theme.color2
                                opacity: rebootMouse.containsMouse ? 0.6 : 1.0
                                Layout.alignment: Qt.AlignHCenter
                                border.color: theme.muted
                                border.width: root.moduleBorderThickness

                                Behavior on opacity { NumberAnimation { duration: 150 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰑐"
                                    font.pixelSize: 32
                                    color: theme.background
                                }

                                MouseArea {
                                    id: rebootMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: powerMenu.runCmd("systemctl reboot")
                                }
                            }

                            Text {
                                text: "Reboot"
                                color: theme.foreground
                                font.pixelSize: 11
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        // Lock
                        ColumnLayout {
                            spacing: 8

                            Rectangle {
                                width: 58
                                height: 58
                                radius: root.barRadius
                                color: theme.color4
                                opacity: lockMouse.containsMouse ? 0.6 : 1.0
                                Layout.alignment: Qt.AlignHCenter
                                border.color: theme.muted
                                border.width: root.moduleBorderThickness

                                Behavior on opacity { NumberAnimation { duration: 150 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰌾"
                                    font.pixelSize: 32
                                    color: theme.background
                                }

                                MouseArea {
                                    id: lockMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: powerMenu.runCmd("hyprlock")
                                }
                            }

                            Text {
                                text: "Lock"
                                color: theme.foreground
                                font.pixelSize: 11
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // Cancel button
                    Rectangle {
                        width: 90
                        height: 32
                        radius: root.barRadius
                        color: theme.muted
                        opacity: cancelMouse.containsMouse ? 0.6 : 1.0
                        Layout.alignment: Qt.AlignHCenter
                        border.color: theme.foreground
                        border.width: root.moduleBorderThickness

                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: theme.foreground
                            font.bold: true
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: cancelMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: powerMenu.close()
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: root.barRadius
                    color: "transparent"
                    border.color: theme.muted
                    border.width: root.popupBorderThickness
                    z: 10
                }
            }
        }
    }
}
