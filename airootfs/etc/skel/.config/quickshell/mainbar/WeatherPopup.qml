// ═══════════════════════════════════════════════════════════════════════════════
// WeatherPopup - Weather Details Overlay
// ═══════════════════════════════════════════════════════════════════════════════
// Displays detailed weather information including temperature, humidity, wind,
// pressure, UV index, visibility, and cloud cover.
// Shown on the primary monitor when the weather button is clicked.
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
        visible: weatherPopup.isOpen
        required property var modelData

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: weatherPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: weatherPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked:    weatherPopup.close()
        }

        Rectangle {
            id: weatherPanel
            anchors.top:        parent.top
            anchors.horizontalCenter:  parent.horizontalCenter
            anchors.topMargin:  10
            width:    600
            implicitHeight: weatherColumn.implicitHeight + 32
            height:   implicitHeight
            radius: 5
            color:    theme.background
            opacity:  0.95
            border { width: 2; color: theme.color4 }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id: weatherColumn
                anchors.fill:    parent
                anchors.margins: 16
                spacing: 12

                // ── Header ──────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text:           weather.weatherIconText()
                        font.pixelSize: 36
                        color:          theme.color4
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text:      weather.locationDisplay()
                            color:     theme.foreground
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Text {
                            text:      weather.shortCondition()
                            color:     theme.muted
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text:           weather.loaded ? weather.tempDisplay() : "--"
                        color:          theme.color4
                        font.pixelSize: 36
                        font.bold:      true
                        font.family:    "JetBrains Mono Nerd Font Mono"
                    }
                }

                // ── Separator ────────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 4
                    Layout.topMargin: 4
                    height: 1
                    color: theme.muted
                    opacity: 0.4
                }

                // ── Stats Grid ──────────────────────────────────────────────
                GridLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    columns: 3
                    columnSpacing: 12
                    rowSpacing: 12

                    // Feels Like
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        Layout.alignment: Qt.AlignHCenter
                        radius: 5
                        color: "transparent"
                        border { width: 2; color: Qt.darker(theme.muted, 1.5) }

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text:           "󱥋"
                                font.pixelSize: 24
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.color6
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           weather.feelsLikeC + "°C"
                                font.pixelSize: 18
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.foreground
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           "Feels Like"
                                font.pixelSize: 12
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.muted
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // Humidity
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        Layout.alignment: Qt.AlignHCenter
                        radius: 5
                        color: "transparent"
                        border { width: 2; color: Qt.darker(theme.muted, 1.5) }

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text:           "󰖎"
                                font.pixelSize: 24
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.color3
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           weather.humidity + "%"
                                font.pixelSize: 18
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.foreground
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           "Humidity"
                                font.pixelSize: 12
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.muted
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // Wind
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        Layout.alignment: Qt.AlignHCenter
                        radius: 5
                        color: "transparent"
                        border { width: 2; color: Qt.darker(theme.muted, 1.5) }

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text:           "󰖝"
                                font.pixelSize: 24
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.color5
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           weather.windSpeed + " km/h"
                                font.pixelSize: 18
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.foreground
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           weather.windDir
                                font.pixelSize: 12
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.muted
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // Pressure
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        Layout.alignment: Qt.AlignHCenter
                        radius: 5
                        color: "transparent"
                        border { width: 2; color: Qt.darker(theme.muted, 1.5) }

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text:           "󰖂"
                                font.pixelSize: 24
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.color2
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           weather.pressure + " hPa"
                                font.pixelSize: 18
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.foreground
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           "Pressure"
                                font.pixelSize: 12
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.muted
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // UV Index
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        Layout.alignment: Qt.AlignHCenter
                        radius: 5
                        color: "transparent"
                        border { width: 2; color: Qt.darker(theme.muted, 1.5) }

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text:           "󰖨"
                                font.pixelSize: 24
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.color1
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           weather.uvIndex
                                font.pixelSize: 18
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.foreground
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           "UV Index"
                                font.pixelSize: 12
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.muted
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // Visibility
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        Layout.alignment: Qt.AlignHCenter
                        radius: 5
                        color: "transparent"
                        border { width: 2; color: Qt.darker(theme.muted, 1.5) }

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text:           "󰈈"
                                font.pixelSize: 24
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.color4
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           weather.visibility + " km"
                                font.pixelSize: 18
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.foreground
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text:           "Visibility"
                                font.pixelSize: 12
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.muted
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                // ── Cloud Cover ─────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 24
                        radius: 5
                        color: Qt.darker(theme.background, 1.3)

                        Rectangle {
                            anchors {
                                left:   parent.left
                                top:    parent.top
                                bottom: parent.bottom
                            }
                            width: parent.width * (parseInt(weather.cloudCover) / 100)
                            radius: 5
                            color: theme.color4
                            opacity: 0.6
                        }
                    }

                    Text {
                        text:           weather.cloudCover + "% clouds"
                        font.pixelSize: 14
                        font.family:    "JetBrains Mono Nerd Font Mono"
                        color:          theme.muted
                    }
                }

                // ── Refresh Button ──────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    implicitHeight: 32
                    radius: 5
                    color:  "transparent"
                    border { width: 2; color: theme.color4 }

                    Text {
                        anchors.centerIn: parent
                        text:  "Refresh"
                        color: theme.color4
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    weather.refresh()
                    }
                }
            }
        }
    }
}