// ═══════════════════════════════════════════════════════════════════════════════
// SidePanel - Right-side slide-in widget
// ═══════════════════════════════════════════════════════════════════════════════
// Combines time/date, weather, salaat, keyboard, bluetooth, and screen recorder
// into a single right-side panel that slides in/out with animation.
//
// Required properties (passed from shell.qml):
//   sidePanel.isOpen - Whether the widget is shown
//   sidePanel.close  - Function to close the widget
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Variants {
    model: barSettings.popupScreens()

    PanelWindow {
        id: sidePanelWindow
        screen:  modelData
        visible: panelVisible
        required property var modelData

        property bool panelVisible: false
        readonly property int panelMargin: 10
        readonly property int panelBottomMargin: 60
        readonly property int panelWidth: 340
        readonly property int slideDuration: 300
        property int themeTick: 0

        Timer {
            interval: 1000
            running: sidePanel.isOpen
            repeat: true
            onTriggered: sidePanelWindow.themeTick++
        }

        anchors { top: true; bottom: true; left: true; right: true }

        color:     "transparent"
        focusable: sidePanel.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: sidePanel.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        Connections {
            target: sidePanel
            function onIsOpenChanged() {
                if (sidePanel.isOpen) {
                    panelVisible = true
                    networkPanel.x = modelData.width + 20
                    networkPanel.opacity = 0
                    Qt.callLater(animateIn)
                } else {
                    animateOut()
                    hideTimer.start()
                }
            }

            function animateIn() {
                slideInAnim.from = modelData.width + 20
                slideInAnim.to   = modelData.width - networkPanel.width - sidePanelWindow.panelMargin
                slideInAnim.start()
                fadeInAnim.start()
            }

            function animateOut() {
                fadeOutAnim.start()
                slideOutAnim.from = modelData.width - networkPanel.width - sidePanelWindow.panelMargin
                slideOutAnim.to   = modelData.width + 20
                slideOutAnim.start()
            }
        }

        Timer {
            id: hideTimer
            interval: sidePanelWindow.slideDuration + 50
            onTriggered: panelVisible = false
        }

        MouseArea {
            anchors.fill: parent
            onClicked:    sidePanel.close()
            opacity:      sidePanel.isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        Rectangle {
            id: networkPanel
            width:  sidePanelWindow.panelWidth
            height: Math.min(contentCol.implicitHeight + 32, parent.height - sidePanelWindow.panelMargin - sidePanelWindow.panelBottomMargin)
            y:      sidePanelWindow.panelMargin

            x:       modelData.width + 20
            opacity: 0

            radius: barSettings.barRadius
            color:  theme.background
            border { width: barSettings.borderThickness; color: theme.color4 }

            NumberAnimation {
                id: slideInAnim
                target:   networkPanel
                property: "x"
                duration: 300
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                id: slideOutAnim
                target:   networkPanel
                property: "x"
                duration: 300
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                id: fadeInAnim
                target:   networkPanel
                property: "opacity"
                from:     0
                to:       0.95
                duration: 200
            }

            NumberAnimation {
                id: fadeOutAnim
                target:   networkPanel
                property: "opacity"
                from:     0.95
                to:       0
                duration: 200
            }

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => mouse.accepted = true
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 16
                contentHeight: contentCol.implicitHeight
                clip:           true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: contentCol
                    width: parent.width
                    spacing: 16

                    // SECTION 1: Time & Date
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text:             Qt.formatDateTime(new Date(), "hh : mm : ss")
                            color:            sidePanelWindow.themeTick >= 0 ? theme.foreground : theme.foreground
                            font.pixelSize:   28
                            font.bold:        true
                            font.family:      "JetBrains Mono Nerd Font Mono"

                            Timer {
                                interval: 1000
                                running:  true
                                repeat:   true
                                onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh : mm : ss")
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text:             Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
                            color:            sidePanelWindow.themeTick >= 0 ? theme.muted : theme.muted
                            font.pixelSize:   12
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color:  theme.muted
                        opacity: 0.3
                    }

                    // SECTION 2: Weather
                    Rectangle {
                        id: weatherMonitor
                        Layout.fillWidth: true
                        implicitHeight: weatherCol.implicitHeight + 16
                        radius:   barSettings.barRadius
                        color:    Qt.darker(theme.background, 1.2)
                        border { width: barSettings.borderThickness; color: Qt.darker(theme.muted, 1.5) }

                        property string selectedTab: "Now"

                        ColumnLayout {
                            id: weatherCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:           weather.weatherIconText()
                                    font.pixelSize: 36
                                    font.family:    "JetBrains Mono Nerd Font Mono"
                                    color:          sidePanelWindow.themeTick >= 0 ? theme.color4 : theme.color4
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0

                                    Text {
                                        Layout.fillWidth: true
                                        text:      weather.shortCondition()
                                        color:     sidePanelWindow.themeTick >= 0 ? theme.foreground : theme.foreground
                                        font.pixelSize: 13
                                        font.bold: true
                                        elide:     Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text:      weather.locationDisplay()
                                        color:     sidePanelWindow.themeTick >= 0 ? theme.muted : theme.muted
                                        font.pixelSize: 10
                                        elide:     Text.ElideRight
                                    }
                                }

                                Text {
                                    text:           weather.loaded ? weather.tempDisplay() : "--"
                                    color:          sidePanelWindow.themeTick >= 0 ? theme.color4 : theme.color4
                                    font.pixelSize: 22
                                    font.bold:      true
                                    font.family:    "JetBrains Mono Nerd Font Mono"
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Repeater {
                                    model: ["Now", "Hourly"]

                                    Rectangle {
                                        id: weatherTabBtn
                                        required property string modelData
                                        Layout.fillWidth: true
                                        implicitHeight: 32
                                        radius: barSettings.barRadius
                                        color: weatherMonitor.selectedTab === modelData
                                            ? sidePanelWindow.themeTick >= 0 ? theme.color4 : theme.color4
                                            : sidePanelWindow.themeTick >= 0 ? Qt.darker(theme.background, 1.5) : Qt.darker(theme.background, 1.5)
                                        border {
                                            width: 1
                                            color: weatherMonitor.selectedTab === modelData
                                                ? theme.color4
                                                : Qt.darker(theme.muted, 1.5)
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: weatherTabBtn.modelData
                                            color: weatherMonitor.selectedTab === weatherTabBtn.modelData
                                                ? theme.background : theme.muted
                                            font.pixelSize: 11
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: weatherMonitor.selectedTab = weatherTabBtn.modelData
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    visible: weatherMonitor.selectedTab === "Now"

                                    Repeater {
                                        model: [
                                            { icon: "󰔏", value: weather.feelsLikeC + "°C", label: "Feels" },
                                            { icon: "󰖝", value: weather.windSpeed + " km/h", label: weather.windDir },
                                            { icon: "󰖎", value: weather.humidity + "%", label: "Humidity" }
                                        ]

                                        ColumnLayout {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Text {
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                text:           modelData.icon
                                                font.pixelSize: 14
                                                font.family:    "JetBrains Mono Nerd Font Mono"
                                                color:          sidePanelWindow.themeTick >= 0 ? theme.color6 : theme.color6
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                text:           modelData.value
                                                color:          sidePanelWindow.themeTick >= 0 ? theme.foreground : theme.foreground
                                                font.pixelSize: 11
                                                font.bold:      true
                                                font.family:    "JetBrains Mono Nerd Font Mono"
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                text:           modelData.label
                                                color:          sidePanelWindow.themeTick >= 0 ? theme.muted : theme.muted
                                                font.pixelSize: 9
                                            }
                                        }
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    visible: weatherMonitor.selectedTab === "Hourly" && weather.loaded

                                    Repeater {
                                        model: 5

                                        ColumnLayout {
                                            required property int index
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Text {
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                text:      weather.getHourlyLabel(index)
                                                color:     sidePanelWindow.themeTick >= 0 ? theme.muted : theme.muted
                                                font.pixelSize: 9
                                                font.family: "JetBrains Mono Nerd Font Mono"
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                text:      weather.getHourlyIcon(index)
                                                font.pixelSize: 14
                                                font.family: "JetBrains Mono Nerd Font Mono"
                                                color: sidePanelWindow.themeTick >= 0 ? theme.color4 : theme.color4
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                text:      weather.getHourlyTemp(index) + "°"
                                                color:     sidePanelWindow.themeTick >= 0 ? theme.foreground : theme.foreground
                                                font.pixelSize: 10
                                                font.bold:  true
                                                font.family: "JetBrains Mono Nerd Font Mono"
                                            }
                                        }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: weatherMonitor.selectedTab === "Hourly" && !weather.loaded
                                    text:      "Loading..."
                                    color:     sidePanelWindow.themeTick >= 0 ? theme.muted : theme.muted
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }

                    // SECTION 3: Salaat
                    Rectangle {
                        id: salaatMonitor
                        Layout.fillWidth: true
                        implicitHeight: salaatCol.implicitHeight + 16
                        radius:   barSettings.barRadius
                        color:    Qt.darker(theme.background, 1.2)
                        border { width: barSettings.borderThickness; color: Qt.darker(theme.muted, 1.5) }

                        property string selectedTab: "Times"

                        ColumnLayout {
                            id: salaatCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text:      "Salaat"
                                    color:     sidePanelWindow.themeTick >= 0 ? theme.foreground : theme.foreground
                                    font.pixelSize: 14
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: salaat.loaded && salaat.nextPrayer !== ""
                                    text:      "Next: " + salaat.nextPrayer + " " + salaat.nextTime
                                    color:     sidePanelWindow.themeTick >= 0 ? theme.color3 : theme.color3
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Repeater {
                                    model: ["Times", "Quran", "Sunnah", "Player"]

                                    Rectangle {
                                        id: salaatTabBtn
                                        required property string modelData
                                        Layout.fillWidth: true
                                        implicitHeight: 32
                                        radius: barSettings.barRadius
                                        color: salaatMonitor.selectedTab === modelData
                                            ? sidePanelWindow.themeTick >= 0 ? theme.color3 : theme.color3
                                            : sidePanelWindow.themeTick >= 0 ? Qt.darker(theme.background, 1.5) : Qt.darker(theme.background, 1.5)
                                        border {
                                            width: 1
                                            color: salaatMonitor.selectedTab === modelData
                                                ? theme.color3
                                                : Qt.darker(theme.muted, 1.5)
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: salaatTabBtn.modelData
                                            color: salaatMonitor.selectedTab === salaatTabBtn.modelData
                                                ? theme.background : theme.muted
                                            font.pixelSize: 11
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: salaatMonitor.selectedTab = salaatTabBtn.modelData
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 90

                                Flickable {
                                    id: salaatFlick
                                    anchors.fill: parent
                                    visible: salaatMonitor.selectedTab === "Times"
                                    contentHeight: prayerList.implicitHeight
                                    clip: true
                                    boundsBehavior: Flickable.StopAtBounds

                                    // Handle wheel events - scroll salaat if possible, don't propagate
                                    WheelHandler {
                                        target: null
                                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                        onWheel: event => {
                                            if (salaatFlick.contentHeight > salaatFlick.height) {
                                                const delta = event.angleDelta.y > 0 ? -40 : 40
                                                salaatFlick.contentY = Math.max(0, Math.min(
                                                    salaatFlick.contentY + delta,
                                                    salaatFlick.contentHeight - salaatFlick.height
                                                ))
                                                event.accepted = true
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        id: prayerList
                                        width: parent.width
                                        spacing: 2

                                        Repeater {
                                            model: [
                                                { name: "Fajr",    time: salaat.fajr },
                                                { name: "Sunrise", time: salaat.sunrise },
                                                { name: "Dhuhr",   time: salaat.dhuhr },
                                                { name: "Asr",     time: salaat.asr },
                                                { name: "Maghrib", time: salaat.maghrib },
                                                { name: "Isha",    time: salaat.isha }
                                            ]

                                            Rectangle {
                                                required property var modelData
                                                Layout.fillWidth: true
                                                implicitHeight: 22
                                                radius: 3
                                                color: modelData.name === salaat.nextPrayer
                                                    ? sidePanelWindow.themeTick >= 0 ? Qt.darker(theme.color3, 1.5) : Qt.darker(theme.color3, 1.5)
                                                    : "transparent"

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 8
                                                    anchors.rightMargin: 8

                                                    Text {
                                                        text: modelData.name
                                                        color: modelData.name === salaat.nextPrayer
                                                            ? sidePanelWindow.themeTick >= 0 ? theme.color3 : theme.color3
                                                            : sidePanelWindow.themeTick >= 0 ? theme.foreground : theme.foreground
                                                        font.pixelSize: 11
                                                        font.bold: true
                                                        font.family: "JetBrains Mono Nerd Font Mono"
                                                        Layout.fillWidth: true
                                                    }

                                                    Text {
                                                        text: modelData.time
                                                        color: modelData.name === salaat.nextPrayer
                                                            ? sidePanelWindow.themeTick >= 0 ? theme.color3 : theme.color3
                                                            : sidePanelWindow.themeTick >= 0 ? theme.muted : theme.muted
                                                        font.pixelSize: 11
                                                        font.bold: true
                                                        font.family: "JetBrains Mono Nerd Font Mono"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    visible: salaatMonitor.selectedTab === "Quran"
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        text:      "Read the Quran with word-by-word translation"
                                        color:     sidePanelWindow.themeTick >= 0 ? theme.muted : theme.muted
                                        font.pixelSize: 10
                                        wrapMode:  Text.WordWrap
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        radius: barSettings.barRadius
                                        color: theme.color4
                                        border { width: 0 }

                                        Text {
                                            anchors.centerIn: parent
                                            text:  "Open Quran"
                                            color: theme.background
                                            font.pixelSize: 12
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.runCommand("chromium --app=https://www.quranwbw.com")
                                        }
                                    }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    visible: salaatMonitor.selectedTab === "Sunnah"
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        text:      "Browse hadith collections and sunnah references"
                                        color:     sidePanelWindow.themeTick >= 0 ? theme.muted : theme.muted
                                        font.pixelSize: 10
                                        wrapMode:  Text.WordWrap
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        radius: barSettings.barRadius
                                        color: theme.color5
                                        border { width: 0 }

                                        Text {
                                            anchors.centerIn: parent
                                            text:  "Open Sunnah"
                                            color: theme.background
                                            font.pixelSize: 12
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.runCommand("chromium --app=https://www.sunnah.com")
                                        }
                                    }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    visible: salaatMonitor.selectedTab === "Player"
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        text:      "Listen to Quran recitations"
                                        color:     sidePanelWindow.themeTick >= 0 ? theme.muted : theme.muted
                                        font.pixelSize: 10
                                        wrapMode:  Text.WordWrap
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        radius: barSettings.barRadius
                                        color: theme.color3
                                        border { width: 0 }

                                        Text {
                                            anchors.centerIn: parent
                                            text:  "Open Quran Player"
                                            color: theme.background
                                            font.pixelSize: 12
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.quranPlayerPopupOpen = true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // SECTION 4: Keyboard Layout
                    Rectangle {
                        id: kbdMonitor
                        Layout.fillWidth: true
                        implicitHeight: kbdCol.implicitHeight + 16
                        radius:   barSettings.barRadius
                        color:    Qt.darker(theme.background, 1.2)
                        border { width: barSettings.borderThickness; color: Qt.darker(theme.muted, 1.5) }

                        ColumnLayout {
                            id: kbdCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:           kbd.layoutIcon()
                                    font.pixelSize: 18
                                    font.family:    "JetBrains Mono Nerd Font Mono"
                                    color:          kbd.layoutColor()
                                }

                                Text {
                                    text:      "Keyboard"
                                    color:     theme.foreground
                                    font.pixelSize: 14
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text:      kbd.layoutLabel
                                    color:     kbd.layoutColor()
                                    font.pixelSize: 14
                                    font.bold: true
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:      "Active"
                                    color:     theme.muted
                                    font.pixelSize: 11
                                }

                                Text {
                                    text:      kbd.activeLayout
                                    color:     theme.foreground
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text:      kbd.loaded ? "Loaded" : "Loading..."
                                    color:     kbd.loaded ? theme.color2 : theme.muted
                                    font.pixelSize: 11
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text:      "Press Alt+Shift to toggle layouts."
                                color:     theme.muted
                                font.pixelSize: 10
                                wrapMode:  Text.WordWrap
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                radius: barSettings.barRadius
                                color: kbd.layoutColor()
                                border { width: 0 }

                                Text {
                                    anchors.centerIn: parent
                                    text:  "Toggle Layout"
                                    color: theme.background
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.runCommand("python3 ~/.config/xkb/symbols/my_ar.py")
                                }
                            }
                        }
                    }

                    // SECTION 5: Bluetooth
                    Rectangle {
                        id: btMonitor
                        Layout.fillWidth: true
                        implicitHeight: btCol.implicitHeight + 16
                        radius:   barSettings.barRadius
                        color:    Qt.darker(theme.background, 1.2)
                        border { width: barSettings.borderThickness; color: Qt.darker(theme.muted, 1.5) }

                        property string selectedTab: "Status"

                        ColumnLayout {
                            id: btCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text:      "Bluetooth"
                                color:     theme.foreground
                                font.pixelSize: 14
                                font.bold: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Repeater {
                                    model: ["Status", "Devices", "Pair"]

                                    Rectangle {
                                        id: btTabBtn
                                        required property string modelData
                                        Layout.fillWidth: true
                                        implicitHeight: 32
                                        radius: barSettings.barRadius
                                        color: btMonitor.selectedTab === modelData
                                            ? theme.color6
                                            : Qt.darker(theme.background, 1.5)
                                        border {
                                            width: 1
                                            color: btMonitor.selectedTab === modelData
                                                ? theme.color6
                                                : Qt.darker(theme.muted, 1.5)
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: btTabBtn.modelData
                                            color: btMonitor.selectedTab === btTabBtn.modelData
                                                ? theme.background : theme.muted
                                            font.pixelSize: 11
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: btMonitor.selectedTab = btTabBtn.modelData
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 110

                                ColumnLayout {
                                    anchors.fill: parent
                                    visible: btMonitor.selectedTab === "Status"
                                    spacing: 8

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            text:           bt.btIcon()
                                            font.pixelSize: 32
                                            font.family:    "JetBrains Mono Nerd Font Mono"
                                            color:          bt.btColor()
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Text {
                                                text:      bt.stateLabel()
                                                color:     theme.foreground
                                                font.pixelSize: 14
                                                font.bold: true
                                            }

                                            Text {
                                                text:      bt.adapterName
                                                color:     theme.muted
                                                font.pixelSize: 12
                                                font.family: "JetBrains Mono Nerd Font Mono"
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        radius: barSettings.barRadius
                                        color: bt.enabled ? theme.color6 : "transparent"
                                        border { width: barSettings.borderThickness; color: theme.color6 }

                                        Text {
                                            anchors.centerIn: parent
                                            text:  bt.enabled ? "Disable Bluetooth" : "Enable Bluetooth"
                                            color: bt.enabled ? theme.background : theme.color6
                                            font.pixelSize: 12
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: bt.toggle()
                                        }
                                    }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    visible: btMonitor.selectedTab === "Devices"
                                    spacing: 4

                                    Flickable {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        contentHeight: deviceList.implicitHeight
                                        clip: true
                                        boundsBehavior: Flickable.StopAtBounds

                                        ColumnLayout {
                                            id: deviceList
                                            width: parent.width
                                            spacing: 4

                                            Repeater {
                                                model: bt.adapterValid ? bt.adapter.devices : []

                                                Rectangle {
                                                    required property var modelData
                                                    Layout.fillWidth: true
                                                    implicitHeight: 28
                                                    radius: 3
                                                    color: modelData.connected ? Qt.darker(theme.background, 1.4) : "transparent"
                                                    border { width: 1; color: modelData.connected ? theme.color6 : Qt.darker(theme.muted, 1.5) }

                                                    RowLayout {
                                                        anchors.fill: parent
                                                        anchors.leftMargin: 6
                                                        anchors.rightMargin: 4
                                                        spacing: 6

                                                        Text {
                                                            text: modelData.connected ? "󰂱" : "󰂯"
                                                            font.pixelSize: 12
                                                            font.family: "JetBrains Mono Nerd Font Mono"
                                                            color: modelData.connected ? theme.color6 : theme.muted
                                                        }

                                                        Text {
                                                            text: modelData.name || modelData.address
                                                            color: modelData.connected ? theme.foreground : theme.muted
                                                            font.pixelSize: 11
                                                            font.family: "JetBrains Mono Nerd Font Mono"
                                                            Layout.fillWidth: true
                                                            elide: Text.ElideRight
                                                        }

                                                        Rectangle {
                                                            Layout.preferredWidth: 24
                                                            Layout.preferredHeight: 20
                                                            radius: 3
                                                            color: "transparent"
                                                            border { width: 1; color: theme.color1 }

                                                            Text {
                                                                anchors.centerIn: parent
                                                                text:  "✕"
                                                                color: theme.color1
                                                                font.pixelSize: 11
                                                                font.bold: true
                                                            }

                                                            MouseArea {
                                                                anchors.fill: parent
                                                                cursorShape: Qt.PointingHandCursor
                                                                onClicked: bt.connectDevice(modelData)
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Text {
                                                visible: !bt.adapterValid
                                                text:      "No adapter available"
                                                color:     theme.muted
                                                font.pixelSize: 11
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                    }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    visible: btMonitor.selectedTab === "Pair"
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        text:      "Pair a new Bluetooth device using the system manager."
                                        color:     theme.muted
                                        font.pixelSize: 10
                                        wrapMode:  Text.WordWrap
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        radius: barSettings.barRadius
                                        color: theme.color6
                                        border { width: 0 }

                                        Text {
                                            anchors.centerIn: parent
                                            text:  "Open Bluetooth Manager"
                                            color: theme.background
                                            font.pixelSize: 12
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.runCommand("blueman-manager")
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // SECTION 6: Screen Recorder
                    Rectangle {
                        id: recMonitor
                        Layout.fillWidth: true
                        implicitHeight: recCol.implicitHeight + 16
                        radius:   barSettings.barRadius
                        color:    Qt.darker(theme.background, 1.2)
                        border { width: barSettings.borderThickness; color: Qt.darker(theme.muted, 1.5) }

                        ColumnLayout {
                            id: recCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text:      "Screen Recorder"
                                    color:     theme.foreground
                                    font.pixelSize: 14
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text:      recBtn.isRecording ? "REC" : "Idle"
                                    color:     recBtn.isRecording ? theme.color1 : theme.muted
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.family: "JetBrains Mono Nerd Font Mono"
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text:      recBtn.isRecording
                                    ? "Recording in progress. Click to stop."
                                    : "Click to start a new screen recording."
                                color:     theme.muted
                                font.pixelSize: 10
                                wrapMode:  Text.WordWrap
                            }

                            Rectangle {
                                id: recBtn
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                radius: barSettings.barRadius
                                color: recBtn.isRecording ? theme.color1 : theme.color4
                                border { width: 0 }

                                property bool isRecording: false

                                Text {
                                    anchors.centerIn: parent
                                    text:  recBtn.isRecording ? "Stop Recording" : "Start Recording"
                                    color: theme.background
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                SequentialAnimation {
                                    id: recPulse
                                    running: recBtn.isRecording
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

                                Binding {
                                    target: recBtn
                                    property: "opacity"
                                    value: 1.0
                                    when: !recBtn.isRecording
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        recBtn.isRecording = !recBtn.isRecording
                                        recProc.running = true
                                    }
                                }
                            }

                            Process {
                                id: recProc
                                command: ["nohup", "setsid", "bash", "-c",
                                    Quickshell.env("HOME") + "/.config/quickshell/scripts/wf-recorder.sh </dev/null >/dev/null 2>&1"]
                                running: false
                            }
                        }
                    }

                    Item { Layout.fillHeight: true; Layout.preferredHeight: 20 }
                }
            }
        }
    }
}
