import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0
import QtGraphicalEffects 1.15

RowLayout {
    id: root
    spacing: 32

    Icon {
        id: lockIcon
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        icon.source: Style.isDark ? "qrc:/icons/top_header_icons/dark/lock.svg" : "qrc:/icons/top_header_icons/lock.svg"
        onClicked: Style.mapAreaVisible = !Style.mapAreaVisible
        isGlow: false
        contentItem: Item {
            Image {
                anchors.centerIn: parent
                source: lockIcon.icon.source
                width: 40
                height: 40
                fillMode: Image.PreserveAspectFit
                sourceSize.width: 40
                sourceSize.height: 40
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: "#87CEEB" // Sky blue color
                }
            }
        }
    }

    Icon {
        id: userIcon
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        icon.source: Style.isDark ? "qrc:/icons/top_header_icons/dark/Sentry.svg" : "qrc:/icons/top_header_icons/Sentry.svg"
        onClicked: Style.isDark = !Style.isDark
        isGlow: false
        contentItem: Item {
            Image {
                anchors.centerIn: parent
                source: userIcon.icon.source
                width: 40
                height: 40
                fillMode: Image.PreserveAspectFit
                sourceSize.width: 40
                sourceSize.height: 40

            }
        }
    }
}
