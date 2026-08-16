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

        Rectangle {
            id:           barBackground
            anchors.fill: parent
            color:        "transparent"
            radius: barSettings.barRadius
            visible:      barSettings.loaded

            Rectangle {
                id:           barFill
                anchors.fill: parent
                color:        theme.background
                opacity:      barSettings.barOpacity
                radius:       barSettings.barRadius
                border { color: theme.color2; width: barSettings.borderThickness }
            }

            Connections {
                target: theme
                function onColorsChanged() { themeTransition.start() }
            }

            SequentialAnimation {
                id: themeTransition
                PropertyAnimation {
                    target: barFill
                    property: "opacity"
                    to: barSettings.barOpacity * 0.6
                    duration: 120
                    easing.type: Easing.InQuad
                }
                PropertyAnimation {
                    target: barFill
                    property: "opacity"
                    to: barSettings.barOpacity
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            RowLayout {
                anchors {
                    fill:         parent
                    leftMargin:   10
                    rightMargin:  10
                    topMargin:    10
                    bottomMargin: 10
                }
                spacing: 5

                // ── Arch Logo //
                Rectangle {
                    id:     archBtn
                    width:  40
                    height: 40
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: hovered ? theme.muted : theme.color2 }

                    property bool hovered: false
                    property string archLogoPath: "file://" + Quickshell.env("HOME") + "/.config/quickshell/assets/arch.png"
                    property int archLogoVersion: 0

                    FileView {
                        id: archLogoWatcher
                        path: Quickshell.env("HOME") + "/.config/quickshell/assets/arch.png"
                        watchChanges: true
                        onFileChanged: archBtn.archLogoVersion++
                    }

                    Image {
                        anchors.centerIn:  parent
                        width:             30
                        height:            30
                        source:            archBtn.archLogoPath + "?v=" + archBtn.archLogoVersion
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

                                color: barSettings.workspaceStyle === "dots" ? "transparent" : (isActive ? theme.color2 : (hasWindows ? Qt.darker(theme.background, 1.25) : "transparent"))
                                border.width: barSettings.workspaceStyle === "dots" ? 0 : 0

                                Text {
                                    anchors.centerIn: parent
                                    visible:          barSettings.workspaceStyle !== "dots"
                                    text:             parent.workspaceId.toString()
                                    color:            parent.isActive ? theme.background : (parent.hasWindows ? theme.color4 : theme.muted)
                                    font.pixelSize:   14
                                    font.bold:        true
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    visible:          barSettings.workspaceStyle === "dots" && !parent.isActive
                                    width: 14
                                    height: 14
                                    radius: 7
                                    color: parent.hasWindows ? Qt.darker(theme.background, 1.25) : theme.muted
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    visible:          barSettings.workspaceStyle === "dots" && parent.isActive
                                    width: 20
                                    height: 14
                                    radius: 7
                                    color: theme.color2
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


                // ── Settings ────────────────────────────────────────────
                Rectangle {
                    id:     settingsBtn
                    width:  40
                    height: 40
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: hovered ? theme.muted : theme.color5 }

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
                        }
                    }
                }

                // ── Center Spacer ─────────────────────────────────────────
                Item { Layout.fillWidth: true }

                // ── Themes //──
                Rectangle {
                    id:     themesBtn
                    width:  40
                    height: 40
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: hovered ? theme.muted : theme.color6 }

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
                        }
                    }
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
                }

                //─
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
                            color: hovered ? theme.muted : (audio.volumeMuted ? theme.color1 : theme.color4)
                        }

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
                        color:            clockBtn.hovered ? theme.color1 : theme.muted
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
                        onContainsMouseChanged: clockBtn.hovered = containsMouse
                        onClicked:    root.calendarPopupOpen = !root.calendarPopupOpen
                    }

                    property bool hovered: false
                }

                // ── Widgets Toggle ─────────────────────────────────────────
                Rectangle {
                    id:     widgetsBtn
                    width:  40
                    height: 40
                    radius: barSettings.barRadius
                    color:  "transparent"
                    border { width: barSettings.borderThickness; color: widgetsBtn.hovered || root.sidePanelOpen || root.widget2Open ? theme.muted : theme.color4 }

                    Layout.alignment: Qt.AlignVCenter

                    property bool hovered: false

                    Text {
                        anchors.centerIn: parent
                        text:           "󰕰"
                        font.pixelSize: 18
                        color:          widgetsBtn.hovered || root.sidePanelOpen || root.widget2Open ? theme.foreground : theme.color4
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    MouseArea {
                        anchors.fill:     parent
                        hoverEnabled:     true
                        cursorShape:      Qt.PointingHandCursor
                        acceptedButtons:  Qt.LeftButton | Qt.RightButton

                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                root.toggleWidget2()
                            } else {
                                root.toggleSidePanel()
                            }
                        }

                        onContainsMouseChanged: {
                            widgetsBtn.hovered = containsMouse
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

        // ── Active Window Title (centered) ────────────────────────────
        Rectangle {
            id:     activeWindowBtn
            z: 10
            visible: barSettings.loaded
            radius: barSettings.barRadius
            color:  theme.background
            opacity: 0.85
            border { width: barSettings.borderThickness; color: activeWindowBtn.hovered ? theme.muted : theme.color4 }

            implicitWidth: 200
            implicitHeight: 40

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter

            property bool hovered: false
            property string windowTitle: "Desktop"
            property string windowClass: ""

            // Scrolling marquee for long titles
            Process {
                id: hyprctlProc
                command: ["hyprctl", "activewindow", "-j"]
                property string buffer: ""
                stdout: SplitParser {
                    onRead: data => {
                        hyprctlProc.buffer += data
                    }
                }
                onRunningChanged: {
                    if (!running && hyprctlProc.buffer.length > 0) {
                        try {
                            const info = JSON.parse(hyprctlProc.buffer)
                            if (info && info.title !== undefined) {
                                activeWindowBtn.windowTitle = info.title || ""
                                activeWindowBtn.windowClass = info.class || ""
                            }
                        } catch (e) {}
                        hyprctlProc.buffer = ""
                    }
                }
            }

            Timer {
                interval: 500
                running: true
                repeat: true
                onTriggered: hyprctlProc.running = true
            }

            // Scrolling marquee for long titles
            clip: true

            Item {
                id: marqueeContainer
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                clip: true

                property real scrollOffset: 0
                property bool needsScroll: false
                property string displayText: activeWindowBtn.windowTitle || activeWindowBtn.windowClass || "Desktop"

                Text {
                    id: measureText
                    visible: false
                    text: marqueeContainer.displayText
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "JetBrains Mono Nerd Font Mono"
                    onImplicitWidthChanged: marqueeContainer.checkScroll()
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: !marqueeContainer.needsScroll
                    text: marqueeContainer.displayText
                    color: activeWindowBtn.hovered ? theme.foreground : theme.muted
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "JetBrains Mono Nerd Font Mono"
                }

                Item {
                    visible: marqueeContainer.needsScroll
                    anchors.fill: parent

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        x: -marqueeContainer.scrollOffset

                        Repeater {
                            model: 2
                            Text {
                                text: marqueeContainer.displayText
                                color: activeWindowBtn.hovered ? theme.foreground : theme.muted
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrains Mono Nerd Font Mono"
                            }
                        }
                    }
                }

                onWidthChanged: checkScroll()
                Component.onCompleted: checkScroll()

                function checkScroll() {
                    needsScroll = measureText.implicitWidth > width
                    scrollOffset = 0
                    if (!needsScroll) {
                        scrollTimer.stop()
                    } else {
                        scrollTimer.start()
                    }
                }

                Timer {
                    id: scrollTimer
                    interval: 30
                    repeat: true
                    running: false
                    onTriggered: {
                        if (marqueeContainer.needsScroll) {
                            marqueeContainer.scrollOffset += 1
                            if (marqueeContainer.scrollOffset >= measureText.implicitWidth) {
                                marqueeContainer.scrollOffset = 0
                            }
                        }
                    }
                }
            }
        }
    }
}
