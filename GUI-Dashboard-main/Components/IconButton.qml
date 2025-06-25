import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0
import QtGraphicalEffects 1.15

// Custom button with glowing and scaling effects
Button {
    id: control
    property string setIcon: "" // Icon source for the button
    property bool isGlow: false // Toggle glow effect
    implicitHeight: isGlow ? 50 : 44 // Adjust height based on glow state
    implicitWidth: isGlow ? 50 : 44 // Adjust width based on glow state

    // Icon inside the button
    Image {
        anchors.centerIn: parent // Center the icon
        source: setIcon // Set the icon source
        scale: control.pressed ? 0.9 : 1.0 // Scale effect when button is pressed
        Behavior on scale { NumberAnimation { duration: 200; } } // Smooth scaling animation
    }

    // Button background
    background: Rectangle {
        implicitWidth: control.width // Match button width
        implicitHeight: control.height // Match button height
        Layout.fillWidth: true
        radius: width // Circular shape
        color: "transparent" // Transparent background
        border.width: 0
        border.color: "transparent"
        visible: false // Background visibility control
        Behavior on color {
            ColorAnimation {
                duration: 200; // Smooth color transition
                easing.type: Easing.Linear;
            }
        }

        // Glow indicator
        Rectangle {
            id: indicator
            property int mx // Mouse X-coordinate
            property int my // Mouse Y-coordinate
            x: mx - width / 2 // Center the indicator on click
            y: my - height / 2
            height: width // Circular shape
            radius: width / 2
            color: isGlow ? Qt.lighter("#29BEB6") : Qt.lighter("#B8FF01") // Color based on glow state
        }
    }

    // Mask for opacity effect
    Rectangle {
        id: mask
        radius: width // Circular mask
        anchors.fill: parent // Fill the parent container
        visible: false
    }

    // Apply opacity mask
    OpacityMask {
        anchors.fill: background // Match background size
        source: background // Use background as source
        maskSource: mask // Apply the mask
    }

    // Mouse area for interaction
    MouseArea {
        id: mouseArea
        hoverEnabled: true // Enable hover effects
        acceptedButtons: Qt.NoButton // No mouse button required for hover
        cursorShape: Qt.PointingHandCursor // Change cursor to pointing hand
        anchors.fill: parent // Cover entire button area
    }

    // Animation for glow effect
    ParallelAnimation {
        id: anim
        NumberAnimation {
            target: indicator
            property: 'width'
            from: 0
            to: control.width * 1.5 // Expand glow size
            duration: 200
        }
        NumberAnimation {
            target: indicator
            property: 'opacity'
            from: 0.9
            to: 0 // Fade-out effect
            duration: 200
        }
    }

    // Trigger animation on button press
    onPressed: {
        indicator.mx = mouseArea.mouseX // Set mouse X-coordinate
        indicator.my = mouseArea.mouseY // Set mouse Y-coordinate
        anim.restart(); // Restart the animation
    }
}
