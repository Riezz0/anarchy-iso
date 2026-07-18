// ═══════════════════════════════════════════════════════════════════════════════
// VolumePopup - Volume Control Overlay
// ═══════════════════════════════════════════════════════════════════════════════
// Displays a volume slider popup with mute/unmute and mixer launch.
// Shown on the primary monitor when the volume button is clicked.
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
        visible: volumePopup.isOpen
        required property var modelData

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: volumePopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: volumePopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked:    volumePopup.close()
        }

        Rectangle {
            id: volumePanel
            anchors.top:        parent.top
            anchors.horizontalCenter:  parent.horizontalCenter
            anchors.topMargin:  10
            width:    500
            implicitHeight: volumeColumn.implicitHeight + 28
            height:   implicitHeight
            radius: 5
            color:    theme.background
            opacity:  0.90
            border { width: 2; color: theme.color2 }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id: volumeColumn
                anchors.fill:    parent
                anchors.margins: 14
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text:           audio.volumeIcon()
                        font.pixelSize: 22
                        color:          audio.volumeMuted ? theme.color1 : theme.color2
                    }

                    Text {
                        text:      "Volume"
                        color:     theme.foreground
                        font.pixelSize: 16
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        text:        Math.round(audio.volumeLevel * 100) + "%"
                        color:       theme.muted
                        font.pixelSize: 14
                        font.bold:   true
                        font.family: "JetBrains Mono Nerd Font Mono"
                    }
                }

                // Slider
                Rectangle {
                    id:     sliderTrack
                    Layout.fillWidth: true
                    implicitHeight: 14
                    radius: 5
                    color:  Qt.darker(theme.background, 1.3)
                    border { width: 2; color: theme.color4 }

                    Rectangle {
                        anchors {
                            left:   parent.left
                            top:    parent.top
                            bottom: parent.bottom
                        }
                        width:  parent.width * Math.min(Math.max(audio.volumeLevel, 0), 1)
                        radius: 5
                        color:  audio.volumeMuted ? theme.muted : theme.color2

                        Behavior on width { NumberAnimation { duration: 80 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onPressed:         mouse => audio.setVolume(mouse.x / width)
                        onPositionChanged: mouse => { if (pressed) audio.setVolume(mouse.x / width) }
                    }
                }

                // Output device name
                Text {
                    text:    audio.audioSink
                                 ? (audio.audioSink.description || audio.audioSink.name)
                                 : "No output device"
                    color:   theme.muted
                    font.pixelSize: 12
                    elide:   Text.ElideRight
                    Layout.fillWidth: true
                }

                // Actions
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 5
                        color:  audio.volumeMuted ? theme.color1 : "transparent"
                        border { width: 2; color: theme.color4 }

                        Text {
                            anchors.centerIn: parent
                            text:  audio.volumeMuted ? "Unmute" : "Mute"
                            color: audio.volumeMuted ? theme.background : theme.color2
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    audio.toggleMute()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 5
                        color:  "transparent"
                        border { width: 2; color: theme.color4 }

                        Text {
                            anchors.centerIn: parent
                            text:  "Mixer"
                            color: theme.color2
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                volumePopup.close()
                                root.runCommand("bash /usr/local/bin/pulse.sh")
                            }
                        }
                    }
                }
            }
        }
    }
}