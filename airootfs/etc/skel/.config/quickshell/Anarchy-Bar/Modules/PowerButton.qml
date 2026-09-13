import QtQuick

Rectangle {
    id: powerBtn

    property bool isOpen: false
    property var screen: null

    width: 42
    height: 42
    radius: root.barRadius
    color: isOpen ? theme.color1 : "transparent"

    Text {
        anchors.centerIn: parent
        text: "󰐥"
        color: powerBtn.isOpen ? theme.background : theme.color1
        font.pixelSize: 25
        font.family: "JetBrainsMono Nerd Font"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: powerBtn.opacity = 0.7
        onExited: powerBtn.opacity = 1.0
        onClicked: powerMenu.isOpen ? powerMenu.close() : powerMenu.open(powerBtn.screen)
    }

    Behavior on opacity { NumberAnimation { duration: 150 } }
}
