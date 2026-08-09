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
    property int hyprlandGapIn: 5
    property int hyprlandGapOut: 10
    property bool hyprlandBlurEnabled: true
    property int hyprlandBlurSize: 20
    property int hyprlandBlurPasses: 3
    property real hyprlandBlurVibrancy: 0.1696
    property string barMonitor: "all"
    property string barPosition: "top"
    property int selectedReciter: 0
    property bool autoNext: false
    property string arabicFont: "Noto Naskh Arabic"
    property real arabicFontSize: 20
    property real translationFontSize: 11
    property bool arabicBold: false
    property bool nightlightEnabled: false
    property string workspaceStyle: "numbers"
    property bool _loading: false
    property bool loaded: false

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
                if (data && data.workspaceStyle !== undefined) {
                    settingsRoot.workspaceStyle = data.workspaceStyle
                }
                if (data && data.hyprlandGapIn !== undefined) {
                    settingsRoot.hyprlandGapIn = data.hyprlandGapIn
                }
                if (data && data.hyprlandGapOut !== undefined) {
                    settingsRoot.hyprlandGapOut = data.hyprlandGapOut
                }
                if (data && data.hyprlandBlurEnabled !== undefined) {
                    settingsRoot.hyprlandBlurEnabled = data.hyprlandBlurEnabled
                }
                if (data && data.hyprlandBlurSize !== undefined) {
                    settingsRoot.hyprlandBlurSize = data.hyprlandBlurSize
                }
                if (data && data.hyprlandBlurPasses !== undefined) {
                    settingsRoot.hyprlandBlurPasses = data.hyprlandBlurPasses
                }
                if (data && data.hyprlandBlurVibrancy !== undefined) {
                    settingsRoot.hyprlandBlurVibrancy = data.hyprlandBlurVibrancy
                }
                _loading = false
                applyHyprlandRadius(settingsRoot.hyprlandRadius)
                applyHyprlandBorderThickness(settingsRoot.hyprlandBorderThickness)
                applyHyprlandWindowOpacity(settingsRoot.hyprlandWindowOpacity)
                applyHyprlandGapIn(settingsRoot.hyprlandGapIn)
                applyHyprlandGapOut(settingsRoot.hyprlandGapOut)
                applyHyprlandBlur(settingsRoot.hyprlandBlurEnabled, settingsRoot.hyprlandBlurSize,
                                  settingsRoot.hyprlandBlurPasses, settingsRoot.hyprlandBlurVibrancy)
                settingsRoot.loaded = true
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

    Process {
        id: themePatchProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: themePatchProc2
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: hyprctlGapInProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: hyprctlGapOutProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: sedGapInProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: sedGapOutProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: hyprctlBlurProc
        running: false
        stdout: SplitParser { onRead: line => {} }
    }

    Process {
        id: sedBlurProc
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

    function setHyprlandGapIn(g) {
        settingsRoot.hyprlandGapIn = g
        applyHyprlandGapIn(g)
    }

    function setHyprlandGapOut(g) {
        settingsRoot.hyprlandGapOut = g
        applyHyprlandGapOut(g)
    }

    function setHyprlandBlurEnabled(enabled) {
        settingsRoot.hyprlandBlurEnabled = enabled
        applyHyprlandBlur(enabled, settingsRoot.hyprlandBlurSize, settingsRoot.hyprlandBlurPasses, settingsRoot.hyprlandBlurVibrancy)
    }

    function setHyprlandBlurSize(s) {
        settingsRoot.hyprlandBlurSize = s
        applyHyprlandBlur(settingsRoot.hyprlandBlurEnabled, s, settingsRoot.hyprlandBlurPasses, settingsRoot.hyprlandBlurVibrancy)
    }

    function setHyprlandBlurPasses(p) {
        settingsRoot.hyprlandBlurPasses = p
        applyHyprlandBlur(settingsRoot.hyprlandBlurEnabled, settingsRoot.hyprlandBlurSize, p, settingsRoot.hyprlandBlurVibrancy)
    }

    function setHyprlandBlurVibrancy(v) {
        settingsRoot.hyprlandBlurVibrancy = v
        applyHyprlandBlur(settingsRoot.hyprlandBlurEnabled, settingsRoot.hyprlandBlurSize, settingsRoot.hyprlandBlurPasses, v)
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

    function setWorkspaceStyle(style) {
        settingsRoot.workspaceStyle = style
    }

    function applyHyprlandRadius(r) {
        hyprctlProc.command = ["hyprctl", "eval", "hl.config({ decoration = { rounding = " + r + " } })"]
        hyprctlProc.running = true
        saveLuaConfig(r)
        patchAllThemeHyprlook("rounding", r)
    }

    function applyHyprlandBorderThickness(t) {
        hyprctlBorderProc.command = ["hyprctl", "eval", "hl.config({ general = { border_size = " + t + " } })"]
        hyprctlBorderProc.running = true
        saveLuaBorderConfig(t)
        patchAllThemeHyprlook("border_size", t)
    }

    function applyHyprlandWindowOpacity(o) {
        hyprctlOpacityProc.command = ["hyprctl", "eval", "hl.config({ decoration = { active_opacity = " + o + ", inactive_opacity = " + o + " } })"]
        hyprctlOpacityProc.running = true
        saveLuaOpacityConfig(o)
        patchAllThemeHyprlook("active_opacity", o)
        patchAllThemeHyprlook("inactive_opacity", o)
    }

    function applyHyprlandGapIn(g) {
        hyprctlGapInProc.command = ["hyprctl", "eval", "hl.config({ general = { gaps_in = " + g + " } })"]
        hyprctlGapInProc.running = true
        saveLuaGapInConfig(g)
        patchAllThemeHyprlook("gaps_in", g)
    }

    function applyHyprlandGapOut(g) {
        hyprctlGapOutProc.command = ["hyprctl", "eval", "hl.config({ general = { gaps_out = " + g + " } })"]
        hyprctlGapOutProc.running = true
        saveLuaGapOutConfig(g)
        patchAllThemeHyprlook("gaps_out", g)
    }

    function applyHyprlandBlur(enabled, size, passes, vibrancy) {
        var en = enabled ? "true" : "false"
        hyprctlBlurProc.command = ["hyprctl", "eval", "hl.config({ decoration = { blur = { enabled = " + en + ", size = " + size + ", passes = " + passes + ", vibrancy = " + vibrancy + " } } })"]
        hyprctlBlurProc.running = true
        saveLuaBlurConfig(enabled, size, passes, vibrancy)
        patchAllThemeHyprlookBool("enabled", en)
        patchAllThemeHyprlook("size", size)
        patchAllThemeHyprlook("passes", passes)
        patchAllThemeHyprlookFloat("vibrancy", vibrancy)
    }

    function saveLuaOpacityConfig(o) {
        const luaPath = StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/hypr/modules/look.lua"
        const cmd = "sed -i 's/active_opacity\\s*=\\s*[0-9.]*\\+/active_opacity    = " + o + "/g' '" + luaPath + "' && " +
                    "sed -i 's/inactive_opacity\\s*=\\s*[0-9.]*\\+/inactive_opacity  = " + o + "/g' '" + luaPath + "'"
        sedOpacityProc.command = ["sh", "-c", cmd]
        sedOpacityProc.running = true
    }

    function saveLuaGapInConfig(g) {
        const luaPath = StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/hypr/modules/look.lua"
        const cmd = "sed -i 's/gaps_in\\s*=\\s*[0-9]\\+/gaps_in  = " + g + "/g' '" + luaPath + "'"
        sedGapInProc.command = ["sh", "-c", cmd]
        sedGapInProc.running = true
    }

    function saveLuaGapOutConfig(g) {
        const luaPath = StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/hypr/modules/look.lua"
        const cmd = "sed -i 's/gaps_out\\s*=\\s*[0-9]\\+/gaps_out = " + g + "/g' '" + luaPath + "'"
        sedGapOutProc.command = ["sh", "-c", cmd]
        sedGapOutProc.running = true
    }

    function saveLuaBlurConfig(enabled, size, passes, vibrancy) {
        const luaPath = StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/hypr/modules/look.lua"
        var en = enabled ? "true" : "false"
        const cmd = "sed -i 's/ enabled\\s*=\\s*true\\| enabled\\s*=\\s*false/enabled   = " + en + "/g' '" + luaPath + "' && " +
                    "sed -i 's/ size\\s*=\\s*[0-9]\\+/size      = " + size + "/g' '" + luaPath + "' && " +
                    "sed -i 's/ passes\\s*=\\s*[0-9]\\+/passes    = " + passes + "/g' '" + luaPath + "' && " +
                    "sed -i 's/ vibrancy\\s*=\\s*[0-9.]*\\+/vibrancy  = " + vibrancy + "/g' '" + luaPath + "'"
        sedBlurProc.command = ["sh", "-c", cmd]
        sedBlurProc.running = true
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

    function patchAllThemeHyprlook(key, value) {
        var cmd = "for f in $HOME/.config/.hypr-themes/*/hyprlook; do " +
                  "[ -f \"$f\" ] && sed -i 's/ " + key + "\\s*=\\s*[0-9.]*\\+/" + key + " = " + value + "/g' \"$f\"; done"
        themePatchProc.command = ["sh", "-c", cmd]
        themePatchProc.running = true
        if (key === "rounding") {
            var cmd2 = "for f in $HOME/.config/.hypr-themes/*/hyprlook; do " +
                       "[ -f \"$f\" ] && sed -i 's/ rounding_power\\s*=\\s*[0-9.]*\\+/rounding_power = " + value + "/g' \"$f\"; done"
            themePatchProc2.command = ["sh", "-c", cmd2]
            themePatchProc2.running = true
        }
    }

    function patchAllThemeHyprlookBool(key, value) {
        var cmd = "for f in $HOME/.config/.hypr-themes/*/hyprlook; do " +
                  "[ -f \"$f\" ] && sed -i 's/ " + key + "\\s*=\\s*true\\| " + key + "\\s*=\\s*false/" + key + "   = " + value + "/g' \"$f\"; done"
        themePatchProc.command = ["sh", "-c", cmd]
        themePatchProc.running = true
    }

    function patchAllThemeHyprlookFloat(key, value) {
        var cmd = "for f in $HOME/.config/.hypr-themes/*/hyprlook; do " +
                  "[ -f \"$f\" ] && sed -i 's/ " + key + "\\s*=\\s*[0-9]*\\.[0-9]*/" + key + "  = " + value + "/g' \"$f\"; done"
        themePatchProc2.command = ["sh", "-c", cmd]
        themePatchProc2.running = true
    }

    function save() {
        const json = JSON.stringify({
            barRadius: settingsRoot.barRadius,
            hyprlandRadius: settingsRoot.hyprlandRadius,
            borderThickness: settingsRoot.borderThickness,
            hyprlandBorderThickness: settingsRoot.hyprlandBorderThickness,
            barOpacity: settingsRoot.barOpacity,
            hyprlandWindowOpacity: settingsRoot.hyprlandWindowOpacity,
            hyprlandGapIn: settingsRoot.hyprlandGapIn,
            hyprlandGapOut: settingsRoot.hyprlandGapOut,
            hyprlandBlurEnabled: settingsRoot.hyprlandBlurEnabled,
            hyprlandBlurSize: settingsRoot.hyprlandBlurSize,
            hyprlandBlurPasses: settingsRoot.hyprlandBlurPasses,
            hyprlandBlurVibrancy: settingsRoot.hyprlandBlurVibrancy,
            barMonitor: settingsRoot.barMonitor,
            barPosition: settingsRoot.barPosition,
            selectedReciter: settingsRoot.selectedReciter,
            autoNext: settingsRoot.autoNext,
            arabicFont: settingsRoot.arabicFont,
            arabicFontSize: settingsRoot.arabicFontSize,
            translationFontSize: settingsRoot.translationFontSize,
            arabicBold: settingsRoot.arabicBold,
            nightlightEnabled: settingsRoot.nightlightEnabled,
            workspaceStyle: settingsRoot.workspaceStyle
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

    onHyprlandGapInChanged: {
        if (!_loading) save()
    }

    onHyprlandGapOutChanged: {
        if (!_loading) save()
    }

    onHyprlandBlurEnabledChanged: {
        if (!_loading) save()
    }

    onHyprlandBlurSizeChanged: {
        if (!_loading) save()
    }

    onHyprlandBlurPassesChanged: {
        if (!_loading) save()
    }

    onHyprlandBlurVibrancyChanged: {
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

    onWorkspaceStyleChanged: {
        if (!_loading) save()
    }
}
