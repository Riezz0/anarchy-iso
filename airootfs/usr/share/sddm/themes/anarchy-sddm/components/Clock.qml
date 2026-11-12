/**
 * Pixie SDDM - Clock Component
 * Author: xCaptaiN09
 */
import QtQuick

Item {
    id: clock

    property string backgroundSource: ""
    property string fontFamily: "JetBrainsMonoNerdFontMono-Regular"
    property color baseAccent: pywalColors.loaded ? pywalColors.color2 : config.accentColor
    property string hourStr: ""
    property string minStr: ""

    PywalColors {
        id: pywalColors
    }

    function updateTime() {
        var date = new Date();
        var hours = date.getHours();
        var minutes = date.getMinutes();

        if (config.use24HourClock !== "true") {
            hours = hours % 12;
            if (hours === 0) hours = 12;
        }

        clock.hourStr = hours < 10 ? "0" + hours : "" + hours;
        clock.minStr = minutes < 10 ? "0" + minutes : "" + minutes;
    }

    Component.onCompleted: updateTime()

    Row {
        anchors.centerIn: parent
        spacing: 10

        Column {
            spacing: 0
            Text {
                text: clock.hourStr.charAt(0)
                color: pywalColors.loaded ? pywalColors.color2 : config.accentColor
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
                color: pywalColors.loaded ? pywalColors.color3 : Qt.darker(config.accentColor, 1.2)
                font.pixelSize: 200
                font.family: clock.fontFamily
                font.weight: Font.Medium
                width: 100
                horizontalAlignment: Text.AlignHCenter
                antialiasing: true
                renderType: Text.NativeRendering
            }
        }

        Column {
            spacing: 0
            Text {
                text: clock.hourStr.charAt(1)
                color: pywalColors.loaded ? pywalColors.color2 : config.accentColor
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
                color: pywalColors.loaded ? pywalColors.color3 : Qt.darker(config.accentColor, 1.2)
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
