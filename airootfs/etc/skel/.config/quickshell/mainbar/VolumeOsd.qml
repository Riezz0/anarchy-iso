import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    model: barSettings.popupScreens()

    PanelWindow {
        screen:  modelData
        visible: osd.showOsd
        required property var modelData

        anchors { top: true; bottom: true; left: true; right: true }

        color: "transparent"
        focusable: false

        WlrLayershell.layer: WlrLayer.Overlay

        id: osd

        property bool showOsd: false
        property bool initialized: false

        // ── Auto-hide timer ──────────────────────────────────────────────────
        Timer {
            id:      hideTimer
            interval: 1500
            onTriggered: osd.showOsd = false
        }

        // ── Skip initial volume read on reload ───────────────────────────────
        Component.onCompleted: {
            skipTimer.start()
        }

        Timer {
            id:      skipTimer
            interval: 500
            onTriggered: osd.initialized = true
        }

        // ── Volume change tracker ────────────────────────────────────────────
        Connections {
            target: audio
            function onVolumeLevelChanged() {
                if (!osd.initialized) return
                osd.showOsd = true
                hideTimer.restart()
            }
        }

        // ── OSD container ────────────────────────────────────────────────────
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom:           parent.bottom
            anchors.bottomMargin:     20
            width:    osdRow.implicitWidth + 40
            height:   44
            radius:   barSettings.barRadius
            color:    theme.background
            opacity:  osd.showOsd ? 0.95 : 0
            y:        osd.showOsd ? 0 : 20

            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on y       { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            border { width: barSettings.borderThickness; color: theme.color5 }

            Row {
                id:               osdRow
                anchors.centerIn: parent
                spacing:          10

                // Volume icon
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           audio.volumeIcon()
                    font.pixelSize: 14
                    color:          audio.volumeMuted ? theme.color1 : theme.color5
                }

                // Progress bar
                Rectangle {
                    width:  150
                    height: 8
                    radius: 4
                    color:  Qt.darker(theme.background, 1.3)
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width:  parent.width * Math.min(audio.volumeLevel, 1)
                        height: parent.height
                        radius: parent.radius
                    color:          audio.volumeMuted ? theme.color1 : theme.color5

                        Behavior on width { NumberAnimation { duration: 80 } }
                    }
                }

                // Percentage text
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:           Math.round(audio.volumeLevel * 100) + "%"
                    font.pixelSize: 14
                    font.bold:      true
                    font.family:    "JetBrains Mono Nerd Font Mono"
                    color:          theme.muted
                    width:          36
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
