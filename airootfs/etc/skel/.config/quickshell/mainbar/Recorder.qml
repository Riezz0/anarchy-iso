import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: recorder

    property bool recording: false
    property bool hovered: false

    implicitWidth: 40
    implicitHeight: 40

    // ── Process to check if wf-recorder is running ─────────────────────────
    Process {
        id: checkProc
        command: ["pgrep", "-x", "wf-recorder"]
        running: false
        property bool found: false

        stdout: SplitParser {
            onRead: line => {
                if (line.trim().length > 0) {
                    checkProc.found = true
                }
            }
        }

        onRunningChanged: {
            if (!running) {
                recorder.recording = checkProc.found
                checkProc.found = false
            }
        }
    }

    // ── Process to run the recorder script (fully detached) ─────────────────
    // Must fully detach so slurp can display its overlay independently
    // of QuickShell's process group
    Process {
        id: recorderProc
        command: ["nohup", "setsid", "bash", "-c",
            Quickshell.env("HOME") + "/.config/quickshell/scripts/wf-recorder.sh </dev/null >/dev/null 2>&1"]
        running: false

        onRunningChanged: {
            if (!running) {
                checkProc.running = true
            }
        }
    }

    // ── Timer to poll recording state ───────────────────────────────────────
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!checkProc.running) {
                checkProc.running = true
            }
        }
    }

    // ── Main Button ─────────────────────────────────────────────────────────
    Rectangle {
        id: recBtn
        anchors.fill: parent
            radius:   barSettings.barRadius
        color: "transparent"
        border {
            width: 2
            color: recorder.recording ? theme.color1 : theme.color4
        }

        Behavior on border.color { ColorAnimation { duration: 120 } }

        // ── Icon: filled circle (idle) or square (recording) ─────────────────
        Rectangle {
            id: iconShape
            anchors.centerIn: parent
            width:  12
            height: 12
            radius: recorder.recording ? 1 : 6
            color:  recorder.recording ? theme.color1 : theme.color2
        }

        // ── Pulse animation when recording ───────────────────────────────────
        SequentialAnimation {
            id: pulseAnimation
            running: recorder.recording
            loops: Animation.Infinite

            NumberAnimation {
                target: recBtn
                property: "opacity"
                from: 1.0
                to: 0.5
                duration: 1000
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: recBtn
                property: "opacity"
                from: 0.5
                to: 1.0
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }

        // Reset opacity when not recording
        Binding {
            target: recBtn
            property: "opacity"
            value: 1.0
            when: !recorder.recording
        }
    }

    // ── Mouse Interaction ───────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: recorder.hovered = true
        onExited: recorder.hovered = false

        onClicked: {
            if (!recorderProc.running) {
                recorderProc.running = true
            }
        }
    }

    // ── Update border color based on hover + recording state ────────────────
    function updateBorderColor() {
        if (recorder.hovered) {
            recBtn.border.color = theme.muted
        } else {
            recBtn.border.color = recorder.recording ? theme.color1 : theme.color4
        }
    }

    Connections {
        target: recorder
        function onHoveredChanged() { updateBorderColor() }
        function onRecordingChanged() { updateBorderColor() }
    }
}
