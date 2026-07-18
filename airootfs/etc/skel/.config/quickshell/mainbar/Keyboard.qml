// ═══════════════════════════════════════════════════════════════════════════════
// Keyboard Module - Active Layout Detection
// ═══════════════════════════════════════════════════════════════════════════════
// Detects the current keyboard layout using hyprctl devices.
// Layouts configured: us, my_ar (Alt+Shift to toggle)
//
// Usage in shell.qml:
//   Keyboard { id: kbd }
//   kbd.layoutLabel   // Short label (e.g. "EN", "AR")
//   kbd.layoutIcon()  // Nerd Font keyboard icon
//   kbd.layoutColor() // Color based on active layout
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: kbdRoot

    property string activeLayout: "us"
    property string layoutLabel:  "EN"
    property bool   loaded:       false

    property var layoutMap: ({
        "us":      { label: "EN", color: "color6" },
        "my_ar":   { label: "AR", color: "color1" },
        "gb":      { label: "EN", color: "color6" },
        "de":      { label: "DE", color: "color4" },
        "fr":      { label: "FR", color: "color4" },
        "es":      { label: "ES", color: "color4" },
        "it":      { label: "IT", color: "color4" },
        "pt":      { label: "PT", color: "color4" },
        "br":      { label: "BR", color: "color4" },
        "jp":      { label: "JP", color: "color2" },
        "kr":      { label: "KR", color: "color2" },
        "cn":      { label: "CN", color: "color1" },
        "ru":      { label: "RU", color: "color5" },
        "ara":     { label: "AR", color: "color1" },
        "il":      { label: "HE", color: "color5" }
    })

    Process {
        id:      layoutProc
        command: ["hyprctl", "devices", "-j"]
        running: false

        property string output: ""

        stdout: SplitParser {
            onRead: line => { layoutProc.output += line }
        }

        onRunningChanged: {
            if (!running) {
                kbdRoot.parseLayout(layoutProc.output)
                layoutProc.output = ""
            }
        }
    }

    Timer {
        interval:         2000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: {
            if (!layoutProc.running) {
                layoutProc.output = ""
                layoutProc.running = true
            }
        }
    }

    function parseLayout(data) {
        try {
            const json = JSON.parse(data)
            if (json.keyboards && json.keyboards.length > 0) {
                // Find the main keyboard
                for (let i = 0; i < json.keyboards.length; i++) {
                    const kb = json.keyboards[i]
                    if (kb.main === true) {
                        const layouts = kb.layout.split(",")
                        const idx = kb.active_layout_index || 0
                        const code = layouts[idx] || layouts[0] || "us"
                        kbdRoot.activeLayout = code
                        kbdRoot.layoutLabel = getLabel(code)
                        kbdRoot.loaded = true
                        return
                    }
                }
                // Fallback: use first keyboard
                const kb = json.keyboards[0]
                const layouts = kb.layout.split(",")
                const idx = kb.active_layout_index || 0
                const code = layouts[idx] || layouts[0] || "us"
                kbdRoot.activeLayout = code
                kbdRoot.layoutLabel = getLabel(code)
                kbdRoot.loaded = true
            }
        } catch (e) {
            // JSON parse error, ignore
        }
    }

    function getLabel(layout) {
        if (layoutMap[layout])
            return layoutMap[layout].label
        return layout.substring(0, 2).toUpperCase()
    }

    function layoutIcon() {
        return "󰌌"
    }

    function layoutColor() {
        if (layoutMap[activeLayout])
            return theme[layoutMap[activeLayout].color]
        return theme.muted
    }

    function refresh() {
        if (!layoutProc.running) {
            layoutProc.output = ""
            layoutProc.running = true
        }
    }
}
