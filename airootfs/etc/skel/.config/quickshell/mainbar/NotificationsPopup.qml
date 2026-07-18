// ═══════════════════════════════════════════════════════════════════════════════
// NotificationsPopup - Notification Center Panel
// ═══════════════════════════════════════════════════════════════════════════════
// A slide-down notification center showing all active notifications.
// Provides DND toggle, clear all, and per-notification dismiss.
// Replaces swaync's control center panel.
//
// Required: notifs (Notifications module) from shell.qml
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    model: [Quickshell.screens[1]]

    PanelWindow {
        screen:  modelData
        visible: notificationsPopup.isOpen
        required property var modelData

        property real maxPanelHeight: Screen.height * 0.6

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: notificationsPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: notificationsPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked:    notificationsPopup.close()
        }

        Rectangle {
            id:           notifPanel
            anchors.top:        parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin:  10
            width:    440
            implicitHeight: headerColumn.implicitHeight + Math.min(notifListContent.implicitHeight, maxPanelHeight - headerColumn.implicitHeight - 48) + 48
            height:   implicitHeight
            radius:   5
            color:    theme.background
            opacity:  0.95
            border { width: 2; color: theme.color4 }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id:           headerColumn
                anchors.top:  parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
                spacing: 0

                // ── Header ─────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 16
                    spacing: 12

                    Text {
                        text:           notifs.notifIcon()
                        font.pixelSize: 24
                        color:          notifs.notifColor()
                    }

                    Text {
                        text:      "Notifications"
                        color:     theme.foreground
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        text:           notifs.trackedCount.toString()
                        color:          theme.muted
                        font.pixelSize: 14
                        font.bold:      true
                        font.family:    "JetBrains Mono Nerd Font Mono"
                    }
                }

                // ── DND Toggle ──────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 16
                    implicitHeight: 36
                    radius: 5
                    color:  notifs.dndEnabled ? theme.color1 : "transparent"
                    border { width: 2; color: theme.color4 }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           notifs.dndEnabled ? "󰂛" : "󰂞"
                            font.pixelSize: 16
                            color:          notifs.dndEnabled ? theme.background : theme.color4
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:      notifs.dndEnabled ? "Do Not Disturb: ON" : "Do Not Disturb: OFF"
                            color:     notifs.dndEnabled ? theme.background : theme.color2
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    notifs.dndEnabled = !notifs.dndEnabled
                    }
                }

                // ── Clear All Button ────────────────────────────────────────
                Rectangle {
                    visible: notifs.trackedCount > 0
                    Layout.fillWidth: true
                    Layout.bottomMargin: 16
                    implicitHeight: 32
                    radius: 5
                    color:  "transparent"
                    border { width: 2; color: theme.color1 }

                    Text {
                        anchors.centerIn: parent
                        text:  "Clear All (" + notifs.trackedCount + ")"
                        color: theme.color1
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    notifs.clearAll()
                    }
                }
            }

            // ── Scrollable Notification List ────────────────────────────────
            Flickable {
                id:               notifListArea
                anchors.top:      headerColumn.bottom
                anchors.left:     parent.left
                anchors.right:    parent.right
                anchors.bottom:   parent.bottom
                anchors.margins:  16
                anchors.topMargin: 0
                contentHeight:    notifListContent.height
                clip:             true
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior:   Flickable.StopAtBounds

                Column {
                    id:    notifListContent
                    width: parent.width
                    spacing: 8

                    // ── Empty state ──────────────────────────────────────────
                    Text {
                        visible: notifs.trackedCount === 0
                        text:      "No notifications"
                        color:     theme.muted
                        font.pixelSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 24
                    }

                    Repeater {
                        model: notifs.trackedCount > 0 ? notifs.activeNotifications : []

                        Rectangle {
                            required property var modelData
                            required property int index

                            width:    notifListContent.width
                            implicitHeight: notifItemContent.implicitHeight + 24
                            height:   implicitHeight
                            radius: 5
                            color:  Qt.darker(theme.background, 1.15)
                            border {
                                width: 2
                                color: modelData.urgency === 1 ? theme.color1
                                     : modelData.urgency === 0 ? theme.color4
                                     : theme.color2
                            }

                            Column {
                                id:    notifItemContent
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 4

                                RowLayout {
                                    width: parent.width
                                    spacing: 8

                                    // Bell icon
                                    Rectangle {
                                        width:  32
                                        height: 32
                                        radius: 5
                                        color:  Qt.darker(theme.background, 1.2)
                                        border { width: 1; color: theme.muted }

                                        Text {
                                            anchors.centerIn: parent
                                            text:           "󰂞"
                                            font.pixelSize: 16
                                            color:          theme.color4
                                        }
                                    }

                                    // App name + summary
                                    Column {
                                        width: parent.width - 32 - 8 - 24 - 8
                                        spacing: 2

                                        Text {
                                            text:             modelData.appName || "Notification"
                                            color:            theme.muted
                                            font.pixelSize:   12
                                            font.bold:        true
                                            font.family:      "JetBrains Mono Nerd Font Mono"
                                            elide:            Text.ElideRight
                                            width:            parent.width
                                        }

                                        Text {
                                            text:             modelData.summary || ""
                                            color:            theme.foreground
                                            font.pixelSize:   14
                                            font.bold:        true
                                            elide:            Text.ElideRight
                                            width:            parent.width
                                        }
                                    }

                                    // Dismiss button
                                    Rectangle {
                                        width:  24
                                        height: 24
                                        radius: 5
                                        color:  "transparent"
                                        border { width: 1; color: theme.muted }

                                        Text {
                                            anchors.centerIn: parent
                                            text:           "×"
                                            font.pixelSize: 16
                                            color:          theme.muted
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape:  Qt.PointingHandCursor
                                            onClicked:    notifs.dismissNotif(modelData.id)
                                        }
                                    }
                                }

                                // Body
                                Text {
                                    visible:          modelData.body && modelData.body.length > 0
                                    text:             modelData.body || ""
                                    color:            theme.muted
                                    font.pixelSize:   13
                                    wrapMode:         Text.Wrap
                                    maximumLineCount: 3
                                    elide:            Text.ElideRight
                                    width:            parent.width
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
