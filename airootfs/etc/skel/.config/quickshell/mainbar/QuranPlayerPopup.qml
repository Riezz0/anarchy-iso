import QtQuick
import QtQuick.Layouts
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
        focusable: quranPlayerPopup.isOpen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: quranPlayerPopup.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        Connections {
            target: quranPlayerPopup
            function onIsOpenChanged() {
                if (quranPlayerPopup.isOpen) { panelVisible = true }
                else { hideTimer.start() }
            }
        }

        Timer { id: hideTimer; interval: 220; onTriggered: panelVisible = false }

        MouseArea {
            anchors.fill: parent
            onClicked:    quranPlayerPopup.close()
            opacity: quranPlayerPopup.isOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Rectangle {
            id: popupRoot
            anchors.centerIn: parent
            width: popupRoot.showText ? 780 : 380
            height: 500
            radius:   barSettings.barRadius
            color:    theme.background
            opacity:  quranPlayerPopup.isOpen ? 0.95 : 0
            scale:    quranPlayerPopup.isOpen ? 1.0 : 0.95
            border { width: barSettings.borderThickness; color: theme.color3 }

            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            property bool showReciters: false
            property bool showSurahs: true
            property bool showText: false
            property bool showCogSettings: false
            property bool showTransGroup: false
            property bool showFontGroup: false

            MouseArea {
                anchors.fill: parent
                onClicked:    mouse => mouse.accepted = true
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ══════════════════════════════════════════════════════════════
                // Left panel: Player controls
                // ══════════════════════════════════════════════════════════════
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 380
                    Layout.margins: 16
                    spacing: 0

                    // ── Header ──
                    RowLayout {
                        Layout.fillWidth: true; Layout.bottomMargin: 12

                        Text { text: "󰂺"; font.pixelSize: 16; font.family: "JetBrains Mono Nerd Font Mono"; color: theme.color3 }
                        Text { text: "Quran Player"; font.pixelSize: 14; font.bold: true; color: theme.color3 }
                        Item { Layout.fillWidth: true }

                        // Read toggle (book icon)
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            width: 24; height: 24; radius: 12
                            color: readBtnArea.containsMouse ? Qt.darker(theme.muted, 1.3) : (popupRoot.showText ? theme.color3 : theme.muted)
                            Text {
                                anchors.centerIn: parent
                                text: "\u270D"
                                font.pixelSize: 13
                                color: popupRoot.showText ? theme.background : theme.foreground
                            }
                            MouseArea {
                                id: readBtnArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    popupRoot.showText = !popupRoot.showText
                                    if (popupRoot.showText && quranPlayer.currentSurah > 0)
                                        quranText.loadSurahIfNeeded(quranPlayer.currentSurah)
                                }
                            }
                        }

                        // Auto-next toggle (header)
                        RowLayout { spacing: 4; Layout.alignment: Qt.AlignVCenter
                            Rectangle {
                                width: 24; height: 16; radius: 8
                                color: barSettings.autoNext ? theme.color3 : Qt.darker(theme.muted, 1.3)
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: barSettings.autoNext ? parent.width - width - 2 : 2
                                    width: 12; height: 12; radius: 6; color: theme.background
                                    Behavior on x { NumberAnimation { duration: 120 } }
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: barSettings.autoNext = !barSettings.autoNext }
                            }
                            Text { text: "Auto play next"; font.pixelSize: 9; color: theme.muted }
                        }

                        Rectangle {
                            width: 24; height: 24; radius: 12
                            color: minBtnArea.containsMouse ? Qt.darker(theme.muted, 1.3) : theme.muted
                            Text { anchors.centerIn: parent; text: "\u2014"; font.pixelSize: 16; color: theme.foreground }
                            MouseArea {
                                id: minBtnArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: { quranPlayer.toggleMinimize(); quranPlayerPopup.close() }
                            }
                        }
                        Rectangle {
                            width: 24; height: 24; radius: 12
                            color: closeBtnArea.containsMouse ? Qt.darker(theme.muted, 1.3) : theme.muted
                            Text { anchors.centerIn: parent; text: "\u2715"; font.pixelSize: 12; color: theme.foreground }
                            MouseArea {
                                id: closeBtnArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: quranPlayerPopup.close()
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.bottomMargin: 12; height: 1; color: theme.muted; opacity: 0.4 }

                    // ── Now playing ──
                    Rectangle {
                        id: nowPlayingCard
                        Layout.fillWidth: true; Layout.preferredHeight: 56
                        radius: barSettings.barRadius; color: Qt.darker(theme.background, 1.2)
                        opacity: 1

                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        Connections {
                            target: quranPlayer
                            function onCurrentSurahChanged() {
                                if (quranPlayer.currentSurah === 0) return
                                nowPlayingCard.opacity = 0
                                fadeTimer.start()
                                if (popupRoot.showText)
                                    quranText.loadSurahIfNeeded(quranPlayer.currentSurah)
                            }
                        }

                        Timer {
                            id: fadeTimer
                            interval: 250; repeat: false
                            onTriggered: nowPlayingCard.opacity = 1
                        }

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 12

                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                width: 36; height: 36; radius: 18
                                color: theme.color3; opacity: 0.15
                                Text { anchors.centerIn: parent; text: "\u266B"; font.pixelSize: 18; color: theme.color3 }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 1
                                Text { text: quranPlayer.reciterName(); font.pixelSize: 10; color: theme.muted }
                                Text {
                                    text: quranPlayer.loaded
                                        ? quranPlayer.currentSurah + ". " + quranPlayer.surahName(quranPlayer.currentSurah)
                                        : "Select a surah to play"
                                    font.pixelSize: 13; font.bold: true; font.family: "JetBrains Mono Nerd Font Mono"
                                    color: quranPlayer.playing ? theme.color3 : theme.foreground
                                    elide: Text.ElideRight; Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true; height: 10 }

                    // ── Seek bar ──
                    Item {
                        Layout.fillWidth: true; Layout.preferredHeight: 16

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width; height: 4; radius: 2
                            color: Qt.darker(theme.muted, 1.3)
                            Rectangle {
                                width: quranPlayer.duration > 0 ? (quranPlayer.position / quranPlayer.duration) * parent.width : 0
                                height: parent.height; radius: 2; color: theme.color3
                                Behavior on width { NumberAnimation { duration: 300 } }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: function(mouse) {
                                if (quranPlayer.duration > 0 && quranPlayer.loaded) {
                                    var pct = Math.max(0, Math.min(1, mouse.x / width))
                                    quranPlayer.seekTo(pct * quranPlayer.duration)
                                }
                            }
                        }
                    }

                    // ── Time labels ──
                    RowLayout {
                        Layout.fillWidth: true; Layout.bottomMargin: 10
                        Text { text: quranPlayer.formatTime(quranPlayer.position); font.pixelSize: 10; font.family: "JetBrains Mono Nerd Font Mono"; color: theme.muted }
                        Item { Layout.fillWidth: true }
                        Text { text: quranPlayer.duration > 0 ? quranPlayer.formatTime(quranPlayer.duration) : ""; font.pixelSize: 10; font.family: "JetBrains Mono Nerd Font Mono"; color: theme.muted }
                    }

                    // ── Transport controls ──
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 36; spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 44; Layout.preferredHeight: 36; radius: barSettings.barRadius
                            color: sBackArea.containsMouse ? Qt.darker(theme.muted, 1.3) : Qt.darker(theme.background, 1.2)
                            Text { anchors.centerIn: parent; text: "\u23EE"; font.pixelSize: 18; color: theme.foreground }
                            MouseArea { id: sBackArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: quranPlayer.seekBackward() }
                        }
                        Rectangle {
                            Layout.preferredWidth: 44; Layout.preferredHeight: 36; radius: barSettings.barRadius
                            color: prevArea.containsMouse ? Qt.darker(theme.color3, 1.3) : "transparent"
                            border { width: barSettings.borderThickness; color: theme.color3 }
                            Text { anchors.centerIn: parent; text: "\u23EE"; font.pixelSize: 18; color: theme.color3 }
                            MouseArea { id: prevArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: quranPlayer.prev() }
                        }
                        Rectangle {
                            Layout.preferredWidth: 52; Layout.preferredHeight: 40; radius: barSettings.barRadius
                            color: playArea.containsMouse ? Qt.lighter(theme.color3, 1.2) : theme.color3
                            Text { anchors.centerIn: parent; text: quranPlayer.playing ? "\u23F8" : "\u25B6"; font.pixelSize: 20; color: theme.background }
                            MouseArea {
                                id: playArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: { if (!quranPlayer.loaded) quranPlayer.playSurah(1); else quranPlayer.togglePause() }
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: 44; Layout.preferredHeight: 36; radius: barSettings.barRadius
                            color: nextArea.containsMouse ? Qt.darker(theme.color3, 1.3) : "transparent"
                            border { width: barSettings.borderThickness; color: theme.color3 }
                            Text { anchors.centerIn: parent; text: "\u23ED"; font.pixelSize: 18; color: theme.color3 }
                            MouseArea { id: nextArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: quranPlayer.next() }
                        }
                        Rectangle {
                            Layout.preferredWidth: 44; Layout.preferredHeight: 36; radius: barSettings.barRadius
                            color: sFwdArea.containsMouse ? Qt.darker(theme.muted, 1.3) : Qt.darker(theme.background, 1.2)
                            Text { anchors.centerIn: parent; text: "\u23ED"; font.pixelSize: 18; color: theme.foreground }
                            MouseArea { id: sFwdArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: quranPlayer.seekForward() }
                        }
                        Rectangle {
                            Layout.preferredWidth: 44; Layout.preferredHeight: 36; radius: barSettings.barRadius
                            color: stopArea.containsMouse ? Qt.darker(theme.color1, 1.3) : "transparent"
                            border { width: barSettings.borderThickness; color: theme.color1 }
                            Text { anchors.centerIn: parent; text: "\u23F9"; font.pixelSize: 18; color: theme.color1 }
                            MouseArea { id: stopArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: quranPlayer.stop() }
                        }
                    }

                    Item { Layout.fillWidth: true; height: 4 }
                    Rectangle { Layout.fillWidth: true; Layout.bottomMargin: 8; height: 1; color: theme.muted; opacity: 0.4 }

                    // ── Reciter toggle ──
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 32; radius: barSettings.barRadius
                        color: reciterToggleArea.containsMouse ? Qt.darker(theme.muted, 1.2) : theme.muted

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                            Text { text: "Reciter"; font.pixelSize: 11; font.bold: true; color: theme.foreground }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: quranPlayer.reciterName()
                                font.pixelSize: 10; color: theme.color3; elide: Text.ElideRight; Layout.maximumWidth: 200
                            }
                            Text {
                                text: popupRoot.showReciters ? "\u25B2" : "\u25BC"
                                font.pixelSize: 10; color: theme.foreground
                            }
                        }
                        MouseArea {
                            id: reciterToggleArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: popupRoot.showReciters = !popupRoot.showReciters
                        }
                    }

                    Item { Layout.fillWidth: true; height: 8 }

                    // ── Scrollable: Reciter list + Surah list ──
                    Flickable {
                        id: flick
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentHeight: innerCol.implicitHeight
                        clip: true
                        flickableDirection: Flickable.VerticalFlick
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: innerCol
                            width: flick.width
                            spacing: 0

                            // Reciter list (collapsible)
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                visible: popupRoot.showReciters

                                Repeater {
                                    model: ["Hafs", "Mujawwad", "Qalon", "Warsh"]

                                    ColumnLayout {
                                        required property string modelData
                                        property string styleName: modelData
                                        property bool groupExpanded: false
                                        property var styleReciters: {
                                            var result = []
                                            for (var i = 0; i < quranPlayer.reciters.length; i++) {
                                                if (quranPlayer.reciters[i].style === styleName)
                                                    result.push(i)
                                            }
                                            return result
                                        }

                                        Layout.fillWidth: true; spacing: 0

                                        Rectangle {
                                            Layout.fillWidth: true; Layout.preferredHeight: 26; radius: 4
                                            color: styleHeaderArea.containsMouse ? Qt.darker(theme.muted, 1.2) : "transparent"

                                            RowLayout {
                                                anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                                Text { text: styleName + " (" + styleReciters.length + ")"; font.pixelSize: 10; font.bold: true; color: theme.color3 }
                                                Item { Layout.fillWidth: true }
                                                Text { text: groupExpanded ? "\u25B2" : "\u25BC"; font.pixelSize: 8; color: theme.muted }
                                            }
                                            MouseArea {
                                                id: styleHeaderArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: groupExpanded = !groupExpanded
                                            }
                                        }

                                        Repeater {
                                            model: groupExpanded ? styleReciters : []

                                            Rectangle {
                                                required property var modelData
                                                property int reciterIdx: modelData
                                                width: innerCol.width; height: 26; radius: 4
                                                color: reciterIdx === barSettings.selectedReciter
                                                    ? Qt.darker(theme.color3, 1.5)
                                                    : reciterItemArea.containsMouse ? Qt.darker(theme.background, 1.3) : "transparent"

                                                RowLayout {
                                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 8
                                                    Text {
                                                        text: quranPlayer.reciters[reciterIdx].name
                                        font.pixelSize: barSettings.translationFontSize
                                                        color: reciterIdx === barSettings.selectedReciter ? theme.color3 : theme.foreground
                                                        elide: Text.ElideRight; Layout.fillWidth: true
                                                    }
                                                    Text {
                                                        visible: reciterIdx === barSettings.selectedReciter
                                                        text: "\u2713"; font.pixelSize: 12; color: theme.color3
                                                    }
                                                }
                                                MouseArea {
                                                    id: reciterItemArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    onClicked: quranPlayer.selectReciter(reciterIdx)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true; height: 8 }

                            // Surahs toggle
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 26; radius: 4
                                color: surahsToggleArea.containsMouse ? Qt.darker(theme.muted, 1.2) : "transparent"

                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                    Text { text: "Surahs (114)"; font.pixelSize: 10; font.bold: true; color: theme.color3 }
                                    Item { Layout.fillWidth: true }
                                    Text { text: popupRoot.showSurahs ? "\u25B2" : "\u25BC"; font.pixelSize: 8; color: theme.muted }
                                }
                                MouseArea {
                                    id: surahsToggleArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: popupRoot.showSurahs = !popupRoot.showSurahs
                                }
                            }

                            // Surah list
                            Repeater {
                                model: popupRoot.showSurahs ? quranPlayer.surahs : []

                                Rectangle {
                                    required property var modelData
                                    width: innerCol.width; height: 30; radius: 4
                                    color: modelData.n === quranPlayer.currentSurah
                                        ? Qt.darker(theme.color3, 1.5)
                                        : surahArea.containsMouse ? Qt.darker(theme.background, 1.3) : "transparent"

                                    RowLayout {
                                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                                        Text {
                                            text: String(modelData.n).padStart(3, "0")
                                            font.pixelSize: 11; font.family: "JetBrains Mono Nerd Font Mono"; font.bold: true
                                            color: modelData.n === quranPlayer.currentSurah ? theme.color3 : theme.muted
                                            Layout.preferredWidth: 32
                                        }
                                        Text { text: modelData.name; font.pixelSize: 12; color: theme.foreground; Layout.fillWidth: true; elide: Text.ElideRight }
                                        Text { text: modelData.verses + " ayat"; font.pixelSize: 10; font.family: "JetBrains Mono Nerd Font Mono"; color: theme.muted }
                                        Text {
                                            visible: modelData.n === quranPlayer.currentSurah && quranPlayer.playing
                                            text: "\u266B"; font.pixelSize: 12; color: theme.color3
                                        }
                                    }
                                    MouseArea { id: surahArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: quranPlayer.playSurah(modelData.n) }
                                }
                            }
                        }
                    }
                }

                // ══════════════════════════════════════════════════════════════
                // Divider
                // ══════════════════════════════════════════════════════════════
                Rectangle {
                    visible: popupRoot.showText
                    Layout.fillHeight: true
                    width: 1
                    color: theme.muted; opacity: 0.4
                }

                // ══════════════════════════════════════════════════════════════
                // Right panel: Quran text
                // ══════════════════════════════════════════════════════════════
                ColumnLayout {
                    visible: popupRoot.showText
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 380
                    Layout.margins: 16
                    spacing: 0

                    // ── Text panel header (fixed) ──
                    RowLayout {
                        Layout.fillWidth: true; Layout.bottomMargin: 8

                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: quranPlayer.currentSurah > 0
                                    ? quranPlayer.currentSurah + ". " + quranPlayer.surahName(quranPlayer.currentSurah)
                                    : "Select a surah"
                                font.pixelSize: 13; font.bold: true
                                color: theme.color3; elide: Text.ElideRight
                            }
                            Text {
                                visible: quranText.loading
                                text: "Loading..."; font.pixelSize: 10; color: theme.muted
                            }
                            Text {
                                visible: quranText.error !== ""
                                text: quranText.error; font.pixelSize: 10; color: theme.color1
                            }
                        }

                        // Translation toggle
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            width: 24; height: 16; radius: 8
                            color: quranText.showTranslation ? theme.color3 : Qt.darker(theme.muted, 1.3)
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                x: quranText.showTranslation ? parent.width - width - 2 : 2
                                width: 12; height: 12; radius: 6; color: theme.background
                                Behavior on x { NumberAnimation { duration: 120 } }
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: quranText.showTranslation = !quranText.showTranslation }
                        }
                        Text { text: "Tr"; font.pixelSize: 9; color: theme.muted; Layout.rightMargin: 4 }

                        Item { Layout.fillWidth: true }

                        // Cog settings (centered)
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            width: 24; height: 24; radius: 12
                            color: cogBtnArea.containsMouse ? Qt.darker(theme.muted, 1.3) : (popupRoot.showCogSettings ? theme.color3 : theme.muted)
                            Text { anchors.centerIn: parent; text: "\u2699"; font.pixelSize: 12; color: popupRoot.showCogSettings ? theme.background : theme.foreground }
                            MouseArea {
                                id: cogBtnArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: popupRoot.showCogSettings = !popupRoot.showCogSettings
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Close text panel
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            width: 24; height: 24; radius: 12
                            color: closeTextBtn.containsMouse ? Qt.darker(theme.muted, 1.3) : theme.muted
                            Text { anchors.centerIn: parent; text: "\u2715"; font.pixelSize: 12; color: theme.foreground }
                            MouseArea {
                                id: closeTextBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: popupRoot.showText = false
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.bottomMargin: 8; height: 1; color: theme.muted; opacity: 0.4 }

                    // ── Scrollable content below header ──
                    Flickable {
                        id: textFlick
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentHeight: textInnerCol.implicitHeight
                        clip: true
                        flickableDirection: Flickable.VerticalFlick
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: textInnerCol
                            width: textFlick.width
                            spacing: 0

                            // ══════════════════════════════════════════════
                            // Cog Settings Panel (collapsible)
                            // ══════════════════════════════════════════════
                            ColumnLayout {
                                visible: popupRoot.showCogSettings
                                Layout.fillWidth: true; Layout.bottomMargin: 8; spacing: 0

                                // ── Translations Group ──
                                Rectangle {
                                    Layout.fillWidth: true; Layout.preferredHeight: 28; radius: 4
                                    color: transGroupBtn.containsMouse ? Qt.darker(theme.muted, 1.2) : "transparent"
                                    RowLayout {
                                        anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                        Text { text: "Translations"; font.pixelSize: 10; font.bold: true; color: theme.color3 }
                                        Text { text: quranText.translationName(); font.pixelSize: 9; color: theme.muted; Layout.fillWidth: true; elide: Text.ElideRight }
                                        Text { text: popupRoot.showTransGroup ? "\u25B2" : "\u25BC"; font.pixelSize: 8; color: theme.muted }
                                    }
                                    MouseArea {
                                        id: transGroupBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: popupRoot.showTransGroup = !popupRoot.showTransGroup
                                    }
                                }

                                ColumnLayout {
                                    visible: popupRoot.showTransGroup
                                    Layout.fillWidth: true; Layout.bottomMargin: 8; spacing: 2

                                    Repeater {
                                        model: quranText.translations

                                        Rectangle {
                                            required property var modelData
                                            property bool selected: modelData.id === quranText.selectedTranslation
                                            Layout.fillWidth: true; Layout.preferredHeight: 28; radius: 4
                                            color: selected ? Qt.darker(theme.color3, 1.5)
                                                : transItemArea.containsMouse ? Qt.darker(theme.background, 1.3) : "transparent"

                                            RowLayout {
                                                anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                                Text {
                                                    text: modelData.name
                                                    font.pixelSize: 10
                                                    color: selected ? theme.color3 : theme.foreground
                                                    elide: Text.ElideRight; Layout.fillWidth: true
                                                }
                                                Text {
                                                    text: modelData.lang
                                                    font.pixelSize: 8; color: theme.muted
                                                }
                                                Text {
                                                    visible: selected
                                                    text: "\u2713"; font.pixelSize: 11; color: theme.color3
                                                }
                                            }
                                            MouseArea {
                                                id: transItemArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    quranText.changeTranslation(modelData.id)
                                                    popupRoot.showTransGroup = false
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle { Layout.fillWidth: true; height: 1; color: theme.muted; opacity: 0.3; Layout.bottomMargin: 4 }

                                // ── Font Settings Group ──
                                Rectangle {
                                    Layout.fillWidth: true; Layout.preferredHeight: 28; radius: 4
                                    color: fontGroupBtn.containsMouse ? Qt.darker(theme.muted, 1.2) : "transparent"
                                    RowLayout {
                                        anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                        Text { text: "Font Settings"; font.pixelSize: 10; font.bold: true; color: theme.color3 }
                                        Text { text: barSettings.arabicFont; font.pixelSize: 9; color: theme.muted; Layout.fillWidth: true; elide: Text.ElideRight }
                                        Text { text: popupRoot.showFontGroup ? "\u25B2" : "\u25BC"; font.pixelSize: 8; color: theme.muted }
                                    }
                                    MouseArea {
                                        id: fontGroupBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: popupRoot.showFontGroup = !popupRoot.showFontGroup
                                    }
                                }

                                ColumnLayout {
                                    visible: popupRoot.showFontGroup
                                    Layout.fillWidth: true; Layout.bottomMargin: 8; spacing: 6

                                    // Preview text
                                    Rectangle {
                                        Layout.fillWidth: true; Layout.preferredHeight: previewCol.implicitHeight + 20; radius: 6
                                        color: Qt.darker(theme.background, 1.2)
                                        clip: true
                                        ColumnLayout {
                                            id: previewCol
                                            anchors.fill: parent; anchors.margins: 10; spacing: 4
                                            Text {
                                                Layout.fillWidth: true
                                                text: "<div dir=\"rtl\">\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064E\u0647\u0650 \u0627\u0644\u0631\u0651\u064E\u062D\u0652\u0645\u064E\u0646\u0650 \u0627\u0644\u0631\u0651\u064E\u062D\u0650\u064A\u0645\u0650</div>"
                                                textFormat: Text.RichText
                                                font.pixelSize: barSettings.arabicFontSize
                                                font.family: barSettings.arabicFont
                                                font.weight: barSettings.arabicBold ? Font.Bold : Font.Normal
                                                color: theme.foreground
                                                horizontalAlignment: Text.AlignRight
                                                wrapMode: Text.WordWrap
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: quranText.showTranslation ? "In the name of Allah, the Entirely Merciful, the Especially Merciful." : ""
                                                visible: quranText.showTranslation
                                                font.pixelSize: barSettings.translationFontSize
                                                color: theme.muted
                                                wrapMode: Text.WordWrap
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }
                                    }

                                    // Arabic font picker
                                    Text { text: "Arabic Font"; font.pixelSize: 9; color: theme.muted; Layout.topMargin: 4 }
                                    Repeater {
                                        model: [
                                            "Noto Naskh Arabic",
                                            "Noto Kufi Arabic",
                                            "Noto Sans Arabic",
                                            "Noto Sans Arabic UI",
                                            "Noto Naskh Arabic UI",
                                            "Al Majeed Quranic Font",
                                            "KFGQPC Uthmanic Script HAFS",
                                            "Scheherazade New",
                                            "Lateef",
                                            "Cairo",
                                            "Mada",
                                            "Sahel"
                                        ]
                                        Rectangle {
                                            required property string modelData
                                            property bool isSelected: modelData === barSettings.arabicFont
                                            Layout.fillWidth: true; Layout.preferredHeight: 26; radius: 4
                                            color: isSelected ? Qt.darker(theme.color3, 1.5)
                                                : fontItemArea.containsMouse ? Qt.darker(theme.background, 1.3) : "transparent"
                                            RowLayout {
                                                anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                                Text {
                                                    text: modelData
                                                    font.pixelSize: 10; font.family: modelData
                                                    color: isSelected ? theme.color3 : theme.foreground
                                                    elide: Text.ElideRight; Layout.fillWidth: true
                                                }
                                                Text { visible: isSelected; text: "\u2713"; font.pixelSize: 11; color: theme.color3 }
                                            }
                                            MouseArea {
                                                id: fontItemArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: barSettings.arabicFont = modelData
                                            }
                                        }
                                    }

                                    Item { Layout.fillWidth: true; height: 4 }

                                    // Arabic font size
                                    RowLayout {
                                        Layout.fillWidth: true; spacing: 8
                                        Text { text: "Arabic"; font.pixelSize: 9; color: theme.muted; Layout.preferredWidth: 46 }
                                        Text { text: Math.round(barSettings.arabicFontSize); font.pixelSize: 9; color: theme.color3; Layout.preferredWidth: 20 }
                                        Rectangle {
                                            Layout.fillWidth: true; Layout.preferredHeight: 16; color: "transparent"
                                            property real lo: 14; property real hi: 32
                                            function pct() { return (barSettings.arabicFontSize - lo) / (hi - lo) }
                                            Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 3; radius: 1; color: Qt.darker(theme.muted, 1.3)
                                                Rectangle { width: parent.parent.pct() * parent.width; height: parent.height; radius: 1; color: theme.color3 }
                                            }
                                            Rectangle { x: parent.pct() * (parent.width - 12); anchors.verticalCenter: parent.verticalCenter; width: 12; height: 12; radius: 6; color: theme.color3 }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onPressed: function(mouse) { updateArabicSize(mouse.x) }
                                                onPositionChanged: function(mouse) { if (pressed) updateArabicSize(mouse.x) }
                                                function updateArabicSize(mx) {
                                                    var clamped = Math.max(0, Math.min(parent.width - 12, mx - 6))
                                                    barSettings.arabicFontSize = Math.round((clamped / (parent.width - 12) * (parent.hi - parent.lo) + parent.lo) * 2) / 2
                                                }
                                            }
                                        }
                                    }

                                    // Translation font size
                                    RowLayout {
                                        Layout.fillWidth: true; spacing: 8
                                        Text { text: "Trans"; font.pixelSize: 9; color: theme.muted; Layout.preferredWidth: 46 }
                                        Text { text: Math.round(barSettings.translationFontSize); font.pixelSize: 9; color: theme.color3; Layout.preferredWidth: 20 }
                                        Rectangle {
                                            Layout.fillWidth: true; Layout.preferredHeight: 16; color: "transparent"
                                            property real lo: 8; property real hi: 18
                                            function pct() { return (barSettings.translationFontSize - lo) / (hi - lo) }
                                            Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 3; radius: 1; color: Qt.darker(theme.muted, 1.3)
                                                Rectangle { width: parent.parent.pct() * parent.width; height: parent.height; radius: 1; color: theme.color3 }
                                            }
                                            Rectangle { x: parent.pct() * (parent.width - 12); anchors.verticalCenter: parent.verticalCenter; width: 12; height: 12; radius: 6; color: theme.color3 }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onPressed: function(mouse) { updateTransSize(mouse.x) }
                                                onPositionChanged: function(mouse) { if (pressed) updateTransSize(mouse.x) }
                                                function updateTransSize(mx) {
                                                    var clamped = Math.max(0, Math.min(parent.width - 12, mx - 6))
                                                    barSettings.translationFontSize = Math.round((clamped / (parent.width - 12) * (parent.hi - parent.lo) + parent.lo) * 2) / 2
                                                }
                                            }
                                        }
                                    }

                                    Item { Layout.fillWidth: true; height: 2 }

                                    // Bold / Normal toggle
                                    RowLayout {
                                        Layout.fillWidth: true; spacing: 8
                                        Text { text: "Weight"; font.pixelSize: 9; color: theme.muted; Layout.preferredWidth: 46 }
                                        Rectangle {
                                            Layout.preferredWidth: 56; Layout.preferredHeight: 20; radius: 10
                                            color: !barSettings.arabicBold ? theme.color3 : Qt.darker(theme.muted, 1.3)
                                            Text { anchors.centerIn: parent; text: "Normal"; font.pixelSize: 9; color: theme.background; font.bold: true }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: barSettings.arabicBold = false }
                                        }
                                        Rectangle {
                                            Layout.preferredWidth: 44; Layout.preferredHeight: 20; radius: 10
                                            color: barSettings.arabicBold ? theme.color3 : Qt.darker(theme.muted, 1.3)
                                            Text { anchors.centerIn: parent; text: "Bold"; font.pixelSize: 9; color: theme.background; font.bold: true }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: barSettings.arabicBold = true }
                                        }
                                    }
                                }
                            }

                            // ══════════════════════════════════════════════
                            // Verses
                            // ══════════════════════════════════════════════
                            Repeater {
                                model: quranText.verses

                                ColumnLayout {
                                    required property var modelData
                                    property int verseNum: modelData.n
                                    Layout.fillWidth: true; spacing: 4

                                    Item { Layout.fillWidth: true; height: 12 }

                                    // Verse number badge
                                    Rectangle {
                                        Layout.alignment: Qt.AlignLeft
                                        Layout.preferredWidth: 28; Layout.preferredHeight: 20; radius: 10
                                        color: theme.color3; opacity: 0.15
                                        Text {
                                            anchors.centerIn: parent
                                            text: verseNum
                                            font.pixelSize: 9; font.family: "JetBrains Mono Nerd Font Mono"
                                            font.bold: true; color: theme.color3
                                        }
                                    }

                                    // Arabic text
                                    Text {
                                        Layout.fillWidth: true
                                        text: "<div dir=\"rtl\">" + modelData.arabic + "</div>"
                                        textFormat: Text.RichText
                                        font.pixelSize: barSettings.arabicFontSize
                                        font.family: barSettings.arabicFont
                                        font.weight: barSettings.arabicBold ? Font.Bold : Font.Normal
                                        color: theme.foreground
                                        wrapMode: Text.WordWrap
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    // Translation text
                                    Text {
                                        visible: quranText.showTranslation && modelData.translation !== ""
                                        Layout.fillWidth: true
                                        text: modelData.translation
                                        font.pixelSize: barSettings.translationFontSize
                                        color: theme.muted
                                        wrapMode: Text.WordWrap
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Item { Layout.fillWidth: true; height: 8 }
                                    Rectangle { Layout.fillWidth: true; height: 1; color: theme.muted; opacity: 0.15 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
