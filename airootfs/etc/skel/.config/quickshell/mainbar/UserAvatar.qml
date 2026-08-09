import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: userAvatar
    radius: barSettings.barRadius
    color: "transparent"
    border { width: barSettings.borderThickness; color: hovered ? theme.muted : theme.color2 }

    implicitHeight: 40
    implicitWidth: avatarRow.implicitWidth + 16

    property bool hovered: false
    readonly property string avatarPath: "/usr/share/sddm/themes/anarchy-sddm/assets/avatar.jpg"
    readonly property string userName: Quickshell.env("USER") || "user"

    Row {
        id: avatarRow
        anchors.centerIn: parent
        spacing: 8

        Rectangle {
            width: 28
            height: 28
            radius: 14
            anchors.verticalCenter: parent.verticalCenter
            color: theme.muted
            clip: true

            Image {
                anchors.fill: parent
                source: "file://" + userAvatar.avatarPath
                smooth: true
                mipmap: true
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 64
                sourceSize.height: 64

                layer.enabled: true
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: userAvatar.userName
            font.pixelSize: 13
            font.bold: true
            font.family: "JetBrains Mono Nerd Font Mono"
            color: userAvatar.hovered ? theme.foreground : theme.muted
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: userAvatar.hovered = true
        onExited: userAvatar.hovered = false
    }
}
