import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: volumeRoot

    property int volume: 0
    property bool muted: false
    property bool loaded: false

    width: 42
    height: 42

    Rectangle {
        anchors.fill: parent
        radius: root.barRadius
        border.color: theme.muted
        border.width: root.moduleBorderThickness
        color: volHover.containsMouse ? theme.color3 : "transparent"
    }

    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: muted ? "\u{F466}" : (volume === 0 ? "\u{F466}" : (volume >= 66 ? "\u{F028}" : (volume >= 33 ? "\u{F027}" : "\u{F026}")))
            font.pixelSize: 20
            font.family: "JetBrainsMono Nerd Font"
            color: volHover.containsMouse ? theme.background : theme.muted
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: muted ? "Muted" : volume + "%"
            font.pixelSize: 10
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
            color: volHover.containsMouse ? theme.background : theme.muted
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        id: volHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) adjustVolume(5)
            else if (wheel.angleDelta.y < 0) adjustVolume(-5)
        }
        onClicked: pulseCmd.running = true
    }

    function adjustVolume(delta) {
        var newVol = Math.max(0, Math.min(150, volume + delta))
        wpSetProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", newVol / 100]
        wpSetProc.running = true
        volume = newVol
        volumeOSD.show(volume, muted)
        refreshTimer.restart()
    }

    Timer { id: refreshTimer; interval: 200; onTriggered: refreshVolume() }

    Process {
        id: wpSetProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: pulseCmd
        running: false
        command: ["kitty", "--class=pulsepad", "-e", "pulsemixer"]
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: volGetProc
        running: false
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2 * 100)}'"]
        stdout: SplitParser {
            onRead: line => {
                var v = parseInt(line.trim())
                if (!isNaN(v) && v !== volumeRoot.volume) {
                    volumeRoot.volume = v
                    if (volumeRoot.loaded) volumeOSD.show(v, muted)
                }
            }
        }
    }

    Process {
        id: muteGetProc
        running: false
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED && echo 1 || echo 0"]
        stdout: SplitParser {
            onRead: line => {
                var newMuted = line.trim() === "1"
                if (newMuted !== volumeRoot.muted) {
                    volumeRoot.muted = newMuted
                    if (volumeRoot.loaded) volumeOSD.show(volume, newMuted)
                }
            }
        }
    }

    function refreshVolume() {
        volGetProc.running = true
        muteGetProc.running = true
    }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: refreshVolume() }
    Component.onCompleted: { refreshVolume(); volumeLoadTimer.start() }
    Timer { id: volumeLoadTimer; interval: 500; running: false; onTriggered: volumeRoot.loaded = true }
}
