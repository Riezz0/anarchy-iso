// ═══════════════════════════════════════════════════════════════════════════════
// SystemStats Module - Hardware Monitoring Data
// ═══════════════════════════════════════════════════════════════════════════════
// Polls CPU/GPU temperatures and usage percentages, plus RAM usage.
// Runs background processes on a timer to keep stats up to date.
//
// Usage in shell.qml:
//   SystemStats { id: stats }
//   stats.gpuTempRaw   // GPU temperature in °C
//   stats.cpuTempRaw   // CPU temperature in °C
//   stats.cpuUsage     // CPU usage 0–100
//   stats.gpuUsage     // GPU usage 0–100
//   stats.ramUsage     // RAM usage 0–100
//   stats.ramUsedGB    // RAM used in GB
//   stats.ramTotalGB   // RAM total in GB
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: statsRoot

    // ═══════════════════════════════════════════════════════════════════════════
    // Properties
    // ═══════════════════════════════════════════════════════════════════════════

    property string gpuTemp:     "GPU: --"
    property string cpuTemp:     "CPU: --"
    property real   gpuTempRaw:  0
    property real   cpuTempRaw:  0
    property real   cpuUsage:    0
    property real   gpuUsage:    0
    property real   ramUsage:    0
    property real   ramUsedGB:   0
    property real   ramTotalGB:  0
    property var    drives:      []

    // ═══════════════════════════════════════════════════════════════════════════
    // Processes
    // ═══════════════════════════════════════════════════════════════════════════

    // ── GPU Temperature ─────────────────────────────────────────────────────
    Process {
        id:      gpuTempProc
        command: ["bash", "/usr/local/bin/gpu.sh"]
        running: false

        stdout: SplitParser {
            onRead: line => {
                const trimmed = line.trim()
                if (trimmed) {
                    statsRoot.gpuTemp = "GPU: " + trimmed
                    const val = parseFloat(trimmed)
                    if (!isNaN(val)) statsRoot.gpuTempRaw = val
                }
            }
        }
    }

    // ── CPU Temperature ─────────────────────────────────────────────────────
    Process {
        id:      cpuTempProc
        command: ["bash", "/usr/local/bin/cpu.sh"]
        running: false

        stdout: SplitParser {
            onRead: line => {
                const trimmed = line.trim()
                if (trimmed) {
                    statsRoot.cpuTemp = "CPU: " + trimmed
                    const val = parseFloat(trimmed)
                    if (!isNaN(val)) statsRoot.cpuTempRaw = val
                }
            }
        }
    }

    // ── CPU/GPU Usage + RAM ─────────────────────────────────────────────────
    Process {
        id:      usageProc
        command: ["bash", "-c",
            "echo \"CPU_USAGE:$(top -bn1 | grep 'Cpu(s)' | awk '{print 100-$8}')\"; " +
            "echo \"GPU_USAGE:$(cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null)\"; " +
            "echo \"RAM_USED:$(free -m | awk '/Mem:/{print $3}')\"; " +
            "echo \"RAM_TOTAL:$(free -m | awk '/Mem:/{print $2}')\""
        ]
        running: false

        property string output: ""

        stdout: SplitParser {
            onRead: line => { usageProc.output += line + "\n" }
        }

        onRunningChanged: {
            if (!running && usageProc.output) {
                var lines = usageProc.output.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i]
                    if (line.startsWith("CPU_USAGE:")) {
                        var val = parseFloat(line.substring(10).trim())
                        statsRoot.cpuUsage = isNaN(val) ? 0 : Math.min(val, 100)
                    } else if (line.startsWith("GPU_USAGE:")) {
                        var val = parseFloat(line.substring(10).trim())
                        statsRoot.gpuUsage = isNaN(val) ? 0 : Math.min(val, 100)
                    } else if (line.startsWith("RAM_USED:")) {
                        var used = parseFloat(line.substring(9).trim())
                        if (!isNaN(used)) statsRoot.ramUsedGB = used / 1024
                    } else if (line.startsWith("RAM_TOTAL:")) {
                        var total = parseFloat(line.substring(10).trim())
                        if (!isNaN(total)) {
                            statsRoot.ramTotalGB = total / 1024
                            statsRoot.ramUsage = (statsRoot.ramUsedGB / statsRoot.ramTotalGB) * 100
                        }
                    }
                }
                usageProc.output = ""
            }
        }
    }

    // ── Disk Usage ────────────────────────────────────────────────────────
    Process {
        id:      diskProc
        command: ["bash", "-c",
            "lsblk -b -d -n -o NAME,SIZE 2>/dev/null | grep -E '^(sd|nvme|vd|xvd)' | while read dname dsize; do " +
            "mp=$(findmnt -n -r -o TARGET /dev/${dname}p2 2>/dev/null | head -1); " +
            "[ -z \"$mp\" ] && mp=$(findmnt -n -r -o TARGET /dev/${dname}1 2>/dev/null | head -1); " +
            "[ -z \"$mp\" ] && mp=$(findmnt -n -r -o TARGET /dev/${dname} 2>/dev/null | head -1); " +
            "if [ -n \"$mp\" ]; then " +
            "df -B1 \"$mp\" 2>/dev/null | tail -1 | awk -v dn=\"$dname\" -v ds=\"$dsize\" '{print dn\"|\"ds\"|\"$2\"|\"$3\"|\"$4}'; " +
            "else " +
            "echo \"$dname|$dsize|--|--|--\"; " +
            "fi; " +
            "done"
        ]
        running: false

        property string output: ""

        stdout: SplitParser {
            onRead: line => { diskProc.output += line + "\n" }
        }

        onRunningChanged: {
            if (!running && diskProc.output) {
                var drives = []
                var lines = diskProc.output.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line.length === 0) continue
                    var parts = line.split("|")
                    if (parts.length >= 5) {
                        var totalBytes = parseInt(parts[2])
                        var usedBytes = parseInt(parts[3])
                        var availBytes = parseInt(parts[4])
                        var driveSize = parseInt(parts[1])
                        drives.push({
                            name: parts[0],
                            size: isNaN(driveSize) ? "--" : formatBytes(driveSize),
                            totalBytes: isNaN(totalBytes) ? 0 : totalBytes,
                            usedBytes: isNaN(usedBytes) ? 0 : usedBytes,
                            total: isNaN(totalBytes) || totalBytes <= 0 ? "--" : formatBytes(totalBytes),
                            used: isNaN(usedBytes) || usedBytes <= 0 ? "--" : formatBytes(usedBytes),
                            avail: isNaN(availBytes) || availBytes <= 0 ? "--" : formatBytes(availBytes)
                        })
                    }
                }
                statsRoot.drives = drives
                diskProc.output = ""
            }
        }

        function formatBytes(bytes) {
            if (bytes >= 1099511627776) return (bytes / 1099511627776).toFixed(1) + "T"
            if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(1) + "G"
            if (bytes >= 1048576) return (bytes / 1048576).toFixed(0) + "M"
            return bytes + "B"
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Timer - Poll every 3 seconds
    // ═══════════════════════════════════════════════════════════════════════════

    Timer {
        interval:         3000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: {
            if (!gpuTempProc.running) gpuTempProc.running = true
            if (!cpuTempProc.running) cpuTempProc.running = true
            if (!usageProc.running)   usageProc.running = true
            if (!diskProc.running)    diskProc.running = true
        }
    }
}