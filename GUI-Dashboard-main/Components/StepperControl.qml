import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0

// Custom Control for adjusting values (Volume or AC)
Control {
    id: control
    background: null
    property int value: 0 // Current value
    property int maximumValue: 100 // Maximum allowable value
    property int minimumValue: 0 // Minimum allowable value
    property bool isVolume: false // True for volume, False for AC (temperature)

    contentItem: RowLayout {
        spacing: 10 // Spacing between items in the row
        anchors.centerIn: parent // Center the row within the parent

        // Button to decrease the value
        IconButton {
            id: decreaseButton
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter // Align to the left and vertically centered
            icon.source: "qrc:/icons/stepper_icons/right-arrow.svg" // Icon for the decrease button
            enabled: value > minimumValue // Enable only if the current value is above the minimum
            onClicked: {
                if (value > minimumValue) {
                    value -= 1 // Decrease the value by 1
                    if (value < minimumValue) value = minimumValue // Ensure value does not drop below the minimum
                    decreaseIndicator.visible = true // Show the decrease indicator
                }
            }

            // Indicator for decrease action
            Text {
                id: decreaseIndicator
                text: "<" // Visual indicator for decrease
                font.family: Style.fontFamily // Font family for the text
                font.pixelSize: 18 // Font size
                color: "#F44336" // Red color for the decrease indicator
                anchors.centerIn: parent // Center the indicator within the button
                visible: value > minimumValue // Visible only if the value is above the minimum
            }
        }

        // Display the current value
        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter // Center the text horizontally and vertically
            text: isVolume ? value + "%" : value + "°C" // Show percentage for volume, °C for AC
            font.pixelSize: 42 // Font size for the value
            font.family: Style.fontFamily // Font family for the text
            color: Style.black50 // Text color
        }

        // Button to increase the value
        IconButton {
            id: increaseButton
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter // Align to the right and vertically centered
            enabled: value < maximumValue // Enable only if the current value is below the maximum
            onClicked: {
                if (value < maximumValue) {
                    value += 1 // Increase the value by 1
                    if (value > maximumValue) value = maximumValue // Ensure value does not exceed the maximum
                    increaseIndicator.visible = true // Show the increase indicator
                }
            }

            // Indicator for increase action
            Text {
                id: increaseIndicator
                text: ">" // Visual indicator for increase
                font.family: Style.fontFamily // Font family for the text
                font.pixelSize: 18 // Font size
                color: "#4CAF50" // Green color for the increase indicator
                anchors.centerIn: parent // Center the indicator within the button
                visible: value < maximumValue // Visible only if the value is below the maximum
            }
        }
    }
}
