import QtQuick

Rectangle {
    id: settingsBtn

    property bool isOpen: false
    property var screen: null

    width: 34
    height: 34
    radius: root.barRadius
    border.color: theme.muted
    border.width: root.moduleBorderThickness
    color: isOpen ? theme.color5 : "transparent"

    Text {
        anchors.centerIn: parent
        anchors.margins: 8
        text: "󰒓"
        color: settingsBtn.isOpen ? theme.background : theme.color5
        font.pixelSize: 18
        font.family: "JetBrainsMono Nerd Font"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: settingsBtn.opacity = 0.7
        onExited: settingsBtn.opacity = 1.0
        onClicked: settingsPopup.isOpen ? settingsPopup.close() : settingsPopup.open(settingsBtn.screen)
    }

    Behavior on opacity { NumberAnimation { duration: 150 } }
}
