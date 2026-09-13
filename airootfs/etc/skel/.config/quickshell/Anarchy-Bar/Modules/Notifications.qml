import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Item {
    id: notifsRoot

    signal notificationReceived(string appName, string summary, string body, int urgency, real timeout, var actions)

    property int trackedCount: 0
    property bool hasUnread: false
    property bool dndEnabled: false
    property var activeNotifications: []
    property bool startupGrace: true

    readonly property string cacheDir:
        StandardPaths.writableLocation(StandardPaths.CacheLocation).toString().replace(/^file:\/\//, "")
    readonly property string persistPath: cacheDir + "/notifications.json"

    NotificationServer {
        id: notifServer
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        actionsSupported: true
        actionIconsSupported: true

        onNotification: notification => {
            if (notifsRoot.dndEnabled) return
            notification.tracked = true
            var notifData = {
                id: Date.now() + Math.random(),
                appName: notification.appName || "",
                summary: notification.summary || "",
                body: notification.body || "",
                urgency: notification.urgency || 2,
                timeout: notification.expireTimeout > 0 ? notification.expireTimeout : (notification.urgency === 1 ? 10000 : 5000),
                appNotification: notification
            }
            var arr = notifsRoot.activeNotifications.slice()
            arr.push(notifData)
            notifsRoot.activeNotifications = arr
            notifsRoot.trackedCount = arr.length
            notifsRoot.hasUnread = true
            notifsRoot.persist()
            if (!notifsRoot.startupGrace) {
                notifsRoot.notificationReceived(notifData.appName, notifData.summary, notifData.body, notifData.urgency, notifData.timeout, [])
            }
        }
    }

    FileView {
        id: persistFile
        path: notifsRoot.persistPath
        watchChanges: false
        onLoaded: {
            try {
                var data = JSON.parse(persistFile.text())
                if (data && data.length > 0) {
                    notifsRoot.activeNotifications = data
                    notifsRoot.trackedCount = data.length
                    notifsRoot.hasUnread = true
                }
            } catch (e) {}
        }
    }

    Process {
        id: fileWriter
        running: false
        property string pendingData: ""
        stdout: SplitParser { onRead: line => {} }
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

    Timer { interval: 1000; running: true; repeat: true; onTriggered: notifsRoot.cleanup() }
    Timer { interval: 2000; running: true; repeat: false; onTriggered: notifsRoot.startupGrace = false }

    function persist() {
        var arr = []
        for (var i = 0; i < notifsRoot.activeNotifications.length; i++) {
            var n = notifsRoot.activeNotifications[i]
            arr.push({ appName: n.appName, summary: n.summary, body: n.body, urgency: n.urgency, timeout: n.timeout })
        }
        var json = JSON.stringify(arr)
        var escaped = json.replace(/'/g, "'\\''")
        fileWriter.command = ["sh", "-c", "mkdir -p '" + notifsRoot.cacheDir + "' && printf '%s' '" + escaped + "' > '" + notifsRoot.persistPath + "'"]
        fileWriter.running = true
    }

    function cleanup() {
        var arr = notifsRoot.activeNotifications.slice()
        var changed = false
        for (var i = arr.length - 1; i >= 0; i--) {
            var n = arr[i]
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
        if (notifsRoot.trackedCount === 0) notifsRoot.hasUnread = false
    }

    function dismissNotif(nid) {
        var arr = notifsRoot.activeNotifications.slice()
        var notif = arr.find(function(n) { return n.id === nid })
        if (notif && notif.appNotification) notif.appNotification.dismiss()
        arr = arr.filter(function(n) { return n.id !== nid })
        notifsRoot.activeNotifications = arr
        notifsRoot.trackedCount = arr.length
        if (notifsRoot.trackedCount === 0) notifsRoot.hasUnread = false
        notifsRoot.persist()
    }

    function clearAll() {
        var arr = notifsRoot.activeNotifications.slice()
        for (var i = 0; i < arr.length; i++) {
            if (arr[i].appNotification) arr[i].appNotification.dismiss()
        }
        notifsRoot.activeNotifications = []
        notifsRoot.trackedCount = 0
        notifsRoot.hasUnread = false
        notifsRoot.persist()
    }

    function notifIcon() {
        if (notifsRoot.dndEnabled) return "\u{F009B}"
        if (notifsRoot.hasUnread) return "\u{F009E}"
        return "\u{F009C}"
    }

    function notifColor() {
        if (notifsRoot.dndEnabled) return theme.muted
        if (notifsRoot.hasUnread) return theme.color1
        return theme.color4
    }
}
