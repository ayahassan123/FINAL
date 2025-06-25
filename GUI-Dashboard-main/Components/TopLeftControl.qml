import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0

RowLayout {
    id: root
    property int index: 0
    property int batteryPercentage: 98 // Start battery at 98%
    property bool isCharging: false
    property bool isPlugged: false
    spacing: 51

    // Timer for battery discharge (1% every 10 minutes)
    Timer {
        id: dischargeTimer
        interval: 600000 // 10 minutes
        running: !isPlugged && batteryPercentage > 0
        repeat: true
        onTriggered: batteryPercentage -= 1
    }

    // Timer for normal charging (1% every minute)
    Timer {
        id: chargeTimer
        interval: 60000 // 1 minute
        running: isPlugged && batteryPercentage < 100
        repeat: true
        onTriggered: batteryPercentage += 1
    }

    // Timer for fast charging (1% every 30 seconds when battery < 20%)
    Timer {
        id: fastChargeTimer
        interval: 30000 // 30 seconds
        running: isPlugged && batteryPercentage < 20
        repeat: true
        onTriggered: batteryPercentage += 1
    }

    // Toggle charging state when plugged/unplugged
    function togglePlugged() {
        isPlugged = !isPlugged;
        isCharging = isPlugged;
    }

    RowLayout {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        spacing: 4
        Text {
            // ... (Code for driving modes or other left-aligned elements)
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        spacing: 8

        // Plug icon
        Image {
            source: isPlugged ? "qrc:/icons/top_header_icons/plug.svg" : ""
            width: 16
            height: 16
            visible: isPlugged
        }

        // Battery display
        Rectangle {
            width: 28
            height: 14
            radius: 2
            border.color: Style.isDark ? Style.white : Style.black10
            border.width: 1
            color: "transparent"

            // Inner battery level indicator
            Rectangle {
                width: (parent.width - 2) * (batteryPercentage / 100)
                height: parent.height - 2
                anchors.left: parent.left
                anchors.leftMargin: 1
                anchors.verticalCenter: parent.verticalCenter
                radius: 1
                color: getBatteryColor() // Call function to determine battery color
            }

            // Battery cap
            Rectangle {
                width: 3
                height: 7
                anchors.right: parent.right
                anchors.rightMargin: -3
                anchors.verticalCenter: parent.verticalCenter
                color: Style.isDark ? Style.white : Style.black10
            }

            // Lightning icon for charging
            Image {
                anchors.centerIn: parent
                source: isCharging ? "qrc:/icons/top_header_icons/lightning.svg" : ""
                width: 12
                height: 12
                visible: isCharging
            }
        }

        // Battery percentage display
        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            color: getBatteryColor() // Match the text color to the battery color
            text: qsTr("%0%").arg(batteryPercentage)
            font.family: "Inter"
            font.bold: Font.Bold
            font.pixelSize: 18
        }
    }

    // Function to determine the battery color based on its state
    function getBatteryColor() {
        if (isCharging) return "#4CAF50"; // Green while charging
        if (batteryPercentage >= 90) return "#4CAF50"; // Green when 90%–100%
        if (batteryPercentage <= 20) return "#F44336"; // Red when ≤20%
        return Style.isDark ? Style.white : Style.black10; // Default color
    }
}
