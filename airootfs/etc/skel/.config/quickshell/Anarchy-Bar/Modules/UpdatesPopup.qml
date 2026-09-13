import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: updatesWindow

    visible: updatesPopup.isOpen
    screen: powerMenu.targetScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    focusable: updatesPopup.isOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: updatesPopup.isOpen
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onClicked: updatesPopup.close()
        opacity: updatesPopup.isOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Rectangle {
        id: updatesPanel
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        width: 420
        implicitHeight: Math.min(updatesColumn.implicitHeight + 32, 500)
        height: implicitHeight
        radius: root.barRadius
        color: theme.background
        opacity: updatesPopup.isOpen ? 0.95 : 0
        scale: updatesPopup.isOpen ? 1.0 : 0.95
        y: updatesPopup.isOpen ? 0 : -20
        border { width: root.popupBorderThickness; color: updates.updatesAvailable ? theme.color3 : theme.color2 }

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => mouse.accepted = true
        }

        ColumnLayout {
            id: updatesColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 16
                spacing: 12

                Text {
                    text: updates.updateIcon()
                    font.pixelSize: 24
                    font.family: "JetBrainsMono Nerd Font"
                    color: updates.updateColor()
                }

                Text {
                    text: "Updates"
                    color: theme.foreground
                    font.pixelSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    text: String(updates.updateCount)
                    color: updates.updatesAvailable ? theme.color3 : theme.muted
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // Refresh Button
            Rectangle {
                Layout.fillWidth: true
                Layout.bottomMargin: 12
                implicitHeight: 32
                radius: root.barRadius
                color: "transparent"
                border { width: root.popupBorderThickness; color: updates.checking ? theme.muted : theme.color4 }

                Text {
                    anchors.centerIn: parent
                    text: updates.checking ? "Checking..." : "Refresh"
                    color: updates.checking ? theme.muted : theme.color2
                    font.pixelSize: 13
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: !updates.checking
                    onClicked: updates.refresh()
                }
            }

            // Update list
            ScrollView {
                Layout.fillWidth: true
                Layout.bottomMargin: 12
                Layout.preferredHeight: Math.min(updatesList.contentHeight, 320)
                clip: true

                ListView {
                    id: updatesList
                    model: updates.updateList
                    spacing: 4
                    implicitHeight: contentHeight
                    interactive: contentHeight > height

                    delegate: Rectangle {
                        required property var modelData
                        width: updatesList.width
                        implicitHeight: entryRow.implicitHeight + 12
                        radius: 4
                        color: Qt.darker(theme.background, 1.2)
                        border { width: root.popupBorderThickness; color: theme.color4 }

                        RowLayout {
                            id: entryRow
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            Text {
                                text: modelData
                                color: theme.foreground
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Text {
                        visible: updates.updateList.length === 0 && !updates.checking
                        anchors.centerIn: parent
                        text: "No updates available"
                        color: theme.muted
                        font.pixelSize: 13
                    }
                }
            }

            // Launch Update Button
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 40
                radius: root.barRadius
                color: updates.updatesAvailable ? Qt.rgba(theme.color3.r, theme.color3.g, theme.color3.b, 0.15) : "transparent"
                border { width: root.popupBorderThickness; color: updates.updatesAvailable ? theme.color3 : theme.muted }

                Text {
                    anchors.centerIn: parent
                    text: updates.updatesAvailable ? "Launch Update" : "Update"
                    color: updates.updatesAvailable ? theme.color3 : theme.muted
                    font.pixelSize: 14
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        updates.launchUpdate()
                        updatesPopup.close()
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        focus: updatesPopup.isOpen
        Keys.onEscapePressed: updatesPopup.close()
    }
}
