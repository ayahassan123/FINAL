pragma Singleton
import QtQuick 2.9

// Singleton object to define application-wide properties and functions
QtObject {
    // General text color
    readonly property color textColor: "#000000"

    // Primary color palette
    readonly property color blueMedium: "#2E78FF"
    readonly property color blueLight: "#A8C3F4"
    readonly property color red: "#B74134"
    readonly property color redLight: "#ED4E3B"
    readonly property color yellow: "#FFBD0A"
    readonly property color green: "#25CB55"

    // Black and white shades with varying opacity
    readonly property color black: "#000000"
    readonly property color black10: "#414141"
    readonly property color black20: "#757575"
    readonly property color black30: "#A2A3A5"
    readonly property color black40: "#D0D2D0"
    readonly property color black50: "#D0D1D2"
    readonly property color black60: "#E0E0E0"
    readonly property color black80: "#F0F0F0"
    readonly property color white: "#FFFFFF"

    // Default font family
    readonly property string fontFamily: nunitoSans.name

    // Custom colors for search fields and keyboard
    readonly property color searchFieldBackground: isDark ? "#333333" : "#F5F5F5"
    readonly property color searchFieldText: isDark ? "#FFFFFF" : "#212121"
    readonly property color keyboardKeyBackground: isDark ? "#424242" : "#FFFFFF"
    readonly property color keyboardKeyText: isDark ? "#FFFFFF" : "#333333"
    readonly property color keyboardKeyPressed: isDark ? "#666666" : "#CCCCCC"

    // Font loader for "Nunito Sans" font
    readonly property FontLoader nunitoSans: FontLoader {
        source: "qrc:/Nunito_Sans/NunitoSans-Regular.ttf"
    }

    // Theme settings
    property bool isDark: true // Boolean to determine if the dark theme is active
    property bool mapAreaVisible: false // Boolean to toggle the map area visibility
    property string theme: isDark ? "dark" : "light" // Current theme based on isDark value

    // Function to get theme-based background image
    function getImageBasedOnTheme() {
        return `qrc:/icons/${theme}/background_image.png`;
    }

    // Function to apply alpha transparency to a color
    function alphaColor(color, alpha) {
        let actualColor = Qt.darker(color, 1); // Adjust the color brightness
        actualColor.a = alpha; // Set the alpha transparency
        return actualColor;
    }
}
