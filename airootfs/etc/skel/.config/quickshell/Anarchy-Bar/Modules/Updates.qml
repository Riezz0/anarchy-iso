import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: updatesRoot

    property int updateCount: 0
    property bool updatesAvailable: false
    property bool loaded: false
    property bool checking: false
    property var updateList: []

    property string terminal: "kitty"

    function updateIcon() {
        return updatesAvailable ? "\u{F1259}" : "\u{F003C}"
    }

    function updateColor() {
        return updatesAvailable ? theme.color3 : theme.muted
    }

    function stripAnsi(str) {
        return str.replace(/\x1b\[[0-9;]*m/g, "")
    }

    function parse(output) {
        var clean = stripAnsi(output)
        var lines = clean.split("\n")
        var list = []

        for (var i = 0; i < lines.length; i++) {
            var t = lines[i].trim()
            if (!t) continue
            if (t.toLowerCase().indexOf("looking for updates") >= 0) continue
            if (t.indexOf("==>") === 0) continue
            if (t.toLowerCase().indexOf("no update available") >= 0) continue
            if (t.indexOf("up-to-date") >= 0) continue
            if (t.indexOf("Packages:") >= 0) continue
            if (t.indexOf("Foreign Packages:") >= 0) continue
            list.push(t)
        }

        updatesRoot.updateList = list
        updatesRoot.updateCount = list.length
        updatesRoot.updatesAvailable = list.length > 0
        updatesRoot.loaded = true
    }

    function refresh() {
        if (listProc.running) return
        updatesRoot.checking = true
        listProc.running = true
    }

    function launchUpdate() {
        updateProc.command = [terminal, "--app-id", "arch-update", "-e", "arch-update"]
        updateProc.running = true
    }

    Process {
        id: listProc
        running: false
        command: ["arch-update", "--list"]

        stdout: StdioCollector {
            id: listStdio
            onStreamFinished: {
                updatesRoot.parse(listStdio.text)
                updatesRoot.checking = false
            }
        }
    }

    Process {
        id: updateProc
        running: false

        onRunningChanged: {
            if (!running) {
                updatesRoot.refresh()
            }
        }
    }

    Timer {
        interval: 1800000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updatesRoot.refresh()
    }
}
