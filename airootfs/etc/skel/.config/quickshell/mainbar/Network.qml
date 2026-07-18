import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: networkRoot

    property string interfaceName:  "--"
    property string ipAddress:      "--"
    property string connectionType: "disconnected"
    property string ssid:           ""
    property string signalStrength: "--"
    property string gateway:        "--"
    property string dns:            "--"
    property string macAddress:     "--"
    property bool   loaded:         false

    property string rxBytes:    "0"
    property string txBytes:    "0"
    property string rxRate:     "0 B/s"
    property string txRate:     "0 B/s"
    property real   prevRx:     0
    property real   prevTx:     0
    property string dnsInput:   ""

    property var    interfaces: []

    Process {
        id:      netListProc
        command: ["bash", "-c", "nmcli -t -f TYPE,STATE,DEVICE device"]
        running: false

        property string output: ""

        stdout: SplitParser {
            onRead: line => { netListProc.output += line + "\n" }
        }

        onRunningChanged: {
            if (!running) {
                networkRoot.parseDeviceList(netListProc.output)
                netListProc.output = ""
            }
        }
    }

    Process {
        id:      netProc
        command: ["bash", "-c", "nmcli -t -f TYPE,STATE,DEVICE device | grep -E ':connected|:connecting|:connected (auto)' | grep -v loopback | head -1 | cut -d: -f3"]
        running: false

        property string output: ""

        stdout: SplitParser {
            onRead: line => { netProc.output = line.trim() }
        }

        onRunningChanged: {
            if (!running) {
                const iface = netProc.output
                if (iface && iface !== "") {
                    networkRoot.interfaceName = iface
                    netDetailProc.command = ["bash", "-c", "nmcli -t device show " + iface]
                    netDetailProc.output = ""
                    netDetailProc.running = true
                } else {
                    netFallbackProc.running = true
                }
                netProc.output = ""
            }
        }
    }

    Process {
        id:      netFallbackProc
        command: ["bash", "-c", "ip route show default | awk '/default/ {print $5}' | head -1"]
        running: false

        property string output: ""

        stdout: SplitParser {
            onRead: line => { netFallbackProc.output = line.trim() }
        }

        onRunningChanged: {
            if (!running) {
                const iface = netFallbackProc.output
                if (iface && iface !== "" && iface !== "lo") {
                    networkRoot.interfaceName = iface
                    netDetailProc.command = ["bash", "-c", "nmcli -t device show " + iface + " 2>/dev/null || ip addr show " + iface]
                    netDetailProc.output = ""
                    netDetailProc.running = true
                } else {
                    networkRoot.connectionType = "disconnected"
                    networkRoot.ipAddress = "--"
                    networkRoot.gateway = "--"
                    networkRoot.dns = "--"
                    networkRoot.macAddress = "--"
                    networkRoot.loaded = true
                }
                netFallbackProc.output = ""
            }
        }
    }

    Process {
        id:      netDetailProc
        command: ["bash", "-c", "echo noop"]
        running: false

        property string output: ""

        stdout: SplitParser {
            onRead: line => { netDetailProc.output += line + "\n" }
        }

        onRunningChanged: {
            if (!running) {
                networkRoot.parseDetails(netDetailProc.output)
                netDetailProc.output = ""
            }
        }
    }

    Process {
        id:      wifiProc
        command: ["bash", "-c", "nmcli -t -f SIGNAL,SSID device wifi list --rescan yes"]
        running: false

        property string output: ""

        stdout: SplitParser {
            onRead: line => { wifiProc.output += line + "\n" }
        }

        onRunningChanged: {
            if (!running) {
                networkRoot.parseWifi(wifiProc.output)
                wifiProc.output = ""
            }
        }
    }

    Process {
        id:      trafficProc
        command: ["bash", "-c", "cat /sys/class/net/" + networkRoot.interfaceName + "/statistics/rx_bytes /sys/class/net/" + networkRoot.interfaceName + "/statistics/tx_bytes 2>/dev/null || echo 0\\n0"]
        running: false

        property string output: ""

        stdout: SplitParser {
            onRead: line => { trafficProc.output += line.trim() + "\n" }
        }

        onRunningChanged: {
            if (!running) {
                networkRoot.parseTraffic(trafficProc.output)
                trafficProc.output = ""
            }
        }
    }

    Process {
        id:      dnsChangeProc
        command: ["echo", "noop"]
        running: false

        onRunningChanged: {
            if (!running) {
                networkRoot.refresh()
            }
        }
    }

    Process {
        id:      ifaceChangeProc
        command: ["echo", "noop"]
        running: false

        onRunningChanged: {
            if (!running) {
                networkRoot.refresh()
            }
        }
    }

    Timer {
        interval:         5000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: {
            if (!netProc.running) {
                netProc.output = ""
                netProc.running = true
            }
            if (!netListProc.running) {
                netListProc.output = ""
                netListProc.running = true
            }
        }
    }

    Timer {
        interval:         1000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: {
            if (!trafficProc.running && networkRoot.interfaceName !== "--") {
                trafficProc.output = ""
                trafficProc.running = true
            }
        }
    }

    function parseDeviceList(data) {
        const lines = data.trim().split("\n")
        const result = []
        for (let i = 0; i < lines.length; i++) {
            const parts = lines[i].split(":")
            if (parts.length < 3) continue
            const type  = parts[0].trim()
            const state = parts.slice(1, -1).join(":").trim()
            const dev   = parts[parts.length - 1].trim()
            if (dev === "lo") continue
            result.push({ type: type, state: state, device: dev })
        }
        networkRoot.interfaces = result
    }

    function parseTraffic(data) {
        const lines = data.trim().split("\n")
        if (lines.length < 2) return
        const rx = parseFloat(lines[0]) || 0
        const tx = parseFloat(lines[1]) || 0

        const rxDelta = Math.max(0, rx - networkRoot.prevRx)
        const txDelta = Math.max(0, tx - networkRoot.prevTx)

        networkRoot.rxRate = formatBytes(rxDelta) + "/s"
        networkRoot.txRate = formatBytes(txDelta) + "/s"
        networkRoot.rxBytes = formatBytesTotal(rx)
        networkRoot.txBytes = formatBytesTotal(tx)

        networkRoot.prevRx = rx
        networkRoot.prevTx = tx
    }

    function parseDetails(data) {
        const lines = data.trim().split("\n")
        let foundNmcli = false
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            const idx = line.indexOf(":")
            if (idx < 0) continue
            const key = line.substring(0, idx).trim()
            const val = line.substring(idx + 1).trim()

            if (key === "GENERAL.TYPE") {
                foundNmcli = true
                if (val === "wifi" || val === "802-11-wireless")
                    networkRoot.connectionType = "wifi"
                else
                    networkRoot.connectionType = "ethernet"
            }

            if (key.startsWith("IP4.ADDRESS") && val && val !== "--") {
                networkRoot.ipAddress = val.split("/")[0]
            } else if (key === "IP4.GATEWAY" && val && val !== "--") {
                networkRoot.gateway = val
            } else if (key.startsWith("IP4.DNS") && val && val !== "--") {
                if (networkRoot.dns === "--")
                    networkRoot.dns = val
            } else if (key === "GENERAL.HWADDR" && val) {
                networkRoot.macAddress = val
            }
        }

        if (!foundNmcli) {
            netIpFallbackProc.running = true
            return
        }

        networkRoot.loaded = true

        if (networkRoot.connectionType === "wifi") {
            wifiProc.output = ""
            wifiProc.running = true
        }
    }

    Process {
        id:      netIpFallbackProc
        command: ["bash", "-c", "ip -4 addr show " + networkRoot.interfaceName + " 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1"]
        running: false

        property string output: ""

        stdout: SplitParser {
            onRead: line => { netIpFallbackProc.output = line.trim() }
        }

        onRunningChanged: {
            if (!running) {
                const ip = netIpFallbackProc.output
                if (ip && ip !== "") {
                    networkRoot.ipAddress = ip.split("/")[0]
                }
                networkRoot.connectionType = "ethernet"
                networkRoot.gateway = "--"
                networkRoot.dns = "--"
                networkRoot.macAddress = "--"
                networkRoot.loaded = true
                netIpFallbackProc.output = ""
            }
        }
    }

    function parseWifi(data) {
        const lines = data.trim().split("\n")
        for (let i = 0; i < lines.length; i++) {
            const idx = lines[i].indexOf(":")
            if (idx < 0) continue
            const signal = lines[i].substring(0, idx).trim()
            const name   = lines[i].substring(idx + 1).trim()
            if (!networkRoot.ssid) {
                networkRoot.signalStrength = signal
                networkRoot.ssid = name
            } else if (name === networkRoot.ssid) {
                networkRoot.signalStrength = signal
            }
        }
    }

    function formatBytes(bytes) {
        if (bytes < 1024) return bytes.toFixed(0) + " B"
        if (bytes < 1048576) return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1073741824) return (bytes / 1048576).toFixed(1) + " MB"
        return (bytes / 1073741824).toFixed(2) + " GB"
    }

    function formatBytesTotal(bytes) {
        if (bytes < 1024) return bytes.toFixed(0) + " B"
        if (bytes < 1048576) return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1073741824) return (bytes / 1048576).toFixed(1) + " MB"
        if (bytes < 1099511627776) return (bytes / 1073741824).toFixed(2) + " GB"
        return (bytes / 1099511627776).toFixed(2) + " TB"
    }

    function networkIcon() {
        if (networkRoot.connectionType === "disconnected") return "󰤭"
        if (networkRoot.connectionType === "wifi") {
            const s = parseInt(networkRoot.signalStrength) || 0
            if (s >= 80) return "󰤨"
            if (s >= 60) return "󰤥"
            if (s >= 40) return "󰤢"
            if (s >= 20) return "󰤟"
            return "󰤯"
        }
        return "󰈀"
    }

    function networkColor() {
        if (networkRoot.connectionType === "disconnected") return theme.muted
        if (networkRoot.connectionType === "wifi") {
            const s = parseInt(networkRoot.signalStrength) || 0
            if (s >= 60) return theme.color6
            return theme.color4
        }
        return theme.color6
    }

    function displayText() {
        if (networkRoot.connectionType === "disconnected") return "Offline"
        return networkRoot.ipAddress !== "--" ? networkRoot.ipAddress : networkRoot.interfaceName
    }

    function refresh() {
        if (!netProc.running) {
            netProc.output = ""
            netProc.running = true
        }
        if (!netListProc.running) {
            netListProc.output = ""
            netListProc.running = true
        }
    }

    function setDns(server) {
        if (!server || server.length < 7) return
        dnsChangeProc.command = ["bash", "-c",
            "nmcli connection modify " + networkRoot.interfaceName + " ipv4.dns \"" + server + "\" && " +
            "nmcli connection modify " + networkRoot.interfaceName + " ipv4.ignore-auto-dns yes && " +
            "nmcli connection up " + networkRoot.interfaceName]
        dnsChangeProc.running = true
    }

    function resetDns() {
        dnsChangeProc.command = ["bash", "-c",
            "nmcli connection modify " + networkRoot.interfaceName + " ipv4.ignore-auto-dns no && " +
            "nmcli connection modify " + networkRoot.interfaceName + " ipv4.dns \"\" && " +
            "nmcli connection up " + networkRoot.interfaceName]
        dnsChangeProc.running = true
    }

    function switchInterface(dev) {
        if (dev === networkRoot.interfaceName) return
        const targetIface = dev
        ifaceChangeProc.command = ["bash", "-c",
            "nmcli device disconnect " + networkRoot.interfaceName + " 2>/dev/null; " +
            "nmcli device connect " + targetIface]
        ifaceChangeProc.running = true
    }

    function connectionName() {
        if (networkRoot.connectionType === "disconnected") return "Disconnected"
        if (networkRoot.connectionType === "wifi") return "Wi-Fi"
        return "Ethernet"
    }
}
