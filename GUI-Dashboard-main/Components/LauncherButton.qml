import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0
import QtGraphicalEffects 1.15

// Custom button component with icon, text, and ripple animation effect
Button {
    id: control
    // Property to toggle glow effect color
    property bool isGlow: false
    // Property to set text color, defaults to Style.white
    property color textColor: Style.white
    // Default button dimensions
    implicitHeight: 128
    implicitWidth: 128

    // Content layout with centered icon and text
    contentItem: ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        // Spacer to vertically center content
        Item { Layout.fillHeight: true }

        // Icon image with scaling animation on press
        Image {
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            source: control.icon.source
            // Scale down slightly when button is pressed
            scale: control.pressed ? 0.9 : 1.0
            // Smooth scaling animation
            Behavior on scale { NumberAnimation { duration: 200; } }
        }

        // Button text display
        Text {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: control.text
            font: control.font
            color: textColor
        }

        // Spacer to vertically center content
        Item { Layout.fillHeight: true }
    }

    // Background for the button with ripple effect
    background: Rectangle {
        anchors.fill: parent
        radius: width
        color: "transparent"
        border.width: 0
        border.color: "transparent"
        visible: false
        // Smooth color transition animation
        Behavior on color {
            ColorAnimation {
                duration: 200;
                easing.type: Easing.Linear;
            }
        }

        // Ripple effect indicator
        Rectangle {
            id: indicator
            // Properties to store mouse click position
            property int mx
            property int my
            x: mx - width / 2
            y: my - height / 2
            height: width
            radius: width / 2
            // Toggle between two colors based on isGlow property
            color: isGlow ? Qt.lighter("#29BEB6") : Qt.lighter("#B8FF01")
        }
    }

    // Mask for creating circular clipping effect
    Rectangle {
        id: mask
        radius: width
        anchors.fill: parent
        visible: false
    }

    // Apply opacity mask to create circular button shape
    OpacityMask {
        anchors.fill: background
        source: background
        maskSource: mask
    }

    // Mouse area for hover and cursor effects
    MouseArea {
        id: mouseArea
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
    }

    // Animation for ripple effect on button press
    ParallelAnimation {
        id: anim
        // Animate ripple indicator size
        NumberAnimation {
            target: indicator
            property: 'width'
            from: 0
            to: control.width * 1.2
            duration: 200
        }
        // Animate ripple indicator opacity
        NumberAnimation {
            target: indicator
            property: 'opacity'
            from: 0.9
            to: 0
            duration: 200
        }
    }

    // Trigger ripple animation on button press
    onPressed: {
        indicator.mx = mouseArea.mouseX
        indicator.my = mouseArea.mouseY
        anim.restart();
    }
}
