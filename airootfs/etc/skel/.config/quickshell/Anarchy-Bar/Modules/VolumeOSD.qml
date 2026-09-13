import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: volOsd

    visible: panelVisible
    screen: powerMenu.targetScreen

    property bool panelVisible: false
    property int osdVolume: 0
    property bool osdMuted: false

    implicitWidth: 60
    implicitHeight: 240
    anchors.right: true

    color: "transparent"
    focusable: false
    exclusiveZone: -1

    WlrLayershell.layer: WlrLayer.Overlay

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: {}
        onWheel: {}
    }

    Timer {
        id: osdHideTimer
        interval: 3000
        onTriggered: panelVisible = false
    }

    Rectangle {
        anchors.centerIn: parent
        width: 50; height: 200
        radius: root.barRadius
        color: Qt.darker(theme.background, 1.2)
        opacity: root.popupOpacity
        border.color: osdMuted ? theme.color1 : theme.color3
        border.width: root.popupBorderThickness

        Column {
            anchors.centerIn: parent
            spacing: 4

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: osdMuted ? "\u{F466}" : (osdVolume >= 66 ? "\u{F028}" : (osdVolume >= 33 ? "\u{F027}" : "\u{F026}"))
                    font.pixelSize: 20; font.family: "JetBrainsMono Nerd Font"
                    color: osdMuted ? theme.color1 : theme.color3
                }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 20; height: 120
                radius: 3
                color: Qt.darker(theme.muted, 1.3)

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * Math.min(osdVolume / 100, 1)
                    radius: 3
                    color: osdMuted ? theme.color1 : theme.color3
                    Behavior on height { NumberAnimation { duration: 100 } }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: osdMuted ? "Muted" : osdVolume + "%"
                    font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                    font.bold: true; color: osdMuted ? theme.color1 : theme.foreground
                }
            }
        }
    }

    function show(vol, muted) {
        osdVolume = vol
        osdMuted = muted
        panelVisible = true
        osdHideTimer.restart()
    }
}
