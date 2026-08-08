import QtQuick
import QtQuick.Layouts
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
        focusable: salaatPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: salaatPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        Connections {
            target: salaatPopup
            function onIsOpenChanged() {
                if (salaatPopup.isOpen) { panelVisible = true }
                else { hideTimer.start() }
            }
        }

        Timer { id: hideTimer; interval: 220; onTriggered: panelVisible = false }

        MouseArea {
            anchors.fill: parent
            onClicked:    salaatPopup.close()
            opacity: salaatPopup.isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Rectangle {
            id: salaatPanel
            anchors.top:        parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin:  10
            width:    320
            implicitHeight: popupColumn.implicitHeight + 32
            height:   implicitHeight
            radius:   barSettings.barRadius
            color:    theme.background
            opacity:  salaatPopup.isOpen ? 0.95 : 0
            scale:    salaatPopup.isOpen ? 1.0 : 0.95
            y:        salaatPopup.isOpen ? 0 : -20
            border { width: barSettings.borderThickness; color: theme.color3 }

            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on y       { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id: popupColumn
                anchors.fill:    parent
                anchors.margins: 16
                spacing: 0

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Layout.bottomMargin: 4

                    Text {
                        text:           "󰽥"
                        font.pixelSize: 22
                        font.family:    "JetBrains Mono Nerd Font Mono"
                        color:          theme.color3
                    }

                    Text {
                        text:           "Prayer Times"
                        font.pixelSize: 16
                        font.bold:      true
                        color:          theme.foreground
                        Layout.fillWidth: true
                    }
                }

                Text {
                    text:           salaat.locationName || ""
                    font.pixelSize: 14
                    color:          theme.muted
                    Layout.bottomMargin: 8
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    height: 1
                    color: theme.muted
                    opacity: 0.4
                }

                // Prayer time rows
                Repeater {
                    model: [
                        { name: "Fajr",    time: salaat.fajr },
                        { name: "Sunrise", time: salaat.sunrise },
                        { name: "Dhuhr",   time: salaat.dhuhr },
                        { name: "Asr",     time: salaat.asr },
                        { name: "Maghrib", time: salaat.maghrib },
                        { name: "Isha",    time: salaat.isha }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        Layout.bottomMargin: 4
                        radius:   barSettings.barRadius
                        color: modelData.name === salaat.nextPrayer
                            ? Qt.darker(theme.color3, 1.5)
                            : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            Text {
                                text:           modelData.name
                                font.pixelSize: 14
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          modelData.name === salaat.nextPrayer
                                    ? theme.muted : theme.foreground
                                Layout.fillWidth: true
                            }

                            Text {
                                text:           modelData.time
                                font.pixelSize: 14
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          modelData.name === salaat.nextPrayer
                                    ? theme.muted : theme.muted
                            }
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    height: 1
                    color: theme.muted
                    opacity: 0.4
                }

                // App launchers
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius:   barSettings.barRadius
                        color: quranBtnArea.containsMouse ? Qt.darker(theme.color4, 1.3) : "transparent"
                        border { width: barSettings.borderThickness; color: theme.color4 }

                        Text {
                            anchors.centerIn: parent
                            text:           "Quran"
                            font.pixelSize: 14
                            font.bold:      true
                            font.family:    "JetBrains Mono Nerd Font Mono"
                            color:          theme.color4
                        }

                        MouseArea {
                            id: quranBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                salaatPopup.close()
                                root.runCommand("chromium --app=https://www.quranwbw.com")
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius:   barSettings.barRadius
                        color: sunnahBtnArea.containsMouse ? Qt.darker(theme.color5, 1.3) : "transparent"
                        border { width: barSettings.borderThickness; color: theme.color5 }

                        Text {
                            anchors.centerIn: parent
                            text:           "Sunnah"
                            font.pixelSize: 14
                            font.bold:      true
                            font.family:    "JetBrains Mono Nerd Font Mono"
                            color:          theme.color5
                        }

                        MouseArea {
                            id: sunnahBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                salaatPopup.close()
                                root.runCommand("chromium --app=https://www.sunnah.com")
                            }
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    height: 1
                    color: theme.muted
                    opacity: 0.4
                }

                // Quran Player button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius:   barSettings.barRadius
                    color: quranPlayerBtnArea.containsMouse ? Qt.darker(theme.color3, 1.3) : "transparent"
                    border { width: barSettings.borderThickness; color: theme.color3 }

                    Row {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "󰎈"
                            font.pixelSize: 14
                            color: theme.color3
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Quran Player"
                            font.pixelSize: 14
                            font.bold: true
                            font.family: "JetBrains Mono Nerd Font Mono"
                            color: theme.color3
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: quranPlayerBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            salaatPopup.close()
                            root.quranPlayerPopupOpen = true
                        }
                    }
                }
            }
        }
    }
}
