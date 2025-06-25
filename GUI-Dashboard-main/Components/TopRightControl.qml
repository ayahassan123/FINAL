import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0

RowLayout {
    spacing: 48
    property int temp: 34 // Fixed temperature at 34°C
    property bool airbagOn: false
    property int speed: 80 // Dynamic speed property, default to 80 km/h

    // Text for displaying time and date
    Text {
        id: timeDateText
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        text: "" // Will be updated by the Timer
        font.family: "Inter"
        font.pixelSize: 18
        font.bold: Font.DemiBold
        color: "#87CEEB"

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                var currentDate = new Date();
                var timeString = Qt.formatTime(currentDate, "HH:mm:ss");
                var dateString = Qt.formatDate(currentDate, "dd/MM/yyyy");
                timeDateText.text = timeString + "   " + dateString;
            }
        }

        Component.onCompleted: {
            var currentDate = new Date();
            var timeString = Qt.formatTime(currentDate, "HH:mm:ss");
            var dateString = Qt.formatDate(currentDate, "dd/MM/yyyy");
            timeDateText.text = timeString + "   " + dateString;
        }
    }

    // Weather and Temperature
    RowLayout {
        spacing: 10 // Spacing between the weather icon and temperature text
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Rectangle {
            width: 27 // Small rectangle size
            height: 27 // Small rectangle size
            color: "transparent" // Transparent background
            border.color: "lightgray" // Optional light border
            border.width: 1 // Thin border
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            Image {
                id: weatherIcon
                anchors.centerIn: parent
                source: "qrc:/icons/weather/sunny.svg" // Fixed to sunny icon since temp is 34
                width: 27 // Extremely small size
                height: 27 // Extremely small size
                fillMode: Image.PreserveAspectFit

                // Debug image loading
                onStatusChanged: {
                    if (status === Image.Error) {
                        console.log("Error loading weather icon:", source)
                    } else if (status === Image.Ready) {
                        console.log("Weather icon loaded successfully:", source)
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            text: "%0ºC".arg(temp)
            font.family: "Inter"
            font.pixelSize: 18
            font.bold: Font.DemiBold
            color: "#87CEEB"
        }
    }

    Control {
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        implicitHeight: 38
        background: Rectangle {
            color: Style.isDark ? Style.alphaColor(Style.black, 0.55) : Style.black20
            radius: 7
        }
        contentItem: RowLayout {
            spacing: 10
            anchors.centerIn: parent
            Image {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.leftMargin: 10
                source: "qrc:/icons/top_header_icons/airbag_.svg"
            }
            Text {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: 10
                text: airbagOn ? "PASSENGER\nAIRBAG ON" : "PASSENGER\nAIRBAG OFF"
                font.family: Style.fontFamily
                font.bold: Font.Bold
                font.pixelSize: 12
                color: Style.white
            }
        }
    }
}
