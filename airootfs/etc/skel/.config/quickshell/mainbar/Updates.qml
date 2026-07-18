// ═══════════════════════════════════════════════════════════════════════════════
// Updates Module - Arch-Update Integration
// ═══════════════════════════════════════════════════════════════════════════════
// Uses the "arch-update" package (https://github.com/Antiz96/arch-update) to list
// the available system updates via `arch-update --list`, and launches the
// interactive `arch-update` update feature in a terminal on demand.
//
// Usage in shell.qml:
//   Updates { id: updates }
//   updates.updatesAvailable // true when updates are available
//   updates.updateCount      // number of pending updates
//   updates.loaded           // true once the first check completed
//   updates.updateList       // list of "name old -> new" strings
//   updates.updateIcon()     // icon glyph for the bar button
//   updates.updateColor()    // color for the bar button
//   updates.refresh()        // force a re-check
//   updates.launchUpdate()   // run the interactive update feature in a terminal
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: updatesRoot

    // ═══════════════════════════════════════════════════════════════════════════
    // Properties
    // ═══════════════════════════════════════════════════════════════════════════

    property int  updateCount:     0
    property bool updatesAvailable: false
    property bool loaded:          false
    property bool checking:        false
    property var  updateList:      []

    // Terminal used to run the interactive `arch-update` TUI
    property string terminal: "kitty"

    // ═══════════════════════════════════════════════════════════════════════════
    // Helpers
    // ═══════════════════════════════════════════════════════════════════════════

    function updateIcon() {
        return "󰏖"
    }

    function updateColor() {
        return updatesAvailable ? theme.color3 : theme.muted
    }

    function stripAnsi(str) {
        return str.replace(/\x1b\[[0-9;]*m/g, "")
    }

    function parse(output) {
        const clean = stripAnsi(output)
        const lines = clean.split("\n")
        const list  = []

        for (let i = 0; i < lines.length; i++) {
            const t = lines[i].trim()
            if (!t) continue
            if (t.toLowerCase().includes("looking for updates")) continue
            if (t.startsWith("==>") || t.endsWith(":")) continue   // section headers
            if (t.toLowerCase().includes("no update available")) continue
            if (t.includes("up-to-date")) continue
            list.push(t)
        }

        updatesRoot.updateList      = list
        updatesRoot.updateCount     = list.length
        updatesRoot.updatesAvailable = list.length > 0
        updatesRoot.loaded          = true
    }

    function refresh() {
        if (listProc.running)
            return
        updatesRoot.checking = true
        listProc.running     = true
    }

    function launchUpdate() {
        updateProc.command = [terminal, "-e", "arch-update"]
        updateProc.running = true
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Processes
    // ═══════════════════════════════════════════════════════════════════════════

    // ── List available updates ──────────────────────────────────────────────
    Process {
        id:      listProc
        running: false
        command: ["bash", "-c", "arch-update --list 2>&1"]

        property string buffer: ""

        stdout: SplitParser { onRead: data => { listProc.buffer += data + "\n" } }
        stderr: SplitParser { onRead: data => { listProc.buffer += data + "\n" } }

        onRunningChanged: {
            if (!running) {
                updatesRoot.parse(listProc.buffer)
                listProc.buffer  = ""
                updatesRoot.checking = false
            }
        }
    }

    // ── Launch the interactive update feature ────────────────────────────────
    Process {
        id:      updateProc
        running: false

        onRunningChanged: {
            if (!running) {
                // The terminal was closed after the update finished;
                // re-check so the bar/popup reflect the new state.
                updatesRoot.refresh()
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Timer - Re-check every 30 minutes
    // ═══════════════════════════════════════════════════════════════════════════

    Timer {
        interval:         1800000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered:      updatesRoot.refresh()
    }
}
