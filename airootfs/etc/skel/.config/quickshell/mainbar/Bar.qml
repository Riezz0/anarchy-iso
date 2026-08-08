// ═══════════════════════════════════════════════════════════════════════════════
// Bar - Main Status Bar
// ═══════════════════════════════════════════════════════════════════════════════
// The top bar containing: Arch logo, workspaces, Bluetooth, system resources,
// weather, recorder, notifications, volume, clock, and power button.
// Displayed on configured monitor(s) via barSettings.barMonitor.
//
// Required properties (passed from shell.qml):
//   theme, audio, bt, weather, stats, calendar
//   Various popup open/close signals
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Variants {
    model: barSettings.popupScreens()

        PanelWindow {
            id:     barWindow
            screen: modelData
            required property var modelData
            property bool settingsPopupOpen: false

            anchors {
                top:    barSettings.barPosition === "top"
                bottom: barSettings.barPosition === "bottom"
                left:   true
                right:  true
            }

            implicitHeight: 60
            color:          "transparent"
            exclusiveZone:  implicitHeight
            exclusionMode:  ExclusionMode.Normal

            margins { left: 10; right: 10; top: 10; bottom: 10 }

            Process {
                id: bluemanProc
                command: ["blueman-manager"]
                running: false
            }

            property var scratchpadOpenClasses: []

            Process {
                id: clientsProc
                command: ["hyprctl", "clients", "-j"]
                running: false
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            var data = JSON.parse(text())
                            var found = []
                            for (var i = 0; i < data.length; i++) {
                                var cls = data[i].class || ""
                                if (cls === "nautipad" || cls === "termpad" || cls === "vimpad" || cls === "codipad")
                                    found.push(cls)
                            }
                            barWindow.scratchpadOpenClasses = found
                        } catch(e) {}
                    }
                }
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    clientsProc.running = false
                    clientsProc.running = true
                }
            }

        Rectangle {
            id:           barBackground
            anchors.fill: parent
            color:        "transparent"
            radius: barSettings.barRadius

            Rectangle {
                anchors.fill: parent
                color:        theme.background
                opacity:      barSettings.barOpacity
                radius: barSettings.barRadius
                border { color: theme.color2; width: barSettings.borderThickness }
            }

            RowLayout {
                anchors {
                    fill:         parent
                    leftMargin:   10
                    rightMargin:  10
                    topMargin:    10
                    bottomMargin: 10
                }
                spacing: 10

                // ── Arch Logo //
                Rectangle {
                    id:     archBtn
                    width:  40
                    height: 40
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: theme.color2 }

                    property bool hovered: false

                    Image {
                        anchors.centerIn:  parent
                        width:             30
                        height:            30
                        source:            "file://" + Quickshell.env("HOME") + "/.config/quickshell/assets/arch.png"
                        smooth:            true
                        mipmap:            true
                        fillMode:          Image.PreserveAspectFit
                        sourceSize.width:  64
                        sourceSize.height: 65
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onEntered:    archBtn.hovered = true
                        onExited:     archBtn.hovered = false
                        onClicked:    { root.keybindsPopupOpen = !root.keybindsPopupOpen }
                    }

                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    onHoveredChanged: { border.color = hovered ? theme.muted : theme.color2 }
                }

                // ── Workspaces ────────────────────────────────────────────
                Rectangle {
                    id:     workspaceContainer
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { color: theme.color4; width: barSettings.borderThickness }

                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth:    workspaceRow.implicitWidth + 20
                    implicitHeight:   workspaceRow.implicitHeight + 15

                    Row {
                        id:               workspaceRow
                        spacing:          5
                        anchors.centerIn: parent

                        // ── Regular Workspaces (dynamic) ──────────────────
                        Repeater {
                            model: {
                                let maxId = 5
                                for (let i = 0; i < Hyprland.workspaces.count; ++i) {
                                    const ws = Hyprland.workspaces.get(i)
                                    if (ws.id > maxId) maxId = ws.id
                                }
                                if (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id > maxId)
                                    maxId = Hyprland.focusedWorkspace.id
                                return maxId
                            }

                            Rectangle {
                                required property int index
                                property int workspaceId: index + 1
                                width:  25
                                height: 25
                                radius: barSettings.barRadius

                                property bool isActive: Hyprland.focusedWorkspace
                                    && Hyprland.focusedWorkspace.id === workspaceId

                                property bool hasWindows: {
                                    for (let i = 0; i < Hyprland.workspaces.count; ++i) {
                                        const ws = Hyprland.workspaces.get(i)
                                        if (ws.id === workspaceId && ws.windowCount > 0)
                                            return true
                                    }
                                    return false
                                }

                                color:        isActive ? theme.color2 : (hasWindows ? Qt.darker(theme.background, 1.25) : "transparent")

                                Text {
                                    anchors.centerIn: parent
                                    text:             parent.workspaceId.toString()
                                    color:            parent.isActive ? theme.background : (parent.hasWindows ? theme.color4 : theme.muted)
                                    font.pixelSize:   14
                                    font.bold:        true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked: {
                                        if (Hyprland.usingLua) {
                                            Hyprland.dispatch("hl.dsp.focus({ workspace = " + parent.workspaceId + " })")
                                        } else {
                                            Hyprland.dispatch("workspace " + parent.workspaceId)
                                        }
                                    }
                                }
                            }
                        }

                    }
                }

                // ── Bluetooth ────────────────────────────────────────────
                Item {
                    id:     btButton
                    implicitWidth:  40
                    implicitHeight: 40

                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        id:           btRect
                        anchors.fill: parent
                        color:        "transparent"
                        radius: barSettings.barRadius
                        property bool hovered: false
                        border {
                            width: barSettings.borderThickness
                            color: theme.color2
                        }

                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text:           bt.btIcon()
                            font.pixelSize: 18
                            color:          btRect.hovered ? theme.foreground : bt.btColor()
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }

                    MouseArea {
                        anchors.fill:     parent
                        hoverEnabled:     true
                        cursorShape:      Qt.PointingHandCursor
                        acceptedButtons:  Qt.LeftButton | Qt.RightButton

                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                bt.toggle()
                            } else {
                                bluemanProc.running = true
                            }
                        }

                        onContainsMouseChanged: {
                            btRect.hovered = containsMouse
                            btRect.border.color = containsMouse ? theme.muted : theme.color2
                        }
                    }
                }

                // ── System Resources ─────────────────────────────────────
                Rectangle {
                    id:     tempModule
                    width:  40
                    height: 40
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: theme.color2 }

                    Layout.alignment: Qt.AlignVCenter

                    property bool hovered: false

                    Text {
                        anchors.centerIn: parent
                        text:           "󰍛"
                        font.pixelSize: 18
                            color:          tempModule.hovered ? theme.foreground : theme.color4
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.tempPopupOpen = !root.tempPopupOpen
                        onContainsMouseChanged: {
                            tempModule.hovered = containsMouse
                            tempModule.border.color = containsMouse ? theme.muted : theme.color2
                        }
                    }

                    Behavior on border.color { ColorAnimation { duration: 120 } }
                }

                // ── Weather //─
                Rectangle {
                    id:     weatherBtn
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: theme.color4 }

                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight:   40
                    implicitWidth:    weatherRow.implicitWidth + 28

                    property bool hovered: false

                    Row {
                        id:               weatherRow
                        anchors.centerIn: parent
                        spacing:          6

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           weather.weatherIconText()
                            font.pixelSize: 14
                            color:          weatherBtn.hovered ? theme.foreground : theme.color4
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           weather.loaded ? weather.tempDisplay() : "--"
                            font.pixelSize: 14
                            font.bold:      true
                            font.family:    "JetBrains Mono Nerd Font Mono"
                            color:          theme.muted
                        }
                    }

                    MouseArea {
                        anchors.fill:    parent
                        hoverEnabled:    true
                        cursorShape:     Qt.PointingHandCursor
                        onClicked:       root.weatherPopupOpen = !root.weatherPopupOpen
                        onContainsMouseChanged: {
                            weatherBtn.hovered = containsMouse
                            weatherBtn.border.color = containsMouse ? theme.muted : theme.color4
                        }
                    }

                    Behavior on border.color { ColorAnimation { duration: 120 } }
                }

                // ── Keyboard Layout ──────────────────────────────────────
                Rectangle {
                    id:     kbdBtn
                    width:  kbdRow.implicitWidth + 20
                    height: 40
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: theme.color4 }

                    Layout.alignment: Qt.AlignVCenter

                    property bool hovered: false

                    Row {
                        id:               kbdRow
                        anchors.centerIn: parent
                        spacing:          6

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           kbd.layoutIcon()
                            font.pixelSize: 14
                            color:          kbdBtn.hovered ? theme.foreground : kbd.layoutColor()
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           kbd.loaded ? kbd.layoutLabel : "--"
                            font.pixelSize: 13
                            font.bold:      true
                            font.family:    "JetBrains Mono Nerd Font Mono"
                            color:          theme.muted
                        }
                    }

                    MouseArea {
                        anchors.fill:    parent
                        hoverEnabled:    true
                        cursorShape:     Qt.PointingHandCursor
                        onClicked:       root.runCommand("python3 ~/.config/xkb/symbols/my_ar.py")
                        onContainsMouseChanged: {
                            kbdBtn.hovered = containsMouse
                            kbdBtn.border.color = containsMouse ? theme.muted : theme.color4
                        }
                    }

                    Behavior on border.color { ColorAnimation { duration: 120 } }
                }

                // ── Settings ────────────────────────────────────────────
                Rectangle {
                    id:     settingsBtn
                    width:  40
                    height: 40
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: theme.color5 }

                    Layout.alignment: Qt.AlignVCenter

                    property bool hovered: false

                    Text {
                        anchors.centerIn: parent
                        text:           "󰒓"
                        font.pixelSize: 18
                        color:          settingsBtn.hovered ? theme.foreground : theme.color5
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.settingsPopupOpen = !root.settingsPopupOpen
                        onContainsMouseChanged: {
                            settingsBtn.hovered = containsMouse
                            settingsBtn.border.color = containsMouse ? theme.muted : theme.color5
                        }
                    }

                    Behavior on border.color { ColorAnimation { duration: 120 } }
                }

                // ── Center Spacer ─────────────────────────────────────────
                Item { Layout.fillWidth: true }

                // ── Network //─
                Rectangle {
                    id:     netBtn
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: theme.color4 }

                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight:   40
                    implicitWidth:    netRow.implicitWidth + 28

                    property bool hovered: false

                    Row {
                        id:               netRow
                        anchors.centerIn: parent
                        spacing:          6

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           net.networkIcon()
                            font.pixelSize: 14
                            color:          netBtn.hovered ? theme.foreground : net.networkColor()
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           net.loaded ? net.displayText() : "--"
                            font.pixelSize: 12
                            font.bold:      true
                            font.family:    "JetBrains Mono Nerd Font Mono"
                            color:          theme.muted
                        }
                    }

                    MouseArea {
                        anchors.fill:    parent
                        hoverEnabled:    true
                        cursorShape:     Qt.PointingHandCursor
                        onClicked:       root.networkPopupOpen = !root.networkPopupOpen
                        onContainsMouseChanged: {
                            netBtn.hovered = containsMouse
                            netBtn.border.color = containsMouse ? theme.muted : theme.color4
                        }
                    }

                    Behavior on border.color { ColorAnimation { duration: 120 } }
                }

                // ── Themes //──
                Rectangle {
                    id:     themesBtn
                    width:  40
                    height: 40
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: theme.color6 }

                    Layout.alignment: Qt.AlignVCenter

                    property bool hovered: false

                    Text {
                        anchors.centerIn: parent
                        text:           "󰏘"
                        font.pixelSize: 18
                        color:          themesBtn.hovered ? theme.foreground : theme.color6
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.themesPopupOpen = !root.themesPopupOpen
                        onContainsMouseChanged: {
                            themesBtn.hovered = containsMouse
                            themesBtn.border.color = containsMouse ? theme.muted : theme.color6
                        }
                    }

                    Behavior on border.color { ColorAnimation { duration: 120 } }
                }

                // ── Updates ──────────────────────────────────────────────
                Rectangle {
                    id:     updatesBtn
                    implicitWidth:  updatesRow.implicitWidth + 20
                    implicitHeight: 40
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: updatesBtn.hovered ? theme.muted : (updates.updatesAvailable ? theme.color3 : theme.color4) }

                    Layout.alignment: Qt.AlignVCenter

                    property bool hovered: false

                    Row {
                        id:               updatesRow
                        anchors.centerIn: parent
                        spacing:          6

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           updates.updateIcon()
                            font.pixelSize: 14
                            color:          updatesBtn.hovered ? theme.foreground : updates.updateColor()
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           String(updates.updateCount)
                            font.pixelSize: 14
                            font.bold:      true
                            font.family:    "JetBrains Mono Nerd Font Mono"
                            color:          updates.updatesAvailable ? theme.color3 : theme.muted
                        }
                    }

                    MouseArea {
                        anchors.fill:     parent
                        hoverEnabled:     true
                        cursorShape:      Qt.PointingHandCursor
                        acceptedButtons:  Qt.LeftButton | Qt.RightButton

                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                root.archUpdatePopupOpen = !root.archUpdatePopupOpen
                            } else {
                                updates.launchUpdate()
                            }
                        }

                        onContainsMouseChanged: {
                            updatesBtn.hovered = containsMouse
                        }
                    }

                    Behavior on border.color { ColorAnimation { duration: 120 } }
                }

                //─
                Recorder {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                }

                // ── Notifications ─────────────────────────────────────────
                Item {
                    id:     notifButton
                    implicitWidth:  40
                    implicitHeight: 40

                    Layout.alignment: Qt.AlignVCenter

                    property bool hovered: false

                    Rectangle {
                        id:           notifRect
                        anchors.fill: parent
                        color:        "transparent"
                        radius: barSettings.barRadius
                        border {
                            width: barSettings.borderThickness
                            color: notifButton.hovered ? theme.muted
                                 : notifs.hasUnread ? theme.color1
                                 : theme.color4
                        }

                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text:           notifs.notifIcon()
                            font.pixelSize: 18
                            color:          notifButton.hovered ? theme.foreground : notifs.notifColor()
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        // Unread badge
                        Rectangle {
                            visible: notifs.trackedCount > 0
                            width:   16
                            height:  16
                            radius:  8
                            color:   theme.color1
                            anchors.top:    parent.top
                            anchors.right: parent.right
                            anchors.topMargin:   -4
                            anchors.rightMargin: -4

                            Text {
                                anchors.centerIn: parent
                                text:             notifs.trackedCount > 9 ? "9+" : String(notifs.trackedCount)
                                color:            theme.background
                                font.pixelSize:   9
                                font.bold:        true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill:     parent
                        hoverEnabled:     true
                        cursorShape:      Qt.PointingHandCursor
                        acceptedButtons:  Qt.LeftButton | Qt.RightButton

                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                notifs.clearAll()
                            } else {
                                root.notificationsPopupOpen = !root.notificationsPopupOpen
                            }
                        }

                        onContainsMouseChanged: {
                            notifButton.hovered = containsMouse
                        }
                    }
                }

                // ── Volume (Pipewire) ─────────────────────────────────────
                Item {
                    id:     volumeButton
                    implicitWidth:  74
                    implicitHeight: 40

                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        id:           volumeRect
                        anchors.fill: parent
                        color:        "transparent"
                        radius: barSettings.barRadius
                        property bool hovered: false
                        border {
                            width: barSettings.borderThickness
                            color: audio.volumeMuted ? theme.color1 : theme.color4
                        }

                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text:           audio.volumeIcon()
                                font.pixelSize: 18
                                color:          volumeRect.hovered ? theme.foreground : (audio.volumeMuted ? theme.color1 : theme.color2)
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text:           Math.round(audio.volumeLevel * 100) + "%"
                                font.pixelSize: 14
                                font.bold:      true
                                font.family:    "JetBrains Mono Nerd Font Mono"
                                color:          theme.muted
                            }
                        }
                    }

                    MouseArea {
                        id:               volumeArea
                        anchors.fill:     parent
                        hoverEnabled:     true
                        cursorShape:      Qt.PointingHandCursor
                        acceptedButtons:  Qt.LeftButton | Qt.RightButton

                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                audio.toggleMute()
                            } else {
                                root.volumePopupOpen = !root.volumePopupOpen
                            }
                        }

                        onWheel: wheel => {
                            const step  = 0.05
                            const delta = wheel.angleDelta.y > 0 ? step : -step
                            audio.setVolume(audio.volumeLevel + delta)
                        }

                        onContainsMouseChanged: {
                            volumeRect.hovered = containsMouse
                            volumeRect.border.color = containsMouse
                                ? theme.muted
                                : (audio.volumeMuted ? theme.color1 : theme.color4)
                        }
                    }
                }

                // ── Clock //────
                Item {
                    id:     clockBtn
                    implicitWidth:  clockLabel.implicitWidth + 16
                    implicitHeight: 40
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        id:               clockLabel
                        anchors.centerIn: parent
                        color:            theme.muted
                        font.pixelSize:   14
                        font.bold:        true
                        font.family:      "JetBrains Mono Nerd Font Mono"
                        text:             root.clockTime

                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    root.calendarPopupOpen = !root.calendarPopupOpen
                        onContainsMouseChanged: {
                            clockLabel.color = containsMouse ? theme.color1 : theme.muted
                        }
                    }
                }

                // ── Power Button ──────────────────────────────────────────
                Rectangle {
                    width:            40
                    height:           40
                    radius: barSettings.barRadius
                    color:            root.powerMenuOpen ? theme.color1 : "transparent"
                    opacity:          powerBtnMouse.containsMouse ? 0.6 : 1.0
                    border { color: theme.color1; width: barSettings.borderThickness }
                    Layout.alignment: Qt.AlignVCenter

                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text:             "\udb81\udc26"
                        color:            root.powerMenuOpen ? theme.background : theme.color1
                        font.pixelSize:   20
                    }

                        MouseArea {
                            id:               powerBtnMouse
                            anchors.fill:     parent
                            hoverEnabled:     true
                            cursorShape:      Qt.PointingHandCursor
                            onClicked:        root.togglePowerMenu()
                        }

                }
            }
        }

        // ── Salaat Widget (centered on screen, above bar) ─────────────
        Rectangle {
            id:     salaatBtn
            width:  200
            height: 40
            radius: barSettings.barRadius
            color:  "transparent"
            border { width: barSettings.borderThickness; color: theme.color3 }
            clip:   true
            z: 10

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter

            property bool hovered: false

            Text {
                anchors.centerIn: parent
                text:             salaat._displayText || "Loading..."
                font.pixelSize:   14
                font.bold:        true
                font.family:      "JetBrains Mono Nerd Font Mono"
                color:            salaatBtn.hovered ? theme.foreground : theme.muted
                Behavior on color { ColorAnimation { duration: 120 } }
                elide:            Text.ElideRight
                width:            parent.width - 16
                clip:             true
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.salaatPopupOpen = !root.salaatPopupOpen
                onContainsMouseChanged: {
                    salaatBtn.hovered = containsMouse
                    salaatBtn.border.color = containsMouse ? theme.muted : theme.color3
                }
            }

            Behavior on border.color { ColorAnimation { duration: 120 } }
        }
    }
}
