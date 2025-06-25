import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0 // Custom style module
import QtGraphicalEffects 1.15 // Module for graphical effects

// Root container for the UI item
Item {
    height: 54 // Fixed height for the container
    width: parent.width // Full width of the parent container

    // Left control item
    TopLeftControl {
        anchors.left: parent.left // Align to the left edge of the parent
        anchors.leftMargin: 24 // Add margin to the left
        anchors.verticalCenter: parent.verticalCenter // Vertically center-align within the parent
    }

    // Center control item
    TopMiddleControl {
        anchors.centerIn: parent // Center the control within the parent container
    }

    // Right control item
    TopRightControl {
        anchors.right: parent.right // Align to the right edge of the parent
        anchors.verticalCenter: parent.verticalCenter // Vertically center-align within the parent
        anchors.rightMargin: 24 // Add margin to the right
    }
}
