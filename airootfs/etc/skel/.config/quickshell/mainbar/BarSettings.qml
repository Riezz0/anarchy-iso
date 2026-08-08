import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Item {
    id: settingsRoot

    property int barRadius: 5
    property int hyprlandRadius: 5
    property int borderThickness: 2
    property int hyprlandBorderThickness: 2
    property real barOpacity: 0.95
    property real hyprlandWindowOpacity: 1.0
    property string barMonitor: "all"
    property string barPosition: "top"
    property int selectedReciter: 0
    property bool autoNext: false
    property string arabicFont: "Noto Naskh Arabic"
    property real arabicFontSize: 20
    property real translationFontSize: 11
    property bool arabicBold: false
    property bool nightlightEnabled: false
    property bool _loading: false

    readonly property string configPath:
        StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/quickshell/bar-settings.json"

    FileView {
        id: settingsFile
        path: settingsRoot.configPath
        watchChanges: false
        onLoaded: {
            try {
                _loading = true
                const data = JSON.parse(settingsFile.text())
                if (data && data.barRadius !== undefined) {
                    settingsRoot.barRadius = data.barRadius
                }
                if (data && data.hyprlandRadius !== undefined) {
                    settingsRoot.hyprlandRadius = data.hyprlandRadius
                }
                if (data && data.borderThickness !== undefined) {
                    settingsRoot.borderThickness = data.borderThickness
                }
                if (data && data.hyprlandBorderThickness !== undefined) {
                    settingsRoot.hyprlandBorderThickness = data.hyprlandBorderThickness
                }
                if (data && data.barOpacity !== undefined) {
                    settingsRoot.barOpacity = data.barOpacity
                }
                if (data && data.hyprlandWindowOpacity !== undefined) {
                    settingsRoot.hyprlandWindowOpacity = data.hyprlandWindowOpacity
                }
                if (data && data.barMonitor !== undefined) {
                    settingsRoot.barMonitor = data.barMonitor
                }
                if (data && data.barPosition !== undefined) {
                    settingsRoot.barPosition = data.barPosition
                }
                if (data && data.selectedReciter !== undefined) {
                    settingsRoot.selectedReciter = data.selectedReciter
                }
                if (data && data.autoNext !== undefined) {
                    settingsRoot.autoNext = data.autoNext
                }
                if (data && data.arabicFont !== undefined) {
                    settingsRoot.arabicFont = data.arabicFont
                }
                if (data && data.arabicFontSize !== undefined) {
                    settingsRoot.arabicFontSize = data.arabicFontSize
                }
                if (data && data.translationFontSize !== undefined) {
                    settingsRoot.translationFontSize = data.translationFontSize
                }
                if (data && data.arabicBold !== undefined) {
                    settingsRoot.arabicBold = data.arabicBold
                }
                if (data && data.nightlightEnabled !== undefined) {
                    settingsRoot.nightlightEnabled = data.nightlightEnabled
                }
                _loading = false
                applyHyprlandRadius(settingsRoot.hyprlandRadius)
                applyHyprlandBorderThickness(settingsRoot.hyprlandBorderThickness)
                applyHyprlandWindowOpacity(settingsRoot.hyprlandWindowOpacity)
                if (settingsRoot.nightlightEnabled) {
                    nightlightToggleProc.command = ["nohup", "setsid", "bash", "-c",
                        "hyprsunset -t 4000 </dev/null >/dev/null 2>&1"]
                    nightlightToggleProc.running = true
                }
            } catch (e) {
                _loading = false
            }
        }
    }

    Process {
        id: settingsWriter
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: hyprctlProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: hyprctlBorderProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: sedBorderProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: hyprctlOpacityProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: sedOpacityProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: nightlightToggleProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: nightlightStopProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Component.onCompleted: {
        settingsFile.reload()
    }

    function setBarRadius(r) {
        settingsRoot.barRadius = r
    }

    function setHyprlandRadius(r) {
        settingsRoot.hyprlandRadius = r
        applyHyprlandRadius(r)
    }

    function setHyprlandWindowOpacity(o) {
        settingsRoot.hyprlandWindowOpacity = o
        applyHyprlandWindowOpacity(o)
    }

    function setBarOpacity(o) {
        settingsRoot.barOpacity = o
    }

    function setBorderThickness(t) {
        settingsRoot.borderThickness = t
    }

    function setHyprlandBorderThickness(t) {
        settingsRoot.hyprlandBorderThickness = t
        applyHyprlandBorderThickness(t)
    }

    function setBarMonitor(m) {
        settingsRoot.barMonitor = m
    }

    function setBarPosition(pos) {
        settingsRoot.barPosition = pos
    }

    function setNightlight(enabled) {
        settingsRoot.nightlightEnabled = enabled
        if (enabled) {
            nightlightToggleProc.command = ["nohup", "setsid", "bash", "-c",
                "hyprsunset -t 4000 </dev/null >/dev/null 2>&1"]
            nightlightToggleProc.running = true
        } else {
            nightlightStopProc.command = ["pkill", "hyprsunset"]
            nightlightStopProc.running = true
        }
    }

    function applyHyprlandRadius(r) {
        hyprctlProc.command = ["hyprctl", "eval", "hl.config({ decoration = { rounding = " + r + " } })"]
        hyprctlProc.running = true
        saveLuaConfig(r)
    }

    function applyHyprlandBorderThickness(t) {
        hyprctlBorderProc.command = ["hyprctl", "eval", "hl.config({ general = { border_size = " + t + " } })"]
        hyprctlBorderProc.running = true
        saveLuaBorderConfig(t)
    }

    function applyHyprlandWindowOpacity(o) {
        hyprctlOpacityProc.command = ["hyprctl", "eval", "hl.config({ decoration = { active_opacity = " + o + ", inactive_opacity = " + o + " } })"]
        hyprctlOpacityProc.running = true
        saveLuaOpacityConfig(o)
    }

    function saveLuaOpacityConfig(o) {
        const luaPath = StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/hypr/modules/look.lua"
        const cmd = "sed -i 's/active_opacity\\s*=\\s*[0-9.]*\\+/active_opacity    = " + o + "/g' '" + luaPath + "' && " +
                    "sed -i 's/inactive_opacity\\s*=\\s*[0-9.]*\\+/inactive_opacity  = " + o + "/g' '" + luaPath + "'"
        sedOpacityProc.command = ["sh", "-c", cmd]
        sedOpacityProc.running = true
    }

    function saveLuaBorderConfig(t) {
        const luaPath = StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/hypr/modules/look.lua"
        const override = "hl.config({ general = { border_size = " + t + " } })"
        const cmd = "if grep -q 'border_size' '" + luaPath + "'; then " +
                    "sed -i 's/border_size\\s*=\\s*[0-9]\\+/border_size = " + t + "/g' '" + luaPath + "'; " +
                    "else echo '" + override + "' >> '" + luaPath + "'; fi"
        sedBorderProc.command = ["sh", "-c", cmd]
        sedBorderProc.running = true
    }

    function saveLuaConfig(r) {
        const luaPath = StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/hypr/modules/look.lua"
        const override = "hl.config({ decoration = { rounding = " + r + ", rounding_power = " + r + " } })"
        const cmd = "if grep -q 'rounding' '" + luaPath + "'; then " +
                    "sed -i 's/rounding\\s*=\\s*[0-9]\\+/rounding = " + r + "/g' '" + luaPath + "' && " +
                    "sed -i 's/rounding_power\\s*=\\s*[0-9]\\+/rounding_power = " + r + "/g' '" + luaPath + "'; " +
                    "else echo '" + override + "' >> '" + luaPath + "'; fi"
        hyprctlProc.command = ["sh", "-c", cmd]
        hyprctlProc.running = true
    }

    function save() {
        const json = JSON.stringify({
            barRadius: settingsRoot.barRadius,
            hyprlandRadius: settingsRoot.hyprlandRadius,
            borderThickness: settingsRoot.borderThickness,
            hyprlandBorderThickness: settingsRoot.hyprlandBorderThickness,
            barOpacity: settingsRoot.barOpacity,
            hyprlandWindowOpacity: settingsRoot.hyprlandWindowOpacity,
            barMonitor: settingsRoot.barMonitor,
            barPosition: settingsRoot.barPosition,
            selectedReciter: settingsRoot.selectedReciter,
            autoNext: settingsRoot.autoNext,
            arabicFont: settingsRoot.arabicFont,
            arabicFontSize: settingsRoot.arabicFontSize,
            translationFontSize: settingsRoot.translationFontSize,
            arabicBold: settingsRoot.arabicBold,
            nightlightEnabled: settingsRoot.nightlightEnabled
        })
        settingsWriter.command = ["sh", "-c",
            "mkdir -p ~/.config/quickshell && cat > ~/.config/quickshell/bar-settings.json << 'ENDOFFILE'\n" + json + "\nENDOFFILE"]
        settingsWriter.running = true
    }

    function monitorList() {
        var list = ["all"]
        for (var i = 0; i < Quickshell.screens.length; i++) {
            var name = Quickshell.screens[i].name
            if (name && name !== "")
                list.push(name)
        }
        return list
    }

    function monitorDisplayName(m) {
        if (m === "all") return "All Monitors"
        for (var i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === m) {
                var s = Quickshell.screens[i]
                return s.name + " (" + s.width + "x" + s.height + ")"
            }
        }
        return m
    }

    function popupScreens() {
        var m = settingsRoot.barMonitor
        if (m === "all") {
            var screens = []
            for (var i = 0; i < Quickshell.screens.length; i++)
                screens.push(Quickshell.screens[i])
            return screens
        }
        for (var i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === m)
                return [Quickshell.screens[i]]
        }
        return [Quickshell.screens[0]]
    }

    onBarMonitorChanged: {
        if (!_loading) save()
    }

    onBarRadiusChanged: {
        if (!_loading) save()
    }

    onHyprlandRadiusChanged: {
        if (!_loading) save()
    }

    onBorderThicknessChanged: {
        if (!_loading) save()
    }

    onHyprlandBorderThicknessChanged: {
        if (!_loading) save()
    }

    onBarOpacityChanged: {
        if (!_loading) save()
    }

    onHyprlandWindowOpacityChanged: {
        if (!_loading) save()
    }

    onBarPositionChanged: {
        if (!_loading) save()
    }

    onSelectedReciterChanged: {
        if (!_loading) save()
    }

    onAutoNextChanged: {
        if (!_loading) save()
    }

    onArabicFontChanged: {
        if (!_loading) save()
    }

    onArabicFontSizeChanged: {
        if (!_loading) save()
    }

    onTranslationFontSizeChanged: {
        if (!_loading) save()
    }

    onArabicBoldChanged: {
        if (!_loading) save()
    }

    onNightlightEnabledChanged: {
        if (!_loading) save()
    }
}
