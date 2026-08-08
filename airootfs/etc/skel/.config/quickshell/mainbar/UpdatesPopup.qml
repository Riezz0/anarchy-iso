// ═══════════════════════════════════════════════════════════════════════════════
// UpdatesPopup - Available Updates Overlay
// ═══════════════════════════════════════════════════════════════════════════════
// Displays the list of pending updates (from `arch-update --list`) and provides
// a button that launches the interactive `arch-update` update feature.
//
// Required properties (passed from shell.qml):
//   visible   - Whether the popup is shown
//   onClose   - Signal to close the popup
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Variants {
    model: barSettings.popupScreens()

    PanelWindow {
        screen:  modelData
        visible: panelVisible
        required property var modelData

        property bool panelVisible: false

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: archUpdatePopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: archUpdatePopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        Connections {
            target: archUpdatePopup
            function onIsOpenChanged() {
                if (archUpdatePopup.isOpen) { panelVisible = true }
                else { hideTimer.start() }
            }
        }

        Timer { id: hideTimer; interval: 220; onTriggered: panelVisible = false }

        MouseArea {
            anchors.fill: parent
            onClicked:    archUpdatePopup.close()
            opacity: archUpdatePopup.isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Rectangle {
            id: updatesPanel
            anchors.top:           parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin:     10
            width:    420
            implicitHeight: updatesColumn.implicitHeight + 32
            height:   Math.min(implicitHeight, Screen.height - 40)
            radius:   barSettings.barRadius
            color:    theme.background
            opacity:  archUpdatePopup.isOpen ? 0.95 : 0
            scale:    archUpdatePopup.isOpen ? 1.0 : 0.95
            y:        archUpdatePopup.isOpen ? 0 : -20
            border { width: barSettings.borderThickness; color: updates.updatesAvailable ? theme.color3 : theme.color2 }

            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on y       { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id: updatesColumn
                anchors.fill:    parent
                anchors.margins: 16
                spacing: 0

                // ── Header ───────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth:  true
                    Layout.bottomMargin: 16
                    spacing: 12

                    Text {
                        text:           updates.updateIcon()
                        font.pixelSize: 24
                        font.family:    "JetBrains Mono Nerd Font Mono"
                        color:          updates.updateColor()
                    }

                    Text {
                        text:      "Updates"
                        color:     theme.foreground
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        text:           String(updates.updateCount)
                        color:          updates.updatesAvailable ? theme.color3 : theme.muted
                        font.pixelSize: 14
                        font.bold:      true
                        font.family:    "JetBrains Mono Nerd Font Mono"
                    }
                }

                // ── Refresh Button ───────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 12
                    implicitHeight: 32
                    radius:   barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: updates.checking ? theme.muted : theme.color4 }

                    Text {
                        anchors.centerIn: parent
                        text:      updates.checking ? "Checking..." : "Refresh"
                        color:     updates.checking ? theme.muted : theme.color2
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        enabled:     !updates.checking
                        onClicked:    updates.refresh()
                    }
                }

                // ── Update list ───────────────────────────────────────────────
                ScrollView {
                    Layout.fillWidth:  true
                    Layout.bottomMargin: 12
                    Layout.preferredHeight: Math.min(
                        updatesList.contentHeight,
                        Screen.height - 320
                    )
                    clip: true

                    ListView {
                        id: updatesList
                        model: updates.updateList
                        spacing: 4
                        implicitHeight: contentHeight
                        interactive: contentHeight > height

                        delegate: Rectangle {
                            required property var modelData
                            width:    updatesList.width
                            implicitHeight: entryRow.implicitHeight + 12
                            radius: 4
                            color:  Qt.darker(theme.background, 1.2)
                            border { width: barSettings.borderThickness; color: theme.color4 }

                            RowLayout {
                                id:               entryRow
                                anchors.fill:     parent
                                anchors.margins:  8
                                spacing: 8

                                Text {
                                    text:             modelData
                                    color:            theme.foreground
                                    font.pixelSize:   12
                                    font.family:      "JetBrains Mono Nerd Font Mono"
                                    Layout.fillWidth: true
                                    elide:            Text.ElideRight
                                }
                            }
                        }

                        Text {
                            visible: updates.updateList.length === 0 && !updates.checking
                            anchors.centerIn: parent
                            text:      "No updates available"
                            color:     theme.muted
                            font.pixelSize: 13
                        }
                    }
                }

                // ── Launch Update Button ──────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 40
                    radius:   barSettings.barRadius
                    color:  updates.updatesAvailable ? Qt.rgba(theme.color3.r, theme.color3.g, theme.color3.b, 0.15) : "transparent"
                    border { width: barSettings.borderThickness; color: updates.updatesAvailable ? theme.color3 : theme.muted }

                    Text {
                        anchors.centerIn: parent
                        text:      updates.updatesAvailable ? "Launch Update" : "Update"
                        color:     updates.updatesAvailable ? theme.color3 : theme.muted
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            updates.launchUpdate()
                            archUpdatePopup.close()
                        }
                    }
                }
            }
        }
    }
}
