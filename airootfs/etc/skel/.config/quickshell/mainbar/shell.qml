//@ pragma UseQApplication
// ═══════════════════════════════════════════════════════════════════════════════
// Shell Root - Quickshell Bar Configuration
// ═══════════════════════════════════════════════════════════════════════════════
// This is the main entry point. It wires together all modular components:
//   - Audio, Calendar, SystemStats, Salaat, Themes, Notifications (data modules)
//   - Theme, Bluetooth, Weather (existing modules)
//   - Bar, VolumePopup, BluetoothPopup, WeatherPopup, CalendarPopup,
//     SystemStatsPopup, NotificationPopup, NotificationsPopup, PowerMenu (UI modules)
//
// Each module is self-contained and can be modified independently.
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import "."

ShellRoot {
    id: root

    // ── Properties ────────────────────────────────────────────────────────────
    property bool   powerMenuOpen:    false
    property bool   volumePopupOpen:  false
    property bool   btPopupOpen:      false
    property bool   weatherPopupOpen: false
    property bool   calendarPopupOpen: false
    property bool   tempPopupOpen:    false
    property bool   salaatPopupOpen:  false
    property bool   themesPopupOpen:  false
    property bool   keybindsPopupOpen: false
    property bool   networkPopupOpen:  false
    property bool   notificationsPopupOpen: false
    property bool   archUpdatePopupOpen: false
    property bool   settingsPopupOpen: false
    property bool   quranPlayerPopupOpen: false
    property bool   sidePanelOpen: false
    property bool   widget2Open: false
    property string clockTime:        Qt.formatDateTime(new Date(), "hh:mm")

    // ── Theme ─────────────────────────────────────────────────────────────────
    Theme { id: theme }

    // ── Data Modules ──────────────────────────────────────────────────────────
    Audio         { id: audio }
    Calendar      { id: calendar }
    SystemStats   { id: stats }
    Notifications { id: notifs }

    // ── Existing Modules ──────────────────────────────────────────────────────
    Bluetooth { id: bt }
    Weather   { id: weather }
    Keyboard  { id: kbd }
    Salaat    { id: salaat }
    Themes    { id: themes }
    Network   { id: net }
    Updates    { id: updates }
    BarSettings   { id: barSettings }
    QuranPlayer   { id: quranPlayer }
    QuranText     { id: quranText }
    UserAvatar    { id: userAvatar }

    // ── Power Menu Functions ──────────────────────────────────────────────────
    function togglePowerMenu() { powerMenuOpen = !powerMenuOpen }
    function closePowerMenu()  { powerMenuOpen = false }

    // ── Side Panel Functions ──────────────────────────────────────────────────
    function toggleSidePanel() {
        if (!sidePanelOpen) widget2Open = false
        sidePanelOpen = !sidePanelOpen
    }
    function closeSidePanel()  { sidePanelOpen = false }

    // ── Widget 2 Functions ───────────────────────────────────────────────────
    function toggleWidget2() {
        if (!widget2Open) sidePanelOpen = false
        widget2Open = !widget2Open
    }
    function closeWidget2()  { widget2Open = false }

    function runCommand(cmd) {
        powerProc.command = ["sh", "-c", cmd]
        powerProc.running = true
        closePowerMenu()
    }

    // ── Power Process ─────────────────────────────────────────────────────────
    Process {
        id:      powerProc
        running: false
    }

    // ── Clock Timer ───────────────────────────────────────────────────────────
    Timer {
        interval:         1000
        running:          true
        repeat:           true
        onTriggered: {
            root.clockTime = Qt.formatDateTime(new Date(), "hh:mm")
        }
    }

    // ── Global Shortcut ───────────────────────────────────────────────────────
    GlobalShortcut {
        name:        "powerMenuToggle"
        description: "Toggle the Quickshell power menu"
        onPressed:   root.togglePowerMenu()
    }

    GlobalShortcut {
        name:        "sidePanelToggle"
        description: "Toggle the Quickshell side panel"
        onPressed:   root.toggleSidePanel()
    }

    // ── Popup Controllers ─────────────────────────────────────────────────────
    // These items provide the visible/close interface that popup components expect.

    Item {
        id: volumePopup
        property bool isOpen: root.volumePopupOpen
        function close() { root.volumePopupOpen = false }
    }

    Item {
        id: btPopup
        property bool isOpen: root.btPopupOpen
        function close() { root.btPopupOpen = false }
    }

    Item {
        id: weatherPopup
        property bool isOpen: root.weatherPopupOpen
        function close() { root.weatherPopupOpen = false }
    }

    Item {
        id: calPopup
        property bool isOpen: root.calendarPopupOpen
        function close() { root.calendarPopupOpen = false }
    }

    Item {
        id: statsPopup
        property bool isOpen: root.tempPopupOpen
        function close() { root.tempPopupOpen = false }
    }

    Item {
        id: salaatPopup
        property bool isOpen: root.salaatPopupOpen
        function close() { root.salaatPopupOpen = false }
    }

    Item {
        id: themesPopup
        property bool isOpen: root.themesPopupOpen
        function close() { root.themesPopupOpen = false }
    }

    Item {
        id: keybindsPopup
        property bool isOpen: root.keybindsPopupOpen
        function close() { root.keybindsPopupOpen = false }
        function loadBinds() { /* Handled by KeybindsPopup component */ }
    }

    Item {
        id: networkPopup
        property bool isOpen: root.networkPopupOpen
        function close() { root.networkPopupOpen = false }
    }

    Item {
        id: notificationsPopup
        property bool isOpen: root.notificationsPopupOpen
        function close() { root.notificationsPopupOpen = false }
    }

    Item {
        id: archUpdatePopup
        property bool isOpen: root.archUpdatePopupOpen
        function close() { root.archUpdatePopupOpen = false }
    }

    Item {
        id: settingsPopup
        property bool isOpen: root.settingsPopupOpen
        function close() { root.settingsPopupOpen = false }
    }

    Item {
        id: quranPlayerPopup
        property bool isOpen: root.quranPlayerPopupOpen
        function close() { root.quranPlayerPopupOpen = false }
    }

    Item {
        id: sidePanel
        property bool isOpen: root.sidePanelOpen
        function close() { root.closeSidePanel() }
    }

    Item {
        id: widget2
        property bool isOpen: root.widget2Open
        function close() { root.closeWidget2() }
    }

    Item {
        id: powerMenu
        property bool isOpen: root.powerMenuOpen
        function close() { root.closePowerMenu() }
        function runCmd(cmd) { root.runCommand(cmd) }
    }

    // ── UI Modules ────────────────────────────────────────────────────────────
    Bar                {}
    VolumePopup        {}
    BluetoothPopup     {}
    WeatherPopup       {}
    CalendarPopup      {}
    SystemStatsPopup   {}
    SalaatPopup        {}
    ThemesPopup        {}
    KeybindsPopup      {}
    NetworkPopup       {}
    NotificationPopup  {}
    NotificationsPopup {}
    UpdatesPopup       {}
    QuranPlayerPopup   {}
    BarSettingsPopup      {}
    VolumeOsd          {}
    PowerMenu          {}
    SidePanel          {}
    Widget2            {}
}
