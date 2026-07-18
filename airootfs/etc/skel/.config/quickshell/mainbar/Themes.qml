import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: themesRoot

    property var    themeList: []
    property bool   loaded: false

    readonly property string themesDir: Quickshell.env("HOME") + "/.config/.hypr-themes"

    Process {
        id:      listProc
        command: ["ls", "-1", themesRoot.themesDir]
        running: false

        property string buffer: ""

        stdout: SplitParser {
            onRead: line => {
                var t = line.trim()
                if (t.length > 0 && !t.endsWith(".sh"))
                    listProc.buffer += t + "\n"
            }
        }

        onRunningChanged: {
            if (!running) {
                var folders = listProc.buffer.trim().split("\n")
                listProc.buffer = ""
                themesRoot.scanFolders(folders)
            }
        }
    }

    property var pendingFolders: []
    property var pendingResults: []

    Process {
        id:      scriptProc
        command: ["ls", "-1", ""]
        running: false

        property int    folderIndex: -1
        property string folderName: ""
        property string buffer: ""

        stdout: SplitParser {
            onRead: line => {
                var t = line.trim()
                if (t.endsWith(".sh") && t !== "wf-recorder-toggle.sh")
                    scriptProc.buffer += t + "\n"
            }
        }

        onRunningChanged: {
            if (!running) {
                var scripts = scriptProc.buffer.trim().split("\n")
                var folder  = scriptProc.folderName
                scriptProc.buffer = ""

                if (scripts.length > 0 && scripts[0].length > 0) {
                    var scriptPath = themesRoot.themesDir + "/" + folder + "/" + scripts[0]
                    var thumbPath  = themesRoot.themesDir + "/" + folder + "/thumbnail.png"
                    themesRoot.pendingResults.push({
                        folder:      folder,
                        script:      scriptPath,
                        thumbnail:   "file://" + thumbPath,
                        displayName: folder.replace(/-/g, " ").replace(/\b\w/g, l => l.toUpperCase())
                    })
                }

                themesRoot.processNextFolder()
            }
        }
    }

    function scanFolders(folders) {
        pendingResults = []
        pendingFolders = []
        for (var i = 0; i < folders.length; i++) {
            var f = folders[i].trim()
            if (f.length > 0) pendingFolders.push(f)
        }
        processNextFolder()
    }

    function processNextFolder() {
        if (pendingFolders.length === 0) {
            themeList = pendingResults
            loaded = true
            return
        }
        var folder = pendingFolders.shift()
        scriptProc.folderName = folder
        scriptProc.command = ["ls", "-1", themesRoot.themesDir + "/" + folder]
        scriptProc.buffer = ""
        scriptProc.running = true
    }

    Process {
        id:      applyProc
        command: ["bash", themesRoot.themesDir + "/run-theme.sh", ""]
        running: false
    }

    Timer {
        interval: 30000
        running: true
        repeat:  true
        triggeredOnStart: true
        onTriggered: {
            if (!listProc.running) {
                listProc.buffer = ""
                listProc.running = true
            }
        }
    }

    function applyTheme(scriptPath) {
        if (applyProc.running) return
        applyProc.command = ["setsid", "bash", themesRoot.themesDir + "/run-theme.sh", scriptPath]
        applyProc.running = true
    }

    function rescan() {
        if (!listProc.running) {
            listProc.buffer = ""
            listProc.running = true
        }
    }
}
