import QtQuick
import Quickshell

Rectangle {
    id: clockContainer

    width: 50
    // Match the workspace module's vertical breathing room.
    height: 42
    radius: root.barRadius
    border.color: theme.muted
    border.width: root.moduleBorderThickness
    color: clockHover.containsMouse ? theme.color1 : "transparent"

    property string currentTime: Qt.formatDateTime(new Date(), "hh:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockContainer.currentTime = Qt.formatDateTime(new Date(), "hh:mm")
    }

    Text {
        anchors.centerIn: parent
        width: parent.width
        text: clockContainer.currentTime
        color: clockHover.containsMouse ? theme.background : theme.muted
        font.pixelSize: 13
        font.family: "JetBrainsMono Nerd Font"
        horizontalAlignment: Text.AlignHCenter
    }

    MouseArea {
        id: clockHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: calendarPopup.isOpen ? calendarPopup.close() : calendarPopup.open()
    }
}
