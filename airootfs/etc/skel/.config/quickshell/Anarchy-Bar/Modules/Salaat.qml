import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: salaat

    property real latitude: -26.2041
    property real longitude: 28.0473
    property string locationName: ""

    property string fajr: "--:--"
    property string sunrise: "--:--"
    property string dhuhr: "--:--"
    property string asr: "--:--"
    property string maghrib: "--:--"
    property string isha: "--:--"

    property string nextPrayer: ""
    property string nextTime: ""
    property bool loaded: false

    property string scrollText: ""
    property string tooltipText: ""
    property int scrollOffset: 0
    property string _displayText: ""

    readonly property int visibleWidth: 30

    Process {
        id: geoProc
        command: ["curl", "-s", "--max-time", "10", "https://ipinfo.io/json"]
        running: false
        property string buffer: ""
        stdout: SplitParser { onRead: line => { geoProc.buffer += line + "\n" } }
        onRunningChanged: { if (!running) { salaat.parseGeo(geoProc.buffer); geoProc.buffer = "" } }
    }

    Process {
        id: prayerProc
        command: ["curl", "-sL", "--max-time", "10", ""]
        running: false
        property string buffer: ""

        function fetch() {
            var url = "http://api.aladhan.com/v1/timings/" + salaat.todayTimestamp()
                + "?latitude=" + salaat.latitude
                + "&longitude=" + salaat.longitude
                + "&method=3"
            command = ["curl", "-sL", "--max-time", "10", url]
            buffer = ""
            running = true
        }

        stdout: SplitParser { onRead: line => { prayerProc.buffer += line + "\n" } }
        onRunningChanged: { if (!running) { salaat.parsePrayers(prayerProc.buffer); prayerProc.buffer = "" } }
    }

    Timer { interval: 1000; running: true; repeat: false; onTriggered: { if (!geoProc.running) { geoProc.buffer = ""; geoProc.running = true } } }
    Timer { interval: 1800000; running: true; repeat: true; triggeredOnStart: false; onTriggered: { if (!prayerProc.running) prayerProc.fetch() } }

    Timer {
        interval: 500
        running: salaat.loaded
        repeat: true
        onTriggered: {
            salaat.scrollOffset = (salaat.scrollOffset + 1) % salaat.scrollText.length
            salaat.updateDisplay()
        }
    }

    Timer { interval: 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { if (salaat.loaded) salaat.findNextPrayer() } }

    function todayTimestamp() { return Math.floor(Date.now() / 1000) }

    function parseGeo(jsonStr) {
        try {
            var data = JSON.parse(jsonStr)
            salaat.latitude = parseFloat(data.loc.split(",")[0])
            salaat.longitude = parseFloat(data.loc.split(",")[1])
            salaat.locationName = (data.city || "") + (data.country ? ", " + data.country : "")
        } catch (e) {}
        if (!prayerProc.running) prayerProc.fetch()
    }

    function parsePrayers(jsonStr) {
        try {
            var data = JSON.parse(jsonStr)
            var t = data.data.timings
            salaat.fajr = cleanTime(t.Fajr || "--:--")
            salaat.sunrise = cleanTime(t.Sunrise || "--:--")
            salaat.dhuhr = cleanTime(t.Dhuhr || "--:--")
            salaat.asr = cleanTime(t.Asr || "--:--")
            salaat.maghrib = cleanTime(t.Maghrib || "--:--")
            salaat.isha = cleanTime(t.Isha || "--:--")
            salaat.loaded = true
            salaat.findNextPrayer()
            salaat.buildScrollText()
        } catch (e) {}
    }

    function cleanTime(t) {
        var idx = t.indexOf(" ")
        return idx > 0 ? t.substring(0, idx) : t
    }

    function findNextPrayer() {
        var now = new Date()
        var prayers = [
            { name: "Fajr", time: salaat.fajr },
            { name: "Sunrise", time: salaat.sunrise },
            { name: "Dhuhr", time: salaat.dhuhr },
            { name: "Asr", time: salaat.asr },
            { name: "Maghrib", time: salaat.maghrib },
            { name: "Isha", time: salaat.isha }
        ]
        for (var i = 0; i < prayers.length; i++) {
            var p = prayers[i]
            if (p.time === "--:--") continue
            var parts = p.time.split(":")
            var prayDate = new Date(now)
            prayDate.setHours(parseInt(parts[0]), parseInt(parts[1]), 0, 0)
            if (prayDate > now) {
                salaat.nextPrayer = p.name
                salaat.nextTime = p.time
                return
            }
        }
        salaat.nextPrayer = "Fajr"
        salaat.nextTime = salaat.fajr
    }

    function buildScrollText() {
        var list = [
            "Fajr: " + salaat.fajr,
            "Sunrise: " + salaat.sunrise,
            "Dhuhr: " + salaat.dhuhr,
            "Asr: " + salaat.asr,
            "Maghrib: " + salaat.maghrib,
            "Isha: " + salaat.isha
        ]
        var joined = list.join("  \u2502  ") + "  \u2502  "
        salaat.scrollText = joined
        salaat.scrollOffset = 0
        salaat.tooltipText = "Prayer Times" + (salaat.locationName ? " \u2014 " + salaat.locationName : "") + "\n\n"
            + list.join("\n")
            + "\n\nNext: " + salaat.nextPrayer + " at " + salaat.nextTime
        salaat.updateDisplay()
    }

    function updateDisplay() {
        if (salaat.scrollText.length === 0) return
        var len = salaat.scrollText.length
        var shift = salaat.scrollOffset % len
        var rotated = salaat.scrollText.substring(shift) + salaat.scrollText.substring(0, shift)
        var display = rotated + salaat.scrollText
        salaat._displayText = display.substring(0, visibleWidth)
    }
}
