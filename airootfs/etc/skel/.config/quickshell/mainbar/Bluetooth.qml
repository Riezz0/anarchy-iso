// ═══════════════════════════════════════════════════════════════════════════════
// Bluetooth Model - Quickshell Bluetooth Integration
// ═══════════════════════════════════════════════════════════════════════════════
// This module wraps the Quickshell.Bluetooth API to provide:
//   - Adapter state management (enable/disable)
//   - Device listing and connection control
//   - Icon and color functions based on connection state
//
// Usage in shell.qml:
//   Bluetooth { id: bt }
//   bt.btIcon()     // Returns Nerd Font icon based on state
//   bt.btColor()    // Returns color based on connection state
//   bt.toggle()     // Toggle Bluetooth on/off
//   bt.enabled      // Boolean: is Bluetooth enabled?
//   bt.connectedCount // Number of connected devices
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Item {
    id: btRoot

    // ═══════════════════════════════════════════════════════════════════════════
    // Properties
    // ═══════════════════════════════════════════════════════════════════════════

    // ── Adapter Properties ────────────────────────────────────────────────────
    readonly property var    adapter:        Bluetooth.defaultAdapter
    readonly property bool   adapterValid:   adapter !== null && adapter !== undefined
    readonly property bool   enabled:        adapterValid && adapter.enabled
    readonly property string adapterName:    adapterValid ? adapter.name : "No Adapter"
    readonly property int    adapterState:   adapterValid ? adapter.state : BluetoothAdapterState.Disabled

    // ── Device Properties ─────────────────────────────────────────────────────
    readonly property var    devices:        adapterValid ? adapter.devices : []
    readonly property int    deviceCount:    adapterValid ? adapter.devices.count : 0
    readonly property int    connectedCount: {
        if (!adapterValid) return 0
        let count = 0
        for (let i = 0; i < adapter.devices.count; ++i) {
            const dev = adapter.devices.get(i)
            if (dev.connected) count++
        }
        return count
    }

    // ── State Flags ───────────────────────────────────────────────────────────
    readonly property bool isDisabled:    adapterState === BluetoothAdapterState.Disabled
    readonly property bool isEnabled:     adapterState === BluetoothAdapterState.Enabled
    readonly property bool isEnabling:    adapterState === BluetoothAdapterState.Enabling
    readonly property bool isDisabling:   adapterState === BluetoothAdapterState.Disabling
    readonly property bool isBlocked:     adapterState === BluetoothAdapterState.Blocked

    // ═══════════════════════════════════════════════════════════════════════════
    // Functions
    // ═══════════════════════════════════════════════════════════════════════════

    // ── Bluetooth Icon ────────────────────────────────────────────────────────
    // Returns a Nerd Font icon based on Bluetooth state:
    //   󰂲 = Disabled/No adapter
    //   󰂱 = Connected (device connected)
    //   󰂯 = Enabled (no device connected)
    function btIcon() {
        if (!adapterValid || isDisabled) return "󰂲"
        if (connectedCount > 0)          return "󰂱"
        return "󰂯"
    }

    // ── Toggle Bluetooth ──────────────────────────────────────────────────────
    // Toggles the adapter enabled state
    function toggle() {
        if (!adapterValid) return
        adapter.enabled = !enabled
    }

    // ── Icon Color ────────────────────────────────────────────────────────────
    // Returns color based on connection state:
    //   theme.muted  = Disabled/No adapter
    //   theme.color6 = Connected (green)
    //   theme.color4 = Enabled but no connection (cyan)
    function btColor() {
        if (!adapterValid || isDisabled) return theme.muted
        if (connectedCount > 0)          return theme.color6
        return theme.color4
    }

    // ── Connect/Disconnect Device ─────────────────────────────────────────────
    // Toggles connection state for a specific device
    function connectDevice(device) {
        if (!device) return
        if (device.connected) {
            device.disconnect()
        } else {
            device.connect()
        }
    }

    // ── State Label ───────────────────────────────────────────────────────────
    // Returns human-readable state description
    function stateLabel() {
        if (!adapterValid)            return "No Adapter"
        if (isDisabled)               return "Disabled"
        if (isEnabling)               return "Enabling..."
        if (isDisabling)              return "Disabling..."
        if (isBlocked)                return "Blocked"
        if (connectedCount > 0)       return connectedCount + " connected"
        return "On"
    }
}