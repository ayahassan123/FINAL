import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0
import QtGraphicalEffects 1.15

RowLayout {
    id: root
    spacing: 32 // Space between the items in the row layout

    // Lock Icon Section
    Icon {
        id: lockIcon
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter // Align icon to the left and vertically center
        icon.source: Style.isDark ? "qrc:/icons/top_header_icons/dark/lock.svg" : "qrc:/icons/top_header_icons/lock.svg" // Choose icon based on the theme (dark/light)

        // Action performed when the icon is clicked
        onClicked: Style.mapAreaVisible = !Style.mapAreaVisible // Toggle visibility of the map area

        isGlow: false // Disable glow effect
        contentItem: Item {
            Image {
                anchors.centerIn: parent // Center the image within the parent item
                source: lockIcon.icon.source // Use the source from the lockIcon
                width: 40 // Set image width to 40
                height: 40 // Set image height to 40
                fillMode: Image.PreserveAspectFit // Preserve the aspect ratio of the image
                sourceSize.width: 40 // Source size width for the image
                sourceSize.height: 40 // Source size height for the image

                // Apply a graphical layer effect
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: "#87CEEB" // Sky blue color for the overlay
                }
            }
        }
    }

    // User Icon Section (Theme Toggle)
    Icon {
        id: userIcon
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter // Align icon to the right and vertically center
        icon.source: Style.isDark ? "qrc:/icons/top_header_icons/dark/Sentry.svg" : "qrc:/icons/top_header_icons/Sentry.svg" // Choose icon based on the theme (dark/light)

        // Action performed when the icon is clicked
        onClicked: Style.isDark = !Style.isDark // Toggle the theme (dark/light)

        isGlow: false // Disable glow effect
        contentItem: Item {
            Image {
                anchors.centerIn: parent // Center the image within the parent item
                source: userIcon.icon.source // Use the source from the userIcon
                width: 40 // Set image width to 40
                height: 40 // Set image height to 40
                fillMode: Image.PreserveAspectFit // Preserve the aspect ratio of the image
                sourceSize.width: 40 // Source size width for the image
                sourceSize.height: 40 // Source size height for the image

                // Apply a graphical layer effect
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: "#87CEEB" // Sky blue color for the overlay
                }
            }
        }
    }
}
