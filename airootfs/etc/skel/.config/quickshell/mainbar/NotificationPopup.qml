// ═══════════════════════════════════════════════════════════════════════════════
// NotificationPopup - Floating Notification Toast Overlay
// ═══════════════════════════════════════════════════════════════════════════════
// Displays floating notification toasts at the top center of the screen.
// Each notification auto-dismisses after a timeout based on urgency level.
// Matches swaync notification dimensions (400px wide, 48px icon, 14px font).
//
// Required: notifs (Notifications module) from shell.qml
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: popupRoot

    property var toastList: []
    property int count: toastList.length

    function dismissNotif(nid) {
        notifs.dismissNotif(nid)
        popupRoot.toastList = popupRoot.toastList.filter(n => n.id !== nid)
    }

    Connections {
        target: notifs

        function onNotificationReceived(appName, summary, body, urgency, timeout, actions) {
            if (notifs.dndEnabled) return

            const notifData = {
                id:       Date.now() + Math.random(),
                appName:  appName,
                summary:  summary,
                body:     body,
                urgency:  urgency,
                actions:  actions || [],
                expireTimeout: timeout > 0 ? timeout : (urgency === 1 ? 10000 : 5000)
            }

            let arr = popupRoot.toastList.slice()
            arr.push(notifData)
            popupRoot.toastList = arr
        }
    }

    Variants {
        model: barSettings.popupScreens()

        PanelWindow {
            screen:  modelData
            visible: popupRoot.count > 0
            required property var modelData

            anchors { top: true; left: true; right: true }

            color:     "transparent"
            focusable: false
            exclusiveZone: -1
            implicitWidth: 432

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            implicitHeight: toastColumn.implicitHeight + 96

            Column {
                id:               toastColumn
                anchors.top:      parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 80
                spacing:          16
                width:            400

                Repeater {
                    model: popupRoot.toastList

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width:    toastColumn.width
                        implicitHeight: toastCol.implicitHeight + 56
                        height:   implicitHeight
                        radius:   barSettings.barRadius
                        color:    theme.background
                        opacity:  0.95
                        border {
                            width: 2
                            color: modelData.urgency === 1 ? theme.color1
                                 : modelData.urgency === 0 ? Qt.darker(theme.color4, 0.7)
                                 : theme.color2
                        }

                        Timer {
                            interval: modelData.expireTimeout
                            running:  true
                            repeat:   false
                            onTriggered: popupRoot.dismissNotif(modelData.id)
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    popupRoot.dismissNotif(modelData.id)
                        }

                        Column {
                            id:    toastCol
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 4

                            Text {
                                width: parent.width
                                text:   modelData.appName || "Notification"
                                color:  theme.muted
                                font.pixelSize:   12
                                font.bold:        true
                                font.family:      "JetBrains Mono Nerd Font Mono"
                                horizontalAlignment: Text.AlignHCenter
                                elide:            Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text:   modelData.summary
                                color:  theme.foreground
                                font.pixelSize:   14
                                font.bold:        true
                                font.weight:      Font.ExtraBold
                                horizontalAlignment: Text.AlignHCenter
                                elide:            Text.ElideRight
                            }

                            Text {
                                visible: modelData.body && modelData.body.length > 0
                                width:   parent.width
                                text:    modelData.body || ""
                                color:   theme.muted
                                font.pixelSize:   13
                                wrapMode:         Text.Wrap
                                maximumLineCount: 3
                                elide:            Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
