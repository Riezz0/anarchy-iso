// ═══════════════════════════════════════════════════════════════════════════════
// Weather Module - Quickshell Weather Integration
// ═══════════════════════════════════════════════════════════════════════════════
// Fetches weather data from open-meteo.com using live IP geolocation.
// Two-step process: ipinfo.io → coordinates, then open-meteo → weather.
//
// Usage in shell.qml:
//   Weather { id: weather }
//   weather.tempDisplay()       // "26°C"
//   weather.locationDisplay()   // "Johannesburg, South Africa"
//   weather.shortCondition()    // "Partly cloudy"
//   weather.weatherIconText()   // Nerd Font weather icon
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: weatherRoot

    // ═══════════════════════════════════════════════════════════════════════════
    // Properties
    // ═══════════════════════════════════════════════════════════════════════════

    property real   latitude:    0
    property real   longitude:   0
    property string city:        ""
    property string country:     ""
    property string tempC:       "--"
    property string feelsLikeC:  "--"
    property string humidity:    "--"
    property string windSpeed:   "--"
    property string windDir:     "--"
    property string condition:   "Loading..."
    property string pressure:    "--"
    property string uvIndex:     "--"
    property string visibility:  "--"
    property string cloudCover:  "--"
    property string weatherIcon: ""
    property bool   loaded:      false

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
                weatherRoot.parseGeo(geoProc.buffer)
                geoProc.buffer = ""
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Step 2: Fetch weather from open-meteo.com
    // ═══════════════════════════════════════════════════════════════════════════

    Process {
        id:      weatherProc
        command: ["curl", "-s", "--max-time", "10", ""]
        running: false

        property string buffer: ""

        function fetch() {
            var url = "https://api.open-meteo.com/v1/forecast"
                + "?latitude=" + weatherRoot.latitude
                + "&longitude=" + weatherRoot.longitude
                + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,cloud_cover"
                + "&daily=uv_index_max,visibility_max"
                + "&timezone=auto"
            command = ["curl", "-s", "--max-time", "10", url]
            buffer = ""
            running = true
        }

        stdout: SplitParser {
            onRead: line => {
                weatherProc.buffer += line + "\n"
            }
        }

        onRunningChanged: {
            if (!running) {
                weatherRoot.parseWeather(weatherProc.buffer)
                weatherProc.buffer = ""
            }
        }
    }

    // ── Timers ───────────────────────────────────────────────────────────────

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

    // Refresh weather every 15 minutes
    Timer {
        interval:         900000
        running:          true
        repeat:           true
        triggeredOnStart: false
        onTriggered: {
            if (!weatherProc.running) {
                weatherProc.fetch()
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Functions
    // ═══════════════════════════════════════════════════════════════════════════

    function parseGeo(jsonStr) {
        try {
            const data = JSON.parse(jsonStr)
            weatherRoot.latitude  = parseFloat(data.loc.split(",")[0])
            weatherRoot.longitude = parseFloat(data.loc.split(",")[1])
            weatherRoot.city      = data.city || ""
            weatherRoot.country   = data.country || ""
        } catch (e) {
            console.warn("Weather: failed to parse geo, using fallback")
        }
        if (!weatherProc.running) {
            weatherProc.fetch()
        }
    }

    function parseWeather(jsonStr) {
        try {
            const data = JSON.parse(jsonStr)
            const cc   = data.current

            weatherRoot.tempC      = Math.round(cc.temperature_2m).toString()
            weatherRoot.feelsLikeC = Math.round(cc.apparent_temperature).toString()
            weatherRoot.humidity   = cc.relative_humidity_2m.toString()
            weatherRoot.windSpeed  = Math.round(cc.wind_speed_10m).toString()
            weatherRoot.windDir    = getWindDir(cc.wind_direction_10m)
            weatherRoot.condition  = getConditionText(cc.weather_code)
            weatherRoot.pressure   = Math.round(cc.surface_pressure).toString()
            weatherRoot.cloudCover = cc.cloud_cover.toString()

            // UV and visibility from daily max
            if (data.daily && data.daily.uv_index_max) {
                weatherRoot.uvIndex = data.daily.uv_index_max[0].toString()
            }
            if (data.daily && data.daily.visibility_max) {
                weatherRoot.visibility = Math.round(data.daily.visibility_max[0] / 1000).toString()
            }

            weatherRoot.weatherIcon = getWeatherIcon(cc.weather_code)
            weatherRoot.loaded      = true
        } catch (e) {
            console.warn("Weather: failed to parse response:", e)
        }
    }

    function getWindDir(degrees) {
        const dirs = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                      "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        const idx = Math.round(degrees / 22.5) % 16
        return dirs[idx]
    }

    function getConditionText(code) {
        const c = parseInt(code)
        if (c === 0)  return "Clear sky"
        if (c <= 3)   return "Partly cloudy"
        if (c <= 49)  return "Fog"
        if (c <= 69)  return "Drizzle"
        if (c <= 79)  return "Snow"
        if (c <= 82)  return "Rain"
        if (c <= 86)  return "Snow showers"
        if (c <= 99)  return "Thunderstorm"
        return "Unknown"
    }

    function weatherIconText() {
        return weatherRoot.weatherIcon || "󰖐"
    }

    function tempDisplay() {
        return weatherRoot.tempC + "°C"
    }

    function locationDisplay() {
        if (weatherRoot.city && weatherRoot.country)
            return weatherRoot.city + ", " + weatherRoot.country
        return "Loading..."
    }

    function shortCondition() {
        return weatherRoot.condition
    }

    function refresh() {
        if (!geoProc.running && !weatherProc.running) {
            geoProc.buffer = ""
            geoProc.running = true
        }
    }

    // ── Weather Code → Nerd Font Icon ────────────────────────────────────────
    function getWeatherIcon(code) {
        const c = parseInt(code)

        // Clear
        if (c === 0)                          return "󰖨"
        // Partly cloudy
        if (c === 1 || c === 2)               return "󰖏"
        // Overcast
        if (c === 3)                          return "󰖐"
        // Fog
        if (c >= 45 && c <= 48)              return "󰖌"
        // Drizzle
        if (c >= 51 && c <= 67)              return "󰖒"
        // Snow
        if (c >= 71 && c <= 77)              return "󰖓"
        // Rain showers
        if (c >= 80 && c <= 82)              return "󰖒"
        // Snow showers
        if (c >= 85 && c <= 86)              return "󰖓"
        // Thunderstorm
        if (c >= 95 && c <= 99)              return "󰖓"

        return "󰖐"
    }
}