import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: salaatPopupWindow

    visible: salaatPopup.isOpen
    screen: powerMenu.targetScreen

    anchors { top: true; bottom: true; left: true; right: true }

    Process {
        id: cmdProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    color: "transparent"
    focusable: salaatPopup.isOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: salaatPopup.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onClicked: salaatPopup.close()
        opacity: salaatPopup.isOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Rectangle {
        id: salaatPanel
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        width: 320
        implicitHeight: popupColumn.implicitHeight + 32
        height: implicitHeight
        radius: root.barRadius
        color: theme.background
        opacity: salaatPopup.isOpen ? root.popupOpacity : 0
        clip: true
        border.color: theme.color3
        border.width: root.popupBorderThickness
        layer.enabled: true
        layer.effect: OpacityMask { maskSource: Rectangle { width: salaatPanel.width; height: salaatPanel.height; radius: root.barRadius; color: "white" } }

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; onClicked: mouse => mouse.accepted = true }

        ColumnLayout {
            id: popupColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0

            RowLayout {
                Layout.fillWidth: true; spacing: 10; Layout.bottomMargin: 4

                Text { text: "\u{EEDA}"; font.pixelSize: 22; font.family: "JetBrainsMono Nerd Font"; color: theme.color3 }

                Text { text: "Prayer Times"; font.pixelSize: 16; font.bold: true; color: theme.foreground; Layout.fillWidth: true }
            }

            Text { text: salaat.locationName || ""; font.pixelSize: 14; color: theme.muted; Layout.bottomMargin: 8 }

            Rectangle { Layout.fillWidth: true; Layout.bottomMargin: 8; height: 1; color: theme.muted; opacity: 0.4 }

            Repeater {
                model: [
                    { name: "Fajr", time: salaat.fajr },
                    { name: "Sunrise", time: salaat.sunrise },
                    { name: "Dhuhr", time: salaat.dhuhr },
                    { name: "Asr", time: salaat.asr },
                    { name: "Maghrib", time: salaat.maghrib },
                    { name: "Isha", time: salaat.isha }
                ]

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 32; Layout.bottomMargin: 4
                    radius: root.barRadius
                    color: modelData.name === salaat.nextPrayer ? Qt.darker(theme.color3, 1.5) : "transparent"

                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10

                        Text { text: modelData.name; font.pixelSize: 14; font.bold: true; font.family: "JetBrainsMono Nerd Font"; color: modelData.name === salaat.nextPrayer ? theme.muted : theme.foreground; Layout.fillWidth: true }
                        Text { text: modelData.time; font.pixelSize: 14; font.bold: true; font.family: "JetBrainsMono Nerd Font"; color: modelData.name === salaat.nextPrayer ? theme.muted : theme.muted }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.topMargin: 4; Layout.bottomMargin: 4; height: 1; color: theme.muted; opacity: 0.4 }

            RowLayout {
                Layout.fillWidth: true; spacing: 8

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 36; radius: root.barRadius
                    color: quranBtnHover.containsMouse ? Qt.darker(theme.color4, 1.3) : "transparent"
                    border { width: root.popupBorderThickness; color: theme.color4 }

                    Text { anchors.centerIn: parent; text: "Quran"; font.pixelSize: 14; font.bold: true; font.family: "JetBrainsMono Nerd Font"; color: theme.color4 }

                    MouseArea {
                        id: quranBtnHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { salaatPopup.close(); cmdProc.command = ["chromium", "--app=https://www.quranwbw.com", "--class=quran"]; cmdProc.running = true }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 36; radius: root.barRadius
                    color: sunnahBtnHover.containsMouse ? Qt.darker(theme.color5, 1.3) : "transparent"
                    border { width: root.popupBorderThickness; color: theme.color5 }

                    Text { anchors.centerIn: parent; text: "Sunnah"; font.pixelSize: 14; font.bold: true; font.family: "JetBrainsMono Nerd Font"; color: theme.color5 }

                    MouseArea {
                        id: sunnahBtnHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { salaatPopup.close(); cmdProc.command = ["chromium", "--app=https://www.sunnah.com", "--class=sunnah"]; cmdProc.running = true }
                    }
                }
            }
        }

        Rectangle { anchors.fill: parent; radius: root.barRadius; color: "transparent"; border.color: theme.color3; border.width: root.popupBorderThickness; z: 10 }
    }

    Item { anchors.fill: parent; focus: salaatPopup.isOpen; Keys.onEscapePressed: salaatPopup.close() }
}
