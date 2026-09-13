import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: calendarWindow

    visible: calendarPopup.isOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    focusable: calendarPopup.isOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: calendarPopup.isOpen
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    property var currentMonth: new Date()

    MouseArea {
        anchors.fill: parent
        onClicked: calendarPopup.close()
    }

    Rectangle {
        id: calendarPanel
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 10
        width: 320
        height: 340
        radius: root.barRadius
        color: theme.background
        opacity: calendarPopup.isOpen ? root.popupOpacity : 0
        border.color: theme.muted
        border.width: root.popupBorderThickness
        clip: true

        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => mouse.accepted = true
        }

        ColumnLayout {
            id: calendarOuter
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "◀"
                    font.pixelSize: 14
                    color: theme.color5
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var m = calendarWindow.currentMonth
                            calendarWindow.currentMonth = new Date(m.getFullYear(), m.getMonth() - 1, 1)
                        }
                    }
                }

                Text {
                    text: Qt.formatDateTime(calendarWindow.currentMonth, "MMMM yyyy")
                    font.pixelSize: 14
                    font.bold: true
                    color: theme.foreground
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: "▶"
                    font.pixelSize: 14
                    color: theme.color5
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var m = calendarWindow.currentMonth
                            calendarWindow.currentMonth = new Date(m.getFullYear(), m.getMonth() + 1, 1)
                        }
                    }
                }
            }

            // Today button
            Rectangle {
                Layout.fillWidth: true
                height: 28
                radius: 4
                color: todayHover.containsMouse ? Qt.darker(theme.color2, 1.2) : theme.color2

                Text {
                    anchors.centerIn: parent
                    text: "Today"
                    font.pixelSize: 11
                    font.bold: true
                    color: theme.background
                }

                MouseArea {
                    id: todayHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: calendarWindow.currentMonth = new Date()
                }
            }

            // Day names
            RowLayout {
                Layout.fillWidth: true

                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                    Text {
                        text: modelData
                        font.pixelSize: 11
                        color: theme.muted
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Days
            GridLayout {
                Layout.fillWidth: true
                columns: 7

                Repeater {
                    model: {
                        var m = calendarWindow.currentMonth
                        var firstDay = new Date(m.getFullYear(), m.getMonth(), 1)
                        var lastDay = new Date(m.getFullYear(), m.getMonth() + 1, 0)
                        var startDay = (firstDay.getDay() + 6) % 7
                        var totalDays = lastDay.getDate()
                        var today = new Date()

                        var days = []
                        for (var i = 0; i < startDay; i++) {
                            days.push({ day: 0, isCurrentMonth: false })
                        }
                        for (var d = 1; d <= totalDays; d++) {
                            var isToday = d === today.getDate() && m.getMonth() === today.getMonth() && m.getFullYear() === today.getFullYear()
                            days.push({ day: d, isCurrentMonth: true, isToday: isToday })
                        }
                        while (days.length % 7 !== 0) {
                            days.push({ day: 0, isCurrentMonth: false })
                        }
                        while (days.length < 42) {
                            days.push({ day: 0, isCurrentMonth: false })
                        }
                        return days
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 28
                        radius: 4
                        color: modelData.day === 0 ? "transparent" : (modelData.isToday ? theme.color2 : (dayHover.containsMouse ? Qt.darker(theme.background, 1.2) : "transparent"))

                        Text {
                            anchors.centerIn: parent
                            text: modelData.day === 0 ? "" : modelData.day.toString()
                            font.pixelSize: 11
                            color: modelData.day === 0 ? "transparent" : (modelData.isToday ? theme.background : (modelData.isCurrentMonth ? theme.foreground : theme.muted))
                        }

                        MouseArea {
                            id: dayHover
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: modelData.day !== 0
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
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

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: calendarPopup.close()
    }
}
