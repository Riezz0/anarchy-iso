// ═══════════════════════════════════════════════════════════════════════════════
// CalendarPopup - Calendar Date Picker Overlay
// ═══════════════════════════════════════════════════════════════════════════════
// Displays a monthly calendar grid with navigation and "Today" button.
// Shown on the primary monitor when the clock is clicked.
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
    model: barSettings.popupScreens()

    PanelWindow {
        screen:  modelData
        visible: panelVisible
        required property var modelData

        property bool panelVisible: false

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: calPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: calPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        Connections {
            target: calPopup
            function onIsOpenChanged() {
                if (calPopup.isOpen) {
                    panelVisible = true
                } else {
                    hideTimer.start()
                }
            }
        }

        Timer {
            id: hideTimer
            interval: 220
            onTriggered: panelVisible = false
        }

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked:    calPopup.close()
            opacity: calPopup.isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Rectangle {
            id: calendarPanel
            anchors.top:        parent.top
            anchors.horizontalCenter:  parent.horizontalCenter
            anchors.topMargin:  10
            width:    400
            implicitHeight: calendarColumn.implicitHeight + 32
            height:   implicitHeight
            radius:   barSettings.barRadius
            color:    theme.background
            opacity:  calPopup.isOpen ? 0.95 : 0
            scale:    calPopup.isOpen ? 1.0 : 0.95
            y:        calPopup.isOpen ? 0 : -20
            border { width: barSettings.borderThickness; color: theme.color4 }

            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on y       { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id: calendarColumn
                anchors.fill:    parent
                anchors.margins: 16
                spacing: 10

                // ── Header ──────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        width: 28; height: 28; radius: barSettings.barRadius
                        color: "transparent"
                        border { width: barSettings.borderThickness; color: theme.color4 }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅁"
                            font.pixelSize: 14
                            font.family: "JetBrains Mono Nerd Font Mono"
                            color: theme.color4
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calendar.prevMonth()
                        }
                    }

                    Text {
                        text: calendar.calendarMonthName()
                        color: theme.foreground
                        font.pixelSize: 16
                        font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        width: 28; height: 28; radius: barSettings.barRadius
                        color: "transparent"
                        border { width: barSettings.borderThickness; color: theme.color4 }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅂"
                            font.pixelSize: 14
                            font.family: "JetBrains Mono Nerd Font Mono"
                            color: theme.color4
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calendar.nextMonth()
                        }
                    }
                }

                // ── Calendar Grid ───────────────────────────────────────
                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 0
                    rowSpacing: 4

                    // Day-of-week headers
                    Repeater {
                        model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

                        Text {
                            text: modelData
                            font.pixelSize: 11
                            font.bold: true
                            font.family: "JetBrains Mono Nerd Font Mono"
                            color: theme.muted
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            horizontalAlignment: Text.AlignHCenter
                            topPadding: 4
                            bottomPadding: 4
                        }
                    }

                    // Separator (spans all 7 columns)
                    Rectangle {
                        Layout.columnSpan: 7
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                        height: 1
                        color: theme.muted
                        opacity: 0.3
                    }

                    // Calendar day cells
                    Repeater {
                        model: 42  // 6 rows * 7 columns

                        Rectangle {
                            required property int index
                            property int rowIndex: Math.floor(index / 7)
                            property int colIndex: index % 7
                            property int dayNum: {
                                var y = calendar.calendarDate.getFullYear()
                                var m = calendar.calendarDate.getMonth()
                                var firstDay = calendar.firstDayOfMonth(y, m)
                                var totalDays = calendar.daysInMonth(y, m)
                                var day = (rowIndex * 7) + colIndex - firstDay + 1
                                if (day < 1 || day > totalDays) return 0
                                return day
                            }
                            property bool isToday: {
                                if (dayNum === 0) return false
                                var now = new Date()
                                return dayNum === now.getDate()
                                    && calendar.calendarDate.getMonth() === now.getMonth()
                                    && calendar.calendarDate.getFullYear() === now.getFullYear()
                            }

                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 32
                            radius:   barSettings.barRadius
                            color: isToday ? theme.color2 : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: dayNum === 0 ? "" : dayNum.toString()
                                font.pixelSize: 12
                                font.family: "JetBrains Mono Nerd Font Mono"
                                font.bold: isToday
                                color: isToday ? theme.background : (dayNum === 0 ? "transparent" : theme.foreground)
                            }
                        }
                    }
                }

                // ── Today Button ────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    implicitHeight: 28
                    radius:   barSettings.barRadius
                    color: "transparent"
                    border { width: barSettings.borderThickness; color: theme.color4 }

                    Text {
                        anchors.centerIn: parent
                        text: "Today"
                        color: theme.color4
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calendar.goToToday()
                    }
                }
            }
        }
    }
}