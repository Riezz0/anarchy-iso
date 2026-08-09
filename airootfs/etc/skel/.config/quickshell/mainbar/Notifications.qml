// ═══════════════════════════════════════════════════════════════════════════════
// Notifications Module - Desktop Notification Server
// ═══════════════════════════════════════════════════════════════════════════════
// Replaces swaync as the system notification daemon. Uses Quickshell's native
// notification server to receive and manage notifications from all applications.
// Persists notifications to disk so they survive bar reloads.
//
// IMPORTANT: Kill swaync before using this module:
//   killall swaync
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Item {
    id: notifsRoot

    // ═══════════════════════════════════════════════════════════════════════════
    // Signals
    // ═══════════════════════════════════════════════════════════════════════════

    signal notificationReceived(string appName, string summary, string body,
                                int urgency, real timeout, var actions)

    // ═══════════════════════════════════════════════════════════════════════════
    // Properties
    // ═══════════════════════════════════════════════════════════════════════════

    property int  trackedCount: 0
    property bool hasUnread:    false
    property bool dndEnabled:   false
    property var  activeNotifications: []
    property bool startupGrace: true

    readonly property string cacheDir:
        StandardPaths.writableLocation(StandardPaths.CacheLocation).toString().replace(/^file:\/\//, "")
    readonly property string persistPath:
        cacheDir + "/notifications.json"

    // ═══════════════════════════════════════════════════════════════════════════
    // Notification Server
    // ═══════════════════════════════════════════════════════════════════════════

    NotificationServer {
        id: notifServer

        keepOnReload:          true
        bodySupported:         true
        bodyMarkupSupported:   true
        bodyImagesSupported:   true
        actionsSupported:      true
        actionIconsSupported:  true

        onNotification: notification => {
            if (notifsRoot.dndEnabled) return

            notification.tracked = true

            const notifData = {
                id:       Date.now() + Math.random(),
                appName:  notification.appName || "",
                summary:  notification.summary || "",
                body:     notification.body || "",
                urgency:  notification.urgency || 2,
                timeout:  notification.expireTimeout > 0 ? notification.expireTimeout
                          : (notification.urgency === 1 ? 10000 : 5000),
                appNotification: notification
            }

            let arr = notifsRoot.activeNotifications.slice()
            arr.push(notifData)
            notifsRoot.activeNotifications = arr
            notifsRoot.trackedCount = arr.length
            notifsRoot.hasUnread = true
            notifsRoot.persist()

            if (!notifsRoot.startupGrace) {
                notifsRoot.notificationReceived(
                    notifData.appName,
                    notifData.summary,
                    notifData.body,
                    notifData.urgency,
                    notifData.timeout,
                    []
                )
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Initialization
    // ═══════════════════════════════════════════════════════════════════════════

    FileView {
        id: persistFile
        path: notifsRoot.persistPath
        watchChanges: false
        onLoaded: {
            try {
                const data = JSON.parse(persistFile.text())
                if (data && data.length > 0) {
                    notifsRoot.activeNotifications = data
                    notifsRoot.trackedCount = data.length
                    notifsRoot.hasUnread = true
                }
            } catch (e) {}
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // File Writer
    // ═══════════════════════════════════════════════════════════════════════════

    Process {
        id: fileWriter
        running: false
        property string pendingData: ""
        stdout: SplitParser { onRead: line => {} }
        onRunningChanged: {
            if (!running) {
                // Write completed
            }
        }
    }

    Process {
        id: dirCreator
        running: false
        command: ["sh", "-c", "mkdir -p \"" + notifsRoot.cacheDir + "\""]
    }

    Component.onCompleted: {
        dirCreator.running = true
        persistFile.reload()
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Cleanup Timer
    // ═══════════════════════════════════════════════════════════════════════════

    Timer {
        interval: 1000
        running:  true
        repeat:   true
        onTriggered: notifsRoot.cleanup()
    }

    Timer {
        interval: 2000
        running:  true
        repeat:   false
        onTriggered: notifsRoot.startupGrace = false
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Functions
    // ═══════════════════════════════════════════════════════════════════════════

    function persist() {
        let arr = []
        for (let i = 0; i < notifsRoot.activeNotifications.length; i++) {
            const n = notifsRoot.activeNotifications[i]
            arr.push({
                appName:  n.appName,
                summary:  n.summary,
                body:     n.body,
                urgency:  n.urgency,
                timeout:  n.timeout
            })
        }
        const json = JSON.stringify(arr)
        const escaped = json.replace(/'/g, "'\\''")
        fileWriter.command = ["sh", "-c", "mkdir -p '" + notifsRoot.cacheDir + "' && printf '%s' '" + escaped + "' > '" + notifsRoot.persistPath + "'"]
        fileWriter.running = true
    }

    function cleanup() {
        let arr = notifsRoot.activeNotifications.slice()
        let changed = false
        for (let i = arr.length - 1; i >= 0; i--) {
            const n = arr[i]
            if (n.appNotification && !n.appNotification.tracked) {
                arr.splice(i, 1)
                changed = true
            }
        }
        if (changed) {
            notifsRoot.activeNotifications = arr
            notifsRoot.trackedCount = arr.length
            notifsRoot.persist()
        }
        if (notifsRoot.trackedCount === 0)
            notifsRoot.hasUnread = false
    }

    function dismissNotif(nid) {
        let arr = notifsRoot.activeNotifications.slice()
        const notif = arr.find(n => n.id === nid)
        if (notif && notif.appNotification) {
            notif.appNotification.dismiss()
        }
        arr = arr.filter(n => n.id !== nid)
        notifsRoot.activeNotifications = arr
        notifsRoot.trackedCount = arr.length
        if (notifsRoot.trackedCount === 0)
            notifsRoot.hasUnread = false
        notifsRoot.persist()
    }

    function clearAll() {
        let arr = notifsRoot.activeNotifications.slice()
        for (let i = 0; i < arr.length; i++) {
            if (arr[i].appNotification) {
                arr[i].appNotification.dismiss()
            }
        }
        notifsRoot.activeNotifications = []
        notifsRoot.trackedCount = 0
        notifsRoot.hasUnread = false
        notifsRoot.persist()
    }

    function notifIcon() {
        if (notifsRoot.dndEnabled)      return "󰂛"
        if (notifsRoot.hasUnread)       return "󰂞"
        return "󰂜"
    }

    function notifColor() {
        if (notifsRoot.dndEnabled)      return theme.muted
        if (notifsRoot.hasUnread)       return theme.color1
        return theme.color4
    }

    function appIcon(name) {
        if (!name) return "󰂚"
        const n = name.toLowerCase()
        if (n.includes("firefox") || n.includes("chrome") || n.includes("browser")) return "󰖟"
        if (n.includes("spotify") || n.includes("music") || n.includes("mpd"))      return "󰎈"
        if (n.includes("discord") || n.includes("slack") || n.includes("telegram") || n.includes("signal")) return "󰭻"
        if (n.includes("mail") || n.includes("thunderbird"))                          return "󰇰"
        if (n.includes("file") || n.includes("nautilus") || n.includes("dolphin"))    return "󰉋"
        if (n.includes("code") || n.includes("vscode") || n.includes("vim"))          return "󰘚"
        if (n.includes("image") || n.includes("gimp") || n.includes("photo"))         return "󰈏"
        if (n.includes("video") || n.includes("mpv") || n.includes("vlc"))            return "󰎉"
        if (n.includes("system") || n.includes("kernel") || n.includes("update"))     return "󰄱"
        if (n.includes("screenshot") || n.includes("grim") || n.includes("slurp"))    return "󰹑"
        return "󰂚"
    }

}
