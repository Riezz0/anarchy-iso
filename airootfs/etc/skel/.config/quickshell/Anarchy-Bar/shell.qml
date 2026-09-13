import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import "Modules"

ShellRoot {
    id: root

    Theme { id: theme }

    property int barRadius: 6
    property real barOpacity: 1.0
    property int barBorderThickness: 0
    property string barPosition: "top"
    property int moduleBorderThickness: 0
    property real popupOpacity: 0.95
    property int popupBorderThickness: 0
    property string workspaceIndicatorStyle: "numbers"
    property int hyprlandBorderThickness: 2
    property real hyprlandActiveOpacity: 0.6
    property real hyprlandInactiveOpacity: 0.2
    property int hyprlandRounding: 10
    property int hyprlandRoundingPower: 10
    property bool hyprlandBlurEnabled: true
    property int hyprlandBlurPasses: 3
    property int hyprlandBlurSize: 20
    property real hyprlandBlurVibrancy: 0.6
    property int hyprlandGapIn: 10
    property int hyprlandGapOut: 10
    property var barMonitors: []
    property int rofiBorderRadius: 5
    property int rofiBorderThickness: 2
    property bool isLoadingSettings: true

    readonly property string settingsPath:
        StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/quickshell/Anarchy-Bar/Settings/bar.json"
    readonly property string hyprlandPatchPath:
        StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/.hypr-themes/patch-look.sh"

    Component.onCompleted: loadSettings()

    function loadSettings() {
        settingsFile.reload()
    }

    function saveSettings() {
        if (isLoadingSettings) return
        var data = {
            "barRadius": barRadius,
            "barOpacity": barOpacity,
            "barBorderThickness": barBorderThickness,
            "barPosition": barPosition,
            "moduleBorderThickness": moduleBorderThickness,
            "popupOpacity": popupOpacity,
            "popupBorderThickness": popupBorderThickness,
            "workspaceIndicatorStyle": workspaceIndicatorStyle,
            "hyprlandBorderThickness": hyprlandBorderThickness,
            "hyprlandActiveOpacity": hyprlandActiveOpacity,
            "hyprlandInactiveOpacity": hyprlandInactiveOpacity,
            "hyprlandRounding": hyprlandRounding,
            "hyprlandRoundingPower": hyprlandRoundingPower,
            "hyprlandBlurEnabled": hyprlandBlurEnabled,
            "hyprlandBlurPasses": hyprlandBlurPasses,
            "hyprlandBlurSize": hyprlandBlurSize,
            "hyprlandBlurVibrancy": hyprlandBlurVibrancy,
            "hyprlandGapIn": hyprlandGapIn,
            "hyprlandGapOut": hyprlandGapOut,
            "barMonitors": barMonitors,
            "rofiBorderRadius": rofiBorderRadius,
            "rofiBorderThickness": rofiBorderThickness
        }
        settingsFile.setText(JSON.stringify(data, null, 2))
    }

    FileView {
        id: settingsFile
        path: root.settingsPath
        watchChanges: true
        onFileChanged: {
            if (!isLoadingSettings) hyprlandPatchTimer.restart()
        }
        onLoaded: {
            if (settingsFile.text().length > 0) {
                try {
                    var data = JSON.parse(settingsFile.text())
                    if (data.barRadius !== undefined) root.barRadius = data.barRadius
                    if (data.barOpacity !== undefined) root.barOpacity = data.barOpacity
                    if (data.barBorderThickness !== undefined) root.barBorderThickness = data.barBorderThickness
                    if (data.barPosition !== undefined) root.barPosition = data.barPosition
                    if (data.moduleBorderThickness !== undefined) root.moduleBorderThickness = data.moduleBorderThickness
                    if (data.popupOpacity !== undefined) root.popupOpacity = data.popupOpacity
                    if (data.popupBorderThickness !== undefined) root.popupBorderThickness = data.popupBorderThickness
                    if (data.workspaceIndicatorStyle !== undefined) root.workspaceIndicatorStyle = data.workspaceIndicatorStyle
                    if (data.hyprlandBorderThickness !== undefined) root.hyprlandBorderThickness = data.hyprlandBorderThickness
                    if (data.hyprlandActiveOpacity !== undefined) root.hyprlandActiveOpacity = data.hyprlandActiveOpacity
                    if (data.hyprlandInactiveOpacity !== undefined) root.hyprlandInactiveOpacity = data.hyprlandInactiveOpacity
                    if (data.hyprlandRounding !== undefined) root.hyprlandRounding = data.hyprlandRounding
                    if (data.hyprlandRoundingPower !== undefined) root.hyprlandRoundingPower = data.hyprlandRoundingPower
                    if (data.hyprlandBlurEnabled !== undefined) root.hyprlandBlurEnabled = data.hyprlandBlurEnabled
                    if (data.hyprlandBlurPasses !== undefined) root.hyprlandBlurPasses = data.hyprlandBlurPasses
                    if (data.hyprlandBlurSize !== undefined) root.hyprlandBlurSize = data.hyprlandBlurSize
                    if (data.hyprlandBlurVibrancy !== undefined) root.hyprlandBlurVibrancy = data.hyprlandBlurVibrancy
                    if (data.hyprlandGapIn !== undefined) root.hyprlandGapIn = data.hyprlandGapIn
                    if (data.hyprlandGapOut !== undefined) root.hyprlandGapOut = data.hyprlandGapOut
                    if (data.barMonitors !== undefined) root.barMonitors = data.barMonitors
                    if (data.rofiBorderRadius !== undefined) root.rofiBorderRadius = data.rofiBorderRadius
                    if (data.rofiBorderThickness !== undefined) root.rofiBorderThickness = data.rofiBorderThickness
                } catch (e) {
                    console.warn("Anarchy-Bar: failed to parse settings:", e)
                }
            }
            hyprlandPatchTimer.restart()
            isLoadingSettings = false
        }
    }

    onBarRadiusChanged: saveSettings()
    onBarOpacityChanged: saveSettings()
    onBarBorderThicknessChanged: saveSettings()
    onBarPositionChanged: saveSettings()
    onModuleBorderThicknessChanged: saveSettings()
    onPopupOpacityChanged: saveSettings()
    onPopupBorderThicknessChanged: saveSettings()
    onWorkspaceIndicatorStyleChanged: saveSettings()
    onHyprlandBorderThicknessChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onHyprlandActiveOpacityChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onHyprlandInactiveOpacityChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onHyprlandRoundingChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onHyprlandRoundingPowerChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onHyprlandBlurEnabledChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onHyprlandBlurPassesChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onHyprlandBlurSizeChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onHyprlandBlurVibrancyChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onHyprlandGapInChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onHyprlandGapOutChanged: {
        saveSettings()
        hyprlandPatchTimer.restart()
    }
    onBarMonitorsChanged: saveSettings()
    onRofiBorderRadiusChanged: {
        saveSettings()
        rofiPatchTimer.restart()
    }
    onRofiBorderThicknessChanged: {
        saveSettings()
        rofiPatchTimer.restart()
    }

    function getMonitorName(monitor) {
        if (monitor && monitor.name) return monitor.name
        return ""
    }

    function isMonitorEnabled(monitor) {
        if (barMonitors.length === 0) return true
        var name = getMonitorName(monitor)
        return barMonitors.indexOf(name) !== -1
    }

    function toggleMonitor(monitor) {
        var name = getMonitorName(monitor)
        var idx = barMonitors.indexOf(name)
        if (idx === -1) {
            barMonitors.push(name)
        } else {
            barMonitors.splice(idx, 1)
        }
        barMonitorsChanged()
    }

    Item {
        id: powerMenu
        property bool isOpen: false
        property var targetScreen: null
        function open(screen) {
            targetScreen = screen
            isOpen = true
        }
        function close() {
            isOpen = false
            targetScreen = null
        }
        function runCmd(cmd) {
            cmdProc.command = ["sh", "-c", cmd]
            cmdProc.running = true
            close()
        }
    }

    Item {
        id: settingsPopup
        property bool isOpen: false
        property var targetScreen: null
        function open(screen) {
            targetScreen = screen
            isOpen = true
        }
        function close() {
            isOpen = false
            targetScreen = null
        }
    }

    Item {
        id: calendarPopup
        property bool isOpen: false
        function open() { isOpen = true }
        function close() { isOpen = false }
    }

    Item {
        id: updatesPopup
        property bool isOpen: false
        function open() { isOpen = true }
        function close() { isOpen = false }
    }

    Item {
        id: infoPopup
        property bool isOpen: false
        function open() { isOpen = true }
        function close() { isOpen = false }
    }

    Item {
        id: salaatPopup
        property bool isOpen: false
        function open() { isOpen = true }
        function close() { isOpen = false }
    }

    Item {
        id: notificationsPopup
        property bool isOpen: false
        function open() { isOpen = true }
        function close() { isOpen = false }
    }

    Item {
        id: keybindsPopup
        property bool isOpen: false
        property string targetScreen: ""
        function open() { isOpen = true }
        function close() {
            isOpen = false
            targetScreen = ""
        }
    }

    Process {
        id: cmdProc
        running: false
    }

    Process {
        id: hyprlandPatchProc
        running: false
    }

    Process {
        id: hyprctlBorderProc
        running: false
    }

    Process {
        id: borderFilesProc
        running: false
    }

    Timer {
        id: hyprlandPatchTimer
        interval: 150
        repeat: false
        onTriggered: {
            var value = root.hyprlandBorderThickness.toString()
            if (hyprctlBorderProc.running)
                hyprctlBorderProc.running = false
            if (borderFilesProc.running)
                borderFilesProc.running = false

            hyprctlBorderProc.command = ["hyprctl", "eval", "hl.config({ general = { border_size = " + value + ", gaps_in = " + root.hyprlandGapIn + ", gaps_out = " + root.hyprlandGapOut + " }, decoration = { active_opacity = " + root.hyprlandActiveOpacity + ", inactive_opacity = " + root.hyprlandInactiveOpacity + ", rounding = " + root.hyprlandRounding + ", rounding_power = " + root.hyprlandRoundingPower + ", blur = { enabled = " + root.hyprlandBlurEnabled + ", passes = " + root.hyprlandBlurPasses + ", size = " + root.hyprlandBlurSize + ", vibrancy = " + root.hyprlandBlurVibrancy + " } } })"]
            hyprctlBorderProc.running = true

            var syncCommand = "for f in $HOME/.config/.hypr-themes/*/hyprlook; do " +
                "[ -f \"$f\" ] || continue; " +
                "sed -i -E 's/gaps_in[[:space:]]*=[[:space:]]*[0-9]+/gaps_in = " + root.hyprlandGapIn + "/g; " +
                "s/gaps_out[[:space:]]*=[[:space:]]*[0-9]+/gaps_out = " + root.hyprlandGapOut + "/g; " +
                "s/border_size[[:space:]]*=[[:space:]]*[0-9]+/border_size = " + value + "/g; " +
                "s/active_opacity[[:space:]]*=[[:space:]]*[0-9.]+/active_opacity = " + root.hyprlandActiveOpacity + "/g; " +
                "s/inactive_opacity[[:space:]]*=[[:space:]]*[0-9.]+/inactive_opacity = " + root.hyprlandInactiveOpacity + "/g; " +
                "s/rounding_power[[:space:]]*=[[:space:]]*[0-9]+/rounding_power = " + root.hyprlandRoundingPower + "/g; " +
                "s/rounding[[:space:]]*=[[:space:]]*[0-9]+/rounding = " + root.hyprlandRounding + "/g' \"$f\"; " +
                "sed -i -E '/blur[[:space:]]*=/,/},},/ { s/enabled[[:space:]]*=[[:space:]]*(true|false)/enabled = " + root.hyprlandBlurEnabled + "/g; s/passes[[:space:]]*=[[:space:]]*[0-9]+/passes = " + root.hyprlandBlurPasses + "/g; s/size[[:space:]]*=[[:space:]]*[0-9]+/size = " + root.hyprlandBlurSize + "/g; s/vibrancy[[:space:]]*=[[:space:]]*[0-9.]+/vibrancy = " + root.hyprlandBlurVibrancy + "/g; }' \"$f\"; done; " +
                "sed -i -E 's/gaps_in[[:space:]]*=[[:space:]]*[0-9]+/gaps_in = " + root.hyprlandGapIn + "/g; " +
                "s/gaps_out[[:space:]]*=[[:space:]]*[0-9]+/gaps_out = " + root.hyprlandGapOut + "/g; " +
                "s/border_size[[:space:]]*=[[:space:]]*[0-9]+/border_size = " + value + "/g; " +
                "s/active_opacity[[:space:]]*=[[:space:]]*[0-9.]+/active_opacity = " + root.hyprlandActiveOpacity + "/g; " +
                "s/inactive_opacity[[:space:]]*=[[:space:]]*[0-9.]+/inactive_opacity = " + root.hyprlandInactiveOpacity + "/g; " +
                "s/rounding_power[[:space:]]*=[[:space:]]*[0-9]+/rounding_power = " + root.hyprlandRoundingPower + "/g; " +
                "s/rounding[[:space:]]*=[[:space:]]*[0-9]+/rounding = " + root.hyprlandRounding + "/g' $HOME/.config/hypr/modules/look.lua; " +
                "sed -i -E '/blur[[:space:]]*=/,/},},/ { s/enabled[[:space:]]*=[[:space:]]*(true|false)/enabled = " + root.hyprlandBlurEnabled + "/g; s/passes[[:space:]]*=[[:space:]]*[0-9]+/passes = " + root.hyprlandBlurPasses + "/g; s/size[[:space:]]*=[[:space:]]*[0-9]+/size = " + root.hyprlandBlurSize + "/g; s/vibrancy[[:space:]]*=[[:space:]]*[0-9.]+/vibrancy = " + root.hyprlandBlurVibrancy + "/g; }' $HOME/.config/hypr/modules/look.lua; " +
                "bash " + root.hyprlandPatchPath + " --sync-all " + value + " " + root.hyprlandActiveOpacity + " " + root.hyprlandInactiveOpacity + " " + root.hyprlandRounding + " " + root.hyprlandRoundingPower + " " + root.hyprlandBlurEnabled + " " + root.hyprlandBlurPasses + " " + root.hyprlandBlurSize + " " + root.hyprlandBlurVibrancy + " " + root.hyprlandGapIn + " " + root.hyprlandGapOut + "; hyprctl reload"
            borderFilesProc.command = ["bash", "-c", syncCommand]
            borderFilesProc.running = true
        }
    }

    Process {
        id: rofiPatchProc
        running: false
        stdout: SplitParser { onRead: line => {} }
        stderr: SplitParser { onRead: line => {} }
    }

    Timer {
        id: rofiPatchTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (rofiPatchProc.running)
                rofiPatchProc.running = false

            var rofiDir = StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().replace(/^file:\/\//, "") + "/.config/rofi/launcher"
            var rofiPath = rofiDir + "/launcher.rasi"
            var patchScript = rofiDir + "/patch-rofi.sh"
            rofiPatchProc.command = ["bash", patchScript, rofiPath, root.rofiBorderRadius.toString(), root.rofiBorderThickness.toString()]
            rofiPatchProc.running = true
        }
    }

    Bar {}
    Updates { id: updates }
    InfoWidget { id: infoWidget }
    Salaat { id: salaat }
    Notifications { id: notifs }
    PowerMenu {}
    SettingsPopup {}
    CalendarPopup {}
    UpdatesPopup {}
    InfoWidgetPopup {}
    SalaatPopup {}
    NotificationsPopup {}
    KeybindsPopup {}
    VolumeOSD { id: volumeOSD }
    ToastPopup {}
}
