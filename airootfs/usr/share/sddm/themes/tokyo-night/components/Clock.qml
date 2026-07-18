/**
 * Pixie SDDM - Clock Component
 * Author: xCaptaiN09
 */
import QtQuick

Item {
    id: clock

    property string backgroundSource: ""
    property color defaultHoursColor: walColors.color2
    property color defaultMinutesColor: walColors.color3
    property string fontFamily: "JetBrainsMonoNerdFontMono-Regular" // Overridden by Main.qml
    property color baseAccent: config.accentColor
    property color smartHoursColor: defaultHoursColor
    property color smartMinutesColor: defaultMinutesColor
    property string hourStr: ""
    property string minStr: ""

    function updateTime() {
        var date = new Date();
        var hours = date.getHours();
        var minutes = date.getMinutes();

        // If 24-hour is not strictly "true", convert to 12-hour format
        if (config.use24HourClock !== "true") {
            hours = hours % 12;
            if (hours === 0) hours = 12; // Midnight becomes 12
        }

        clock.hourStr = hours < 10 ? "0" + hours : "" + hours;
        clock.minStr = minutes < 10 ? "0" + minutes : "" + minutes;
    }

    function updateColors() {
        var base = clock.baseAccent;

        if (base.hsvSaturation < 0.15) {
            clock.smartHoursColor = Qt.lighter(base, 1.3);
            clock.smartMinutesColor = Qt.darker(base, 1.4);
            return;
        }

        if (base.hsvValue < 0.5) {
            clock.smartHoursColor = Qt.hsva(base.hsvHue, 0.7, 0.9, 1.0);
            clock.smartMinutesColor = Qt.hsva(base.hsvHue, 0.45, 0.85, 1.0);
        } else if (base.hsvValue > 0.8 && base.hsvSaturation < 0.2) {
            clock.smartHoursColor = Qt.hsva(base.hsvHue, 0.8, 0.7, 1.0);
            clock.smartMinutesColor = Qt.hsva(base.hsvHue, 0.5, 0.75, 1.0);
        } else {
            clock.smartHoursColor = Qt.hsva(base.hsvHue, Math.min(1.0, base.hsvSaturation * 1.3), 0.95, 1.0);
            clock.smartMinutesColor = Qt.hsva(base.hsvHue, Math.min(1.0, base.hsvSaturation * 0.75), 0.92, 1.0);
        }
    }

    onBaseAccentChanged: updateColors()
    Component.onCompleted: {
        updateColors();
        updateTime();
    }

    // Monospace-optimized stacked clock layout
    // Uses a single Row so each digit column sits side by side naturally
    Row {
        anchors.centerIn: parent
        spacing: 10

        // Hours column (HH)
        Column {
            spacing: 0
            Text {
                text: clock.hourStr.charAt(0)
                color: clock.smartHoursColor
                font.pixelSize: 200
                font.family: clock.fontFamily
                font.weight: Font.Medium
                width: 100
                horizontalAlignment: Text.AlignHCenter
                antialiasing: true
                renderType: Text.NativeRendering
            }
            Text {
                text: clock.minStr.charAt(0)
                color: clock.smartMinutesColor
                font.pixelSize: 200
                font.family: clock.fontFamily
                font.weight: Font.Medium
                width: 100
                horizontalAlignment: Text.AlignHCenter
                antialiasing: true
                renderType: Text.NativeRendering
            }
        }

        // Minutes column (MM)
        Column {
            spacing: 0
            Text {
                text: clock.hourStr.charAt(1)
                color: clock.smartHoursColor
                font.pixelSize: 200
                font.family: clock.fontFamily
                font.weight: Font.Medium
                width: 100
                horizontalAlignment: Text.AlignHCenter
                antialiasing: true
                renderType: Text.NativeRendering
            }
            Text {
                text: clock.minStr.charAt(1)
                color: clock.smartMinutesColor
                font.pixelSize: 200
                font.family: clock.fontFamily
                font.weight: Font.Medium
                width: 100
                horizontalAlignment: Text.AlignHCenter
                antialiasing: true
                renderType: Text.NativeRendering
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateTime()
    }
}
