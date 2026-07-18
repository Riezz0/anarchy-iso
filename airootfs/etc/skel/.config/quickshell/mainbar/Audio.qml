// ═══════════════════════════════════════════════════════════════════════════════
// Audio Module - Pipewire Audio Control
// ═══════════════════════════════════════════════════════════════════════════════
// Wraps Pipewire audio sink for volume control, mute toggle, and icon display.
//
// Usage in shell.qml:
//   Audio { id: audio }
//   audio.volumeLevel     // 0.0 – 1.0
//   audio.volumeMuted     // bool
//   audio.volumeIcon()    // Nerd Font icon string
//   audio.setVolume(0.5)  // Set volume (0.0 – 1.0)
//   audio.toggleMute()    // Toggle mute
// ═══════════════════════════════════════════════════════════════════════════════

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: audioRoot

    // ═══════════════════════════════════════════════════════════════════════════
    // Properties
    // ═══════════════════════════════════════════════════════════════════════════

    readonly property var  audioSink:   Pipewire.defaultAudioSink
    readonly property real volumeLevel: audioSink && audioSink.audio ? audioSink.audio.volume : 0
    readonly property bool volumeMuted: audioSink && audioSink.audio ? audioSink.audio.muted : false

    // ═══════════════════════════════════════════════════════════════════════════
    // Pipewire Object Tracker
    // ═══════════════════════════════════════════════════════════════════════════

    PwObjectTracker {
        objects: audioRoot.audioSink ? [audioRoot.audioSink] : []
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Functions
    // ═══════════════════════════════════════════════════════════════════════════

    /// Returns a Nerd Font icon based on current volume level and mute state
    function volumeIcon() {
        if (volumeMuted)          return "󰝟"
        if (volumeLevel <= 0)     return "󰖁"
        if (volumeLevel < 0.34)   return "󰕿"
        if (volumeLevel < 0.67)   return "󰖀"
        return "󰕾"
    }

    /// Sets volume to a clamped value (0.0 – 1.0) and unmutes if needed
    function setVolume(vol) {
        if (!audioSink || !audioSink.audio) return
        const clamped = Math.max(0, Math.min(1, vol))
        audioSink.audio.volume = clamped
        if (clamped > 0 && audioSink.audio.muted)
            audioSink.audio.muted = false
    }

    /// Toggles the mute state of the default audio sink
    function toggleMute() {
        if (!audioSink || !audioSink.audio) return
        audioSink.audio.muted = !audioSink.audio.muted
    }
}