import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: logoContainer

    width: 40
    height: 40
    radius: root.barRadius
    color: logoHover.containsMouse ? theme.color2 : "transparent"

    Text {
        anchors.centerIn: parent
        text: "\u{F08C7}"
        font.pixelSize: 30
        font.family: "JetBrainsMono Nerd Font"
        color: logoHover.containsMouse ? theme.background : theme.color2
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Process {
        id: keybindsDetectProc
        running: false
        stdout: StdioCollector {
            id: detectStdio
            onStreamFinished: {
                var name = detectStdio.text.trim()
                if (name.length > 0) {
                    keybindsPopup.targetScreen = name
                } else {
                    keybindsPopup.targetScreen = Quickshell.screens[0].name
                }
                keybindsPopup.open()
            }
        }
    }

    function detectCursorScreen() {
        keybindsDetectProc.command = ["sh", "-c", "bash ~/.config/quickshell/Anarchy-Bar/Scripts/detect-cursor-monitor.sh"]
        keybindsDetectProc.running = true
    }

    MouseArea {
        id: logoHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                if (keybindsPopup.isOpen) {
                    keybindsPopup.close()
                } else {
                    detectCursorScreen()
                }
            } else {
                settingsPopup.isOpen ? settingsPopup.close() : settingsPopup.open()
            }
        }
    }
}
