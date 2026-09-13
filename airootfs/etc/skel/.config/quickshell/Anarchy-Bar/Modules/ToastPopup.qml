import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: toastWindow

    visible: toastList.length > 0
    screen: powerMenu.targetScreen

    property var toastList: []
    property int maxToasts: 3

    anchors { top: true; left: true; right: true }

    implicitHeight: toastColumn.implicitHeight + 40
    exclusiveZone: 0
    color: "transparent"
    focusable: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Connections {
        target: notifs
        function onNotificationReceived(appName, summary, body, urgency, timeout, actions) {
            var toast = {
                id: Date.now() + Math.random(),
                appName: appName,
                summary: summary,
                body: body
            }
            var list = toastList.slice()
            list.push(toast)
            if (list.length > maxToasts) list.shift()
            toastList = list
            dismissTimerComponent.createObject(toastWindow, { toastId: toast.id })
        }
    }

    Component {
        id: dismissTimerComponent
        Timer {
            property real toastId: 0
            interval: 4000
            running: true
            repeat: false
            onTriggered: {
                var list = toastWindow.toastList.slice()
                list = list.filter(function(t) { return t.id !== toastId })
                toastWindow.toastList = list
                destroy()
            }
        }
    }

    Column {
        id: toastColumn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        spacing: 8

        Repeater {
            model: toastWindow.toastList

            Rectangle {
                required property var modelData
                required property int index

                width: 320
                height: toastContent.implicitHeight + 20
                radius: root.barRadius
                color: theme.background
                opacity: 0.95
                border.color: theme.color4
                border.width: root.popupBorderThickness
                clip: true

                ColumnLayout {
                    id: toastContent
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: notifs.notifIcon()
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                            color: theme.color4
                        }

                        Text {
                            text: modelData.appName || "Notification"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                            color: theme.muted
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        text: modelData.summary || ""
                        font.pixelSize: 13
                        font.bold: true
                        color: theme.foreground
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        visible: modelData.body && modelData.body.length > 0
                        text: modelData.body || ""
                        font.pixelSize: 11
                        color: theme.muted
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
