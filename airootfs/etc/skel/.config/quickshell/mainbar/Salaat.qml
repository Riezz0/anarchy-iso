// ═══════════════════════════════════════════════════════════════════════════════
// Salaat Module - Prayer Times via Aladhan API
// ═══════════════════════════════════════════════════════════════════════════════
// Fetches prayer times using live IP-based geolocation.
// Two-step process: ipinfo.io → coordinates, then Aladhan API → times.
//
// Usage in shell.qml:
//   Salaat { id: salaat }
//   salaat.scrollText       // scrolling marquee string
//   salaat.tooltipText      // static full list for tooltip
//   salaat.loaded           // true when data is available
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: salaat

    // ═══════════════════════════════════════════════════════════════════════════
    // Properties
    // ═══════════════════════════════════════════════════════════════════════════

    property real   latitude:   -26.2041
    property real   longitude:  28.0473
    property string locationName: ""

    property string fajr:    "--:--"
    property string sunrise: "--:--"
    property string dhuhr:   "--:--"
    property string asr:     "--:--"
    property string maghrib: "--:--"
    property string isha:    "--:--"

    property string nextPrayer: ""
    property string nextTime:   ""
    property bool   loaded:     false

    // Scrolling state
    property string scrollText:  ""
    property string tooltipText: ""
    property int    scrollOffset: 0

    readonly property int visibleWidth: 28

    // ═══════════════════════════════════════════════════════════════════════════
    // Step 1: Fetch geolocation from ipinfo.io
    // ═══════════════════════════════════════════════════════════════════════════

    Process {
        id:      geoProc
        command: ["curl", "-s", "--max-time", "10", "https://ipinfo.io/json"]
        running: false

        property string buffer: ""

        stdout: SplitParser {
            onRead: line => {
                geoProc.buffer += line + "\n"
            }
        }

        onRunningChanged: {
            if (!running) {
                salaat.parseGeo(geoProc.buffer)
                geoProc.buffer = ""
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Step 2: Fetch prayer times from Aladhan API
    // ═══════════════════════════════════════════════════════════════════════════

    Process {
        id:      prayerProc
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

        stdout: SplitParser {
            onRead: line => {
                prayerProc.buffer += line + "\n"
            }
        }

        onRunningChanged: {
            if (!running) {
                salaat.parsePrayers(prayerProc.buffer)
                prayerProc.buffer = ""
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Timers
    // ═══════════════════════════════════════════════════════════════════════════

    // Fetch location once on startup
    Timer {
        interval: 1000
        running: true
        repeat: false
        onTriggered: {
            if (!geoProc.running) {
                geoProc.buffer = ""
                geoProc.running = true
            }
        }
    }

    // Refresh prayer times every 30 minutes
    Timer {
        interval:         1800000
        running:          true
        repeat:           true
        triggeredOnStart: false
        onTriggered: {
            if (!prayerProc.running) {
                prayerProc.fetch()
            }
        }
    }

    // Update scroll position every second
    Timer {
        interval: 1000
        running:  salaat.loaded
        repeat:   true
        onTriggered: {
            salaat.scrollOffset = (salaat.scrollOffset + 1) % salaat.scrollText.length
            salaat.updateDisplay()
        }
    }

    // Recalculate next prayer every minute
    Timer {
        interval:         60000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: {
            if (salaat.loaded) {
                salaat.findNextPrayer()
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Functions
    // ═══════════════════════════════════════════════════════════════════════════

    function todayTimestamp() {
        const now = new Date()
        return Math.floor(now.getTime() / 1000)
    }

    function parseGeo(jsonStr) {
        try {
            const data = JSON.parse(jsonStr)
            salaat.latitude    = parseFloat(data.loc.split(",")[0])
            salaat.longitude   = parseFloat(data.loc.split(",")[1])
            salaat.locationName = (data.city || "") + (data.country ? ", " + data.country : "")
        } catch (e) {
            console.warn("Salaat: failed to parse geo, using fallback coords")
        }
        // Now fetch prayer times with resolved coordinates
        if (!prayerProc.running) {
            prayerProc.fetch()
        }
    }

    function parsePrayers(jsonStr) {
        try {
            const data = JSON.parse(jsonStr)
            const t = data.data.timings

            salaat.fajr    = t.Fajr    || "--:--"
            salaat.sunrise = t.Sunrise || "--:--"
            salaat.dhuhr   = t.Dhuhr   || "--:--"
            salaat.asr     = t.Asr     || "--:--"
            salaat.maghrib = t.Maghrib || "--:--"
            salaat.isha    = t.Isha    || "--:--"

            // Strip timezone suffixes like "(SAST)" from times
            salaat.fajr    = salaat.cleanTime(salaat.fajr)
            salaat.sunrise = salaat.cleanTime(salaat.sunrise)
            salaat.dhuhr   = salaat.cleanTime(salaat.dhuhr)
            salaat.asr     = salaat.cleanTime(salaat.asr)
            salaat.maghrib = salaat.cleanTime(salaat.maghrib)
            salaat.isha    = salaat.cleanTime(salaat.isha)

            salaat.loaded = true
            salaat.findNextPrayer()
            salaat.buildScrollText()
        } catch (e) {
            console.warn("Salaat: failed to parse prayer times:", e)
        }
    }

    function cleanTime(t) {
        // Remove anything after space or parenthesis: "05:12 (SAST)" → "05:12"
        const idx = t.indexOf(" ")
        return idx > 0 ? t.substring(0, idx) : t
    }

    function findNextPrayer() {
        const now = new Date()
        const prayers = [
            { name: "Fajr",    time: salaat.fajr },
            { name: "Sunrise", time: salaat.sunrise },
            { name: "Dhuhr",   time: salaat.dhuhr },
            { name: "Asr",     time: salaat.asr },
            { name: "Maghrib", time: salaat.maghrib },
            { name: "Isha",    time: salaat.isha }
        ]

        for (let i = 0; i < prayers.length; i++) {
            const p = prayers[i]
            if (p.time === "--:--") continue

            const parts = p.time.split(":")
            const prayDate = new Date(now)
            prayDate.setHours(parseInt(parts[0]), parseInt(parts[1]), 0, 0)

            if (prayDate > now) {
                salaat.nextPrayer = p.name
                salaat.nextTime = p.time
                return
            }
        }

        // All prayers passed today — show tomorrow's Fajr
        salaat.nextPrayer = "Fajr"
        salaat.nextTime = salaat.fajr
    }

    function buildScrollText() {
        const list = [
            "Fajr: "    + salaat.fajr,
            "Sunrise: " + salaat.sunrise,
            "Dhuhr: "   + salaat.dhuhr,
            "Asr: "     + salaat.asr,
            "Maghrib: " + salaat.maghrib,
            "Isha: "    + salaat.isha
        ]
        const joined = list.join("  |  ") + "  |  "
        salaat.scrollText = joined
        salaat.scrollOffset = 0

        // Tooltip is the static full list
        salaat.tooltipText = "Prayer Times" + (salaat.locationName ? " — " + salaat.locationName : "") + "\n\n"
            + list.join("\n")
            + "\n\nNext: " + salaat.nextPrayer + " at " + salaat.nextTime

        salaat.updateDisplay()
    }

    function updateDisplay() {
        if (salaat.scrollText.length === 0) return
        const len = salaat.scrollText.length
        const shift = salaat.scrollOffset % len
        const rotated = salaat.scrollText.substring(shift) + salaat.scrollText.substring(0, shift)
        // Pad to at least visibleWidth so the bar doesn't resize
        const display = rotated + salaat.scrollText
        // Expose for bar widget to bind to
        salaat._displayText = display.substring(0, visibleWidth)
    }

    // Internal display text — updated by scroll timer
    property string _displayText: ""
}
