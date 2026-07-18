import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    model: [Quickshell.screens[1]]

    PanelWindow {
        screen:  modelData
        visible: themesPopup.isOpen
        required property var modelData

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: themesPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: themesPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        MouseArea {
            anchors.fill: parent
            onClicked:    themesPopup.close()
        }

        Rectangle {
            anchors.bottom:     parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 10
            width:    520
            height:   popupColumn.implicitHeight + 32
            radius: 5
            color:    theme.background
            opacity:  0.95
            border { width: 2; color: theme.color6 }

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            ColumnLayout {
                id: popupColumn
                anchors.fill:    parent
                anchors.margins: 16
                spacing: 0

                // Header
                Text {
                    text:           "Themes"
                    font.pixelSize: 14
                    font.bold:      true
                    color:          theme.foreground
                    Layout.bottomMargin: 4
                }

                Text {
                    text:           themes.themeList.length + " themes found"
                    font.pixelSize: 14
                    color:          theme.muted
                    Layout.bottomMargin: 8
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    height: 1
                    color: theme.muted
                    opacity: 0.4
                }

                // Scrollable theme grid — 3 columns, 2 rows visible
                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    clip: true
                    contentHeight: gridContent.height
                    flickableDirection: Flickable.VerticalFlick

                    Grid {
                        id:       gridContent
                        width:    parent.width
                        columns:  3
                        columnSpacing: 8
                        rowSpacing:    8

                        Repeater {
                            model: themes.themeList

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                width:  (gridContent.width - 16) / 3
                                height: 140
                                radius: 5
                                color:  "transparent"
                                border { width: 2; color: theme.muted }

                                property bool hovered: false

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 4

                                    // Thumbnail
                                    Rectangle {
                                        width:   parent.width
                                        height:  parent.height - nameLabel.implicitHeight - 10
                                        radius:  3
                                        color:   Qt.darker(theme.background, 1.3)
                                        clip:    true

                                        Image {
                                            anchors.fill: parent
                                            source:       modelData.thumbnail
                                            fillMode:     Image.PreserveAspectCrop
                                            smooth:       true
                                            mipmap:       true

                                            Rectangle {
                                                anchors.fill: parent
                                                color: theme.muted
                                                visible: parent.status === Image.Error

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.displayName.charAt(0)
                                                    font.pixelSize: 24
                                                    font.bold: true
                                                    color: theme.background
                                                }
                                            }
                                        }
                                    }

                                    // Theme name
                                    Text {
                                        id:               nameLabel
                                        width:            parent.width
                                        text:             modelData.displayName
                                        font.pixelSize:   14
                                        font.bold:        true
                                        font.family:      "JetBrains Mono Nerd Font Mono"
                                        color:            theme.foreground
                                        horizontalAlignment: Text.AlignHCenter
                                        elide:            Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape:  Qt.PointingHandCursor
                                    onContainsMouseChanged: {
                                        parent.hovered = containsMouse
                                        parent.border.color = containsMouse ? theme.color6 : theme.muted
                                    }
                                    onClicked: {
                                        themes.applyTheme(modelData.script)
                                        themesPopup.close()
                                    }
                                }

                                Behavior on border.color { ColorAnimation { duration: 120 } }
                            }
                        }
                    }
                }

                // Trigger rescan when popup opens
                Connections {
                    target: themesPopup
                    function onIsOpenChanged() {
                        if (themesPopup.isOpen) themes.rescan()
                    }
                }
            }
        }
    }
}
