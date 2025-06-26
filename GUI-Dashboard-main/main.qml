import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Window 2.15
import Style 1.0
import QtGraphicalEffects 1.15
import QtMultimedia 5.15
import QtQuick.Dialogs 1.3
import "Components"
import "qrc:/LayoutManager.js" as Responsive

// Main application window for the Tesla-like interface
ApplicationWindow {
    id: root
    property var logger: Logger // Logger for recording actions
    property var theme: Style // Theme object for styling
    property bool isFrunkOpen: false // Tracks frunk open/close state
    property bool isTrunkOpen: false // Tracks trunk open/close state
    property bool isLocked: false // Tracks vehicle lock state
    property bool isCharging: false // Tracks charging state

    width: 1920
    height: 1200
    visible: true
    title: qsTr("Tesla Screen")

    // Load custom font
    FontLoader {
        id: uniTextFont
        source: "qrc:/Fonts/Unitext Regular.ttf"
    }

    // Dynamic background based on theme
    background: Loader {
        anchors.fill: parent
        sourceComponent: theme.mapAreaVisible ? backgroundRect : backgroundImage
    }

    // Header component
    Header {
        id: headerLayout
        z: 99
    }

    // Footer with various control buttons
    footer: Footer {
        id: footerLayout
        onOpenLauncher: launcher.open()
        onPhoneClicked: phonePopup.open()
        onBluetoothClicked: bluetoothPopup.open()
        onRadioClicked: radioPopup.open()
        onSpotifyClicked: spotifyPopup.open()
        onDashcamClicked: dashcamPopup.open()
        onTuneinClicked: tuneinPopup.open()
        onMusicClicked: musicPopup.open()
        onCalendarClicked: calendarPopup.open()
        onZoomClicked: zoomPopup.open()
        onMessagesClicked: messagesPopup.open()
    }

    // Column of icons on the top-left
    TopLeftButtonIconColumn {
        z: 99
        anchors {
            left: parent.left
            top: headerLayout.bottom
            leftMargin: 18
        }
    }

    // Test button for logging
    Button {
        text: "Test Logger"
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 20
        }
        z: 1000
        onClicked: {
            logger.logMessage("Test button clicked in QML")
            console.log("Logged message to file")
        }
    }

    // Main layout for map and speedometer when map is visible
    RowLayout {
        id: mapLayout
        visible: theme.mapAreaVisible
        spacing: 0
        anchors.fill: parent

        Item {
            id: carSpeedLayer
            Layout.preferredWidth: 620
            Layout.fillHeight: true

            // Combined car image and speedometer
            Item {
                id: integratedCarSpeed
                anchors.fill: parent

                // Car image display
                Image {
                    id: carImage
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        topMargin: -60
                    }
                    source: theme.isDark ? "qrc:/icons/light/sidebar.png" : "qrc:/icons/dark/sidebar-light.png"
                    width: 900
                    height: 1200
                    fillMode: Image.PreserveAspectFit
                }

                // Speedometer container
                Item {
                    id: speedometerContainer
                    width: 180
                    height: 180
                    anchors {
                        top: carImage.bottom
                        horizontalCenter: parent.horizontalCenter
                        topMargin: -380
                    }

                    // Speedometer background canvas
                    Canvas {
                        id: speedometerBackground
                        anchors.fill: parent

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();

                            ctx.beginPath();
                            ctx.arc(width/2, height/2, width/2 - 15, 0, 2 * Math.PI);
                            ctx.lineWidth = 8;
                            ctx.strokeStyle= "#29BEB6";
                            ctx.stroke();

                            ctx.font = "12px Inter";
                            ctx.fillStyle = "#87CEEB";
                            ctx.textAlign = "center";
                            ctx.textBaseline = "middle";

                            for (var i = 0; i <= 200; i += 20) {
                                var angle = (i / 200) * Math.PI * 1.5 - Math.PI * 0.75;
                                var x = width/2 + (width/2 - 30) * Math.cos(angle);
                                var y = height/2 + (width/2 - 30) * Math.sin(angle);
                                ctx.fillText(i, x, y);
                            }
                        }
                    }

                    // Speedometer needle canvas
                    Canvas {
                        id: speedometerNeedle
                        anchors.fill: parent
                        property int currentSpeed: 0

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();

                            var angle = (currentSpeed / 200) * Math.PI * 1.5 - Math.PI * 0.75;

                            ctx.save();
                            ctx.translate(width/2, height/2);
                            ctx.rotate(angle);

                            ctx.beginPath();
                            ctx.moveTo(0, 0);
                            ctx.lineTo(width/2 - 30, 0);
                            ctx.lineWidth = 3;
                            ctx.strokeStyle = "#FF0000";
                            ctx.stroke();

                            ctx.beginPath();
                            ctx.arc(0, 0, 5, 0, 2 * Math.PI);
                            ctx.fillStyle = "#FF0000";
                            ctx.fill();

                            ctx.restore();
                        }
                    }

                    // Speed display text
                    Text {
                        id: speedText
                        anchors.centerIn: parent
                        text: speedometerNeedle.currentSpeed + " km/h"
                        font.family: "Inter"
                        font.pixelSize: 20
                        font.bold: Font.Bold
                        color: "#FFFFFF"
                    }
                }
            }
        }

        // Navigation map component
        NavigationMapHelperScreen {
            Layout.fillWidth: true
            Layout.fillHeight: true
            runMenuAnimation: true
        }
    }

    // Timer for simulating speed changes
    Timer {
        id: speedTimer
        interval: 5000
        running: mapLayout.visible
        repeat: true
        property var speedLevels: [0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200]
        property int currentIndex: 0

        onTriggered: {
            currentIndex = (currentIndex + 1) % speedLevels.length;
            var newSpeed = speedLevels[currentIndex];
            animateSpeedChange(newSpeed);
        }
    }

    // Function to animate speed changes
    function animateSpeedChange(newSpeed) {
        speedAnimation.from = speedometerNeedle.currentSpeed;
        speedAnimation.to = newSpeed;
        speedAnimation.start();
    }

    // Animation for speedometer needle
    NumberAnimation {
        id: speedAnimation
        target: speedometerNeedle
        property: "currentSpeed"
        duration: 800
        easing.type: Easing.OutQuad
    }

    // Launcher control for various features
    LaunchPadControl {
        id: launcher
        y: (root.height - height) / 2 + footerLayout.height
        x: (root.width - width) / 2
        onPhoneClicked: phonePopup.open()
        onBluetoothClicked: bluetoothPopup.open()
        onRadioClicked: radioPopup.open()
        onSpotifyClicked: spotifyPopup.open()
        onDashcamClicked: dashcamPopup.open()
        onTuneinClicked: tuneinPopup.open()
        onMusicClicked: musicPopup.open()
        onCalendarClicked: calendarPopup.open()
        onZoomClicked: zoomPopup.open()
        onMessagesClicked: messagesPopup.open()
        onCaraokeClicked: caraokePopup.open()
        onTheaterClicked: theaterPopup.open()
        onToyboxClicked: toyboxPopup.open()
        onFrontDefrostClicked: frontDefrostPopup.open()
        onRearDefrostClicked: rearDefrostPopup.open()
        onLeftSeatClicked: leftSeatPopup.open()
        onHeatedSteeringClicked: heatedSteeringPopup.open()
        onWipersClicked: wipersPopup.open()
    }

    // Media player for music playback
    MediaPlayer {
        id: musicPlayer
        source: ""
        onError: {
            errorText.text = "Error: " + errorString
            errorText.visible = true
            console.log("MediaPlayer error:", errorString)
        }
    }

    // File dialog for selecting music files
    FileDialog {
        id: fileDialog
        title: "Choose an MP3 file"
        folder: "file:///C:/Users/Dell/Downloads"
        nameFilters: ["MP3 files (*.mp3)"]
        onAccepted: {
            musicPlayer.source = fileDialog.fileUrl
            errorText.visible = false
            console.log("Selected file:", musicPlayer.source)
        }
    }

    // Radio stations list model
    ListModel {
        id: radioListModel
        ListElement { name: "BBC Radio 1"; streamUrl: "http://stream.live.vc.bbcmedia.co.uk/bbc_radio_one" }
        ListElement { name: "Jazz FM"; streamUrl: "https://jazz-wr-icecast.musicradio.com/JazzFMMP3" }
        ListElement { name: "Radio Sawa"; streamUrl: "https://mbnvoice-2.mbn.org/stream/sawa/sawa_64k" }
        ListElement { name: "NPR"; streamUrl: "https://npr-ice.streamguys1.com/live.mp3" }
        ListElement { name: "Radio France"; streamUrl: "https://icecast.radiofrance.fr/fip-midfi.mp3" }
    }

    // Music tracks list model
    ListModel {
        id: musicListModel
        ListElement { name: "Song 1"; filePath: "file:///C:/Users/Dell/Downloads/song1.mp3" }
        ListElement { name: "Song 2"; filePath: "file:///C:/Users/Dell/Downloads/song2.mp3" }
        ListElement { name: "Song 3"; filePath: "file:///C:/Users/Dell/Downloads/song3.mp3" }
        ListElement { name: "Song 4"; filePath: "file:///C:/Users/Dell/Downloads/song4.mp3" }
        ListElement { name: "Song 5"; filePath: "file:///C:/Users/Dell/Downloads/song5.mp3" }
    }

    // Background rectangle component
    Component {
        id: backgroundRect
        Rectangle {
            color: "#171717"
            anchors.fill: parent
        }
    }

    // Background image with control buttons
    Component {
        id: backgroundImage
        Image {
            source: theme.getImageBasedOnTheme()

            // Lock button
            Button {
                id: lockButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -350
                    horizontalCenterOffset: 37
                }
                width: 100
                height: 100
                icon.source: theme.isDark ? "qrc:/icons/car_action_icons/dark/lock.svg" : "qrc:/icons/car_action_icons/lock.svg"
                icon.color: root.isLocked ? "#ff0000" : "#00ff00"
                icon.width: 80
                icon.height: 80
                background: Rectangle {
                    color: "transparent"
                }
                onClicked: {
                    root.isLocked = !root.isLocked;

                    if (root.isLocked) {
                        root.isFrunkOpen = false;
                        root.isTrunkOpen = false;
                        root.isCharging = false;
                    }

                    logger.logMessage("Vehicle " + (root.isLocked ? "locked" : "unlocked") +
                                      ", Frunk: " + (root.isFrunkOpen ? "open" : "closed") +
                                      ", Trunk: " + (root.isTrunkOpen ? "open" : "closed") +
                                      ", Charging: " + (root.isCharging ? "on" : "off"));
                    console.log("Vehicle " + (root.isLocked ? "locked" : "unlocked") +
                                ", Charging: " + (root.isCharging ? "on" : "off"));
                }
            }

            // Lights control button
            Button {
                id: lightsButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -250
                    horizontalCenterOffset: -150
                }
                icon.source: theme.isDark ? "qrc:/icons/car_action_icons/dark/lights.svg" : "qrc:/icons/car_action_icons/lights.svg"
                icon.color: isLightsOn ? "#00ff00" : "#ff0000"
                background: Rectangle {
                    color: "transparent"
                }
                property bool isLightsOn: false
                onClicked: {
                    isLightsOn = !isLightsOn
                    logger.logMessage("Lights " + (isLightsOn ? "turned ON" : "turned OFF"))
                    console.log("Lights " + (isLightsOn ? "turned ON" : "turned OFF"))
                    forceActiveFocus()
                    root.update()
                }
            }

            // Charging control button
            Button {
                id: chargeButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -80
                    horizontalCenterOffset: 550
                }
                width: 80
                height: 80
                icon.source: theme.isDark ? "qrc:/icons/car_action_icons/Power.svg" : "qrc:/icons/car_action_icons/charge.svg"
                icon.width: 50
                icon.height: 50
                icon.color: root.isCharging ? "#00ff00" : "#ff0000"
                enabled: !root.isLocked
                background: null
                onClicked: {
                    if (!root.isLocked) {
                        root.isCharging = !root.isCharging
                        logger.logMessage("Charge " + (root.isCharging ? "started" : "stopped"))
                        console.log("Charge " + (root.isCharging ? "started" : "stopped") + " at " + new Date().toLocaleTimeString())
                    } else {
                        logger.logMessage("Cannot toggle charging while vehicle is locked")
                        console.log("Cannot toggle charging while vehicle is locked")
                    }
                }
            }

            // Trunk control layout
            ColumnLayout {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -230
                    horizontalCenterOffset: 440
                }
                Loader {
                    sourceComponent: controlLayoutComponent
                    property string title: "Trunk"
                    property bool isOpen: isTrunkOpen
                    property color openColor: "#ff0000"
                    property color closeColor: "#00ff00"
                    property var onToggle: function() {
                        isTrunkOpen = !isTrunkOpen
                        forceActiveFocus()
                        root.update()
                        logger.logMessage("Trunk " + (isTrunkOpen ? "opened" : "closed"))
                        console.log("Trunk " + (isTrunkOpen ? "opened" : "closed"))
                    }
                }
            }

            // Frunk control layout
            ColumnLayout {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -180
                    horizontalCenterOffset: -350
                }
                Loader {
                    sourceComponent: controlLayoutComponent
                    property string title: "Frunk"
                    property bool isOpen: isFrunkOpen
                    property color openColor: "#ff0000"
                    property color closeColor: "#00ff00"
                    property var onToggle: function() {
                        isFrunkOpen = !isFrunkOpen
                        forceActiveFocus()
                        root.update()
                        logger.logMessage("Frunk " + (isFrunkOpen ? "opened" : "closed"))
                        console.log("Frunk " + (isFrunkOpen ? "opened" : "closed"))
                    }
                }
            }
        }
    }

    // Generic control layout component for trunk/frunk
    Component {
        id: controlLayoutComponent
        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            Text {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                text: title
                font {
                    family: "Inter"
                    pixelSize: 14
                    bold: Font.DemiBold
                }
                color: theme.black20
            }

            Button {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                text: isOpen ? "Close" : "Open"
                font {
                    family: "Inter"
                    pixelSize: 16
                    bold: Font.Bold
                }
                enabled: !root.isLocked
                onClicked: {
                    onToggle()
                    logger.logMessage(title + (isOpen ? " opened" : " closed"))
                    console.log(title + (isOpen ? " opened" : " closed"))
                }

                background: Rectangle {
                    color: isOpen ? openColor : closeColor
                    radius: 10
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: theme.isDark ? theme.white : "#171717"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // Base popup component for modals
    Component {
        id: basePopup
        Popup {
            id: popup
            anchors.centerIn: parent
            width: 400
            height: 500
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            padding: 0

            enter: Transition {
                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
                NumberAnimation { property: "scale"; from: 0.8; to: 1.0; duration: 200 }
            }

            exit: Transition {
                NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200 }
                NumberAnimation { property: "scale"; from: 1.0; to: 0.8; duration: 200 }
            }

            background: Rectangle {
                color: theme.isDark ? "#212121" : "#fafafa"
                radius: 20
                border.color: theme.isDark ? "#424242" : "#e0e0e0"
                border.width: 1
            }
        }
    }

    // Phone dialer popup
    Popup {
        id: phonePopup
        anchors.centerIn: parent
        width: 400
        height: 600
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            color: Style.isDark ? "#212121" : "#fafafa"
            radius: 20
            border.color: Style.isDark ? "#424242" : "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15

                Text {
                    id: dialedNumber
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 30
                    text: ""
                    font.family: "Inter"
                    font.pixelSize: 36
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                GridLayout {
                    columns: 3
                    rowSpacing: 15
                    columnSpacing: 15
                    Layout.alignment: Qt.AlignHCenter

                    Repeater {
                        model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"]
                        Button {
                            width: 80
                            height: 80
                            text: modelData
                            font.pixelSize: 28
                            font.family: "Inter"
                            onClicked: dialedNumber.text += modelData
                            background: Rectangle {
                                color: Style.isDark ? "#424242" : "#ffffff"
                                radius: 40
                                border.color: Style.isDark ? "#616161" : "#e0e0e0"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: Style.isDark ? "#ffffff" : "#424242"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    spacing: 10

                    Button {
                        text: "Call"
                        width: 100
                        height: 50
                        background: Rectangle {
                            color: "#4caf50"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            logger.logMessage("Calling number: " + dialedNumber.text)
                            console.log("Call initiated")
                        }
                    }

                    Button {
                        text: "Backspace"
                        width: 100
                        height: 50
                        onClicked: dialedNumber.text = dialedNumber.text.slice(0, -1)
                        background: Rectangle {
                            color: "#ff9800"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Clear"
                        width: 100
                        height: 50
                        onClicked: dialedNumber.text = ""
                        background: Rectangle {
                            color: "#f44336"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: phonePopup.close()
                    background: Rectangle {
                        color: "transparent"
                        border.color: Style.isDark ? "#757575" : "#bdbdbd"
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#616161"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Bluetooth devices popup
    Popup {
        id: bluetoothPopup
        anchors.centerIn: parent
        width: 400
        height: 500
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            color: Style.isDark ? "#212121" : "#fafafa"
            radius: 20
            border.color: Style.isDark ? "#424242" : "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    text: "Bluetooth Devices"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 20
                    clip: true
                    model: ["Phone", "Headphones", "Car Audio"]
                    delegate: Button {
                        width: parent.width
                        height: 60
                        text: modelData
                        font.family: "Inter"
                        font.pixelSize: 18
                        onClicked: console.log("Connecting to:", modelData)
                        background: Rectangle {
                            color: Style.isDark ? "#424242" : "#ffffff"
                            radius: 10
                            border.color: Style.isDark ? "#616161" : "#e0e0e0"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: Style.isDark ? "#ffffff" : "#424242"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: bluetoothPopup.close()
                    background: Rectangle {
                        color: "transparent"
                        border.color: Style.isDark ? "#757575" : "#bdbdbd"
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#616161"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Radio player
    MediaPlayer {
        id: radioPlayer
        source: ""
        volume: radioVolumeSlider.value / 100
        onError: {
            radioErrorText.text = "Error: " + errorString + "\nCode: " + error
            radioErrorText.visible = true
            console.log("Radio Player error:", error, errorString)
            radioPlayPauseButton.text = "▶"
        }
        onPlaying: {
            radioErrorText.visible = false
            radioPlayPauseButton.text = "⏸"
        }
        onStopped: {
            radioPlayPauseButton.text = "▶"
        }
    }

    // Radio popup
    Popup {
        id: radioPopup
        anchors.centerIn: parent
        width: 500
        height: 600
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            color: Style.isDark ? "#212121" : "#fafafa"
            radius: 20
            border.color: Style.isDark ? "#424242" : "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    text: "Internet Radio"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                Text {
                    id: currentStationText
                    Layout.alignment: Qt.AlignHCenter
                    text: radioPlayer.source.toString().split('/').pop() || "No station selected"
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    id: radioErrorText
                    Layout.alignment: Qt.AlignHCenter
                    text: ""
                    font.family: "Inter"
                    font.pixelSize: 16
                    color: "#F44336"
                    visible: false
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                ListView {
                    id: radioListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 20
                    clip: true
                    model: ListModel {
                        id: radioStationsModel
                        ListElement { name: "NPR"; streamUrl: "https://npr-ice.streamguys1.com/live.mp3" }
                        ListElement { name: "Radio France"; streamUrl: "https://icecast.radiofrance.fr/fip-midfi.mp3" }
                    }
                    delegate: Button {
                        width: parent.width
                        height: 60
                        text: name
                        font.family: "Inter"
                        font.pixelSize: 18
                        onClicked: {
                            radioPlayer.stop();
                            radioPlayer.source = streamUrl;
                            radioPlayer.play();
                            currentStationText.text = name;
                            console.log("Playing:", name);
                        }
                        background: Rectangle {
                            color: Style.isDark ? "#424242" : "#ffffff"
                            radius: 10
                            border.color: Style.isDark ? "#616161" : "#e0e0e0"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: Style.isDark ? "#ffffff" : "#424242"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                    ScrollBar.vertical: ScrollBar {}
                }

                // Loading indicator for radio
                BusyIndicator {
                    id: radioLoadingIndicator
                    Layout.alignment: Qt.AlignHCenter
                    running: radioPlayer.status === MediaPlayer.Loading
                    visible: running
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        id: radioPlayPauseButton
                        text: "▶"
                        width: 80
                        height: 80
                        onClicked: {
                            if (radioPlayer.playbackState === MediaPlayer.PlayingState) {
                                radioPlayer.pause();
                                text = "▶";
                            } else {
                                if (radioPlayer.source.toString() === "") {
                                    radioErrorText.text = "Please select a station first";
                                    radioErrorText.visible = true;
                                } else {
                                    radioPlayer.play();
                                    text = "⏸";
                                }
                            }
                        }
                        background: Rectangle {
                            color: "#4CAF50"
                            radius: 40
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 30
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Stop"
                        width: 80
                        height: 80
                        onClicked: {
                            radioPlayer.stop();
                            radioPlayPauseButton.text = "▶";
                        }
                        background: Rectangle {
                            color: "#F44336"
                            radius: 40
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Text {
                        text: "Volume:"
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#424242"
                    }

                    Slider {
                        id: radioVolumeSlider
                        width: 150
                        from: 0
                        to: 100
                        value: 50
                        onValueChanged: {
                            radioPlayer.volume = value / 100;
                        }
                    }
                }

                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: {
                        radioPlayer.stop();
                        radioPopup.close();
                    }
                    background: Rectangle {
                        color: "transparent"
                        border.color: Style.isDark ? "#757575" : "#bdbdbd"
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#616161"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Spotify popup
    Popup {
        id: spotifyPopup
        anchors.centerIn: parent
        width: 500
        height: 600
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        // Spotify media player
        MediaPlayer {
            id: spotifyPlayer
            source: ""
            volume: spotifyVolumeSlider.value / 100
            onError: {
                spotifyErrorText.text = "Error: " + errorString + "\nCode: " + error
                spotifyErrorText.visible = true
                console.log("Spotify Player error:", error, errorString)
                spotifyPlayPauseButton.text = "▶"
            }
            onPlaying: {
                spotifyErrorText.visible = false
                spotifyPlayPauseButton.text = "⏸"
            }
            onStopped: {
                spotifyPlayPauseButton.text = "▶"
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Style.isDark ? "#212121" : "#fafafa"
            radius: 20
            border.color: Style.isDark ? "#424242" : "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15

                // Spotify title
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    text: "Spotify Playlists"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                // Current playlist display
                Text {
                    id: currentPlaylistText
                    Layout.alignment: Qt.AlignHCenter
                    text: spotifyPlayer.source.toString().split('/').pop() || "No playlist selected"
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                // Error text for Spotify
                Text {
                    id: spotifyErrorText
                    Layout.alignment: Qt.AlignHCenter
                    text: ""
                    font.family: "Inter"
                    font.pixelSize: 16
                    color: "#F44336"
                    visible: false
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                // Spotify playlists list
                ListView {
                    id: spotifyListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 20
                    clip: true
                    model: ListModel {
                        id: spotifyPlaylistsModel
                        ListElement { name: "Chill Hits"; streamUrl: "https://example.com/spotify/chill_hits.mp3" }
                        ListElement { name: "Rock Classics"; streamUrl: "https://example.com/spotify/rock_classics.mp3" }
                        ListElement { name: "Pop Hits"; streamUrl: "https://example.com/spotify/pop_hits.mp3" }
                    }
                    delegate: Button {
                        width: parent.width
                        height: 60
                        text: name
                        font.family: "Inter"
                        font.pixelSize: 18
                        onClicked: {
                            spotifyPlayer.stop();
                            spotifyPlayer.source = streamUrl;
                            spotifyPlayer.play();
                            currentPlaylistText.text = name;
                            console.log("Playing Spotify playlist:", name);
                        }
                        background: Rectangle {
                            color: Style.isDark ? "#424242" : "#ffffff"
                            radius: 10
                            border.color: Style.isDark ? "#616161" : "#e0e0e0"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: Style.isDark ? "#ffffff" : "#424242"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                    ScrollBar.vertical: ScrollBar {}
                }

                // Loading indicator for Spotify
                BusyIndicator {
                    id: spotifyLoadingIndicator
                    Layout.alignment: Qt.AlignHCenter
                    running: spotifyPlayer.status === MediaPlayer.Loading
                    visible: running
                }

                // Playback controls
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        id: spotifyPlayPauseButton
                        text: "▶"
                        width: 80
                        height: 80
                        onClicked: {
                            if (spotifyPlayer.playbackState === MediaPlayer.PlayingState) {
                                spotifyPlayer.pause();
                                text = "▶";
                            } else {
                                if (spotifyPlayer.source.toString() === "") {
                                    spotifyErrorText.text = "Please select a playlist first";
                                    spotifyErrorText.visible = true;
                                } else {
                                    spotifyPlayer.play();
                                    text = "⏸";
                                }
                            }
                        }
                        background: Rectangle {
                            color: "#4CAF50"
                            radius: 40
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 30
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Stop"
                        width: 80
                        height: 80
                        onClicked: {
                            spotifyPlayer.stop();
                            spotifyPlayPauseButton.text = "▶";
                        }
                        background: Rectangle {
                            color: "#F44336"
                            radius: 40
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                // Volume control
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Text {
                        text: "Volume:"
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#424242"
                    }

                    Slider {
                        id: spotifyVolumeSlider
                        width: 150
                        from: 0
                        to: 100
                        value: 50
                        onValueChanged: {
                            spotifyPlayer.volume = value / 100;
                        }
                    }
                }

                // Close button
                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: {
                        spotifyPlayer.stop();
                        spotifyPopup.close();
                    }
                    background: Rectangle {
                        color: "transparent"
                        border.color: Style.isDark ? "#757575" : "#bdbdbd"
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#616161"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Dashcam control popup
    Popup {
        id: dashcamPopup
        anchors.centerIn: parent
        width: 400
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            color: Style.isDark ? "#212121" : "#fafafa"
            radius: 20
            border.color: Style.isDark ? "#424242" : "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    text: "Dashcam Control"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        text: "Start Recording"
                        width: 150
                        height: 50
                        onClicked: console.log("Dashcam recording started")
                        background: Rectangle {
                            color: "#4caf50"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Stop Recording"
                        width: 150
                        height: 50
                        onClicked: console.log("Dashcam recording stopped")
                        background: Rectangle {
                            color: "#f44336"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: dashcamPopup.close()
                    background: Rectangle {
                        color: "transparent"
                        border.color: Style.isDark ? "#757575" : "#bdbdbd"
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#616161"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // TuneIn stations popup
    Popup {
        id: tuneinPopup
        anchors.centerIn: parent
        width: 400
        height: 500
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            color: Style.isDark ? "#212121" : "#fafafa"
            radius: 20
            border.color: Style.isDark ? "#424242" : "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    text: "TuneIn Stations"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 20
                    clip: true
                    model: ["BBC Radio", "NPR", "Jazz FM"]
                    delegate: Button {
                        width: parent.width
                        height: 60
                        text: modelData
                        font.family: "Inter"
                        font.pixelSize: 18
                        onClicked: console.log("Tuning to:", modelData)
                        background: Rectangle {
                            color: Style.isDark ? "#424242" : "#ffffff"
                            radius: 10
                            border.color: Style.isDark ? "#616161" : "#e0e0e0"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: Style.isDark ? "#ffffff" : "#424242"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: tuneinPopup.close()
                    background: Rectangle {
                        color: "transparent"
                        border.color: Style.isDark ? "#757575" : "#bdbdbd"
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#616161"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Music player popup
    Popup {
        id: musicPopup
        anchors.centerIn: parent
        width: 400
        height: 500
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property int currentSongIndex: -1

        Rectangle {
            anchors.fill: parent
            color: Style.isDark ? "#212121" : "#fafafa"
            radius: 20
            border.color: Style.isDark ? "#424242" : "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    text: "Music Player"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: musicPlayer.source.toString().split('/').pop() || "No song selected"
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    id: errorText
                    Layout.alignment: Qt.AlignHCenter
                    text: ""
                    font.family: "Inter"
                    font.pixelSize: 16
                    color: "#F44336"
                    visible: false
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                ListView {
                    id: songList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 20
                    clip: true
                    model: musicListModel
                    delegate: Button {
                        width: parent.width
                        height: 60
                        text: name
                        font.family: "Inter"
                        font.pixelSize: 18
                        onClicked: {
                            musicPlayer.source = filePath
                            musicPlayer.play()
                            errorText.visible = false
                            playPauseButton.text = "⏸"
                            currentSongIndex = index
                            console.log("Playing:", name)
                        }
                        background: Rectangle {
                            color: Style.isDark ? "#424242" : "#ffffff"
                            radius: 10
                            border.color: Style.isDark ? "#616161" : "#e0e0e0"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: Style.isDark ? "#ffffff" : "#424242"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                    ScrollBar.vertical: ScrollBar {}
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        text: "◄◄"
                        width: 60
                        height: 60
                        onClicked: {
                            if (currentSongIndex > 0) {
                                currentSongIndex--
                                var prevSong = musicListModel.get(currentSongIndex)
                                musicPlayer.source = prevSong.filePath
                                musicPlayer.play()
                                playPauseButton.text = "⏸"
                                console.log("Playing previous song:", prevSong.name)
                            }
                        }
                        enabled: currentSongIndex > 0
                        background: Rectangle {
                            color: enabled ? (Style.isDark ? "#424242" : "#ffffff") : (Style.isDark ? "#616161" : "#e0e0e0")
                            radius: 30
                            border.color: Style.isDark ? "#616161" : "#e0e0e0"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 20
                            color: parent.enabled ? (Style.isDark ? "#ffffff" : "#424242") : (Style.isDark ? "#757575" : "#bdbdbd")
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: playPauseButton
                        text: "▶"
                        width: 80
                        height: 80
                        onClicked: {
                            if (musicPlayer.playbackState === MediaPlayer.PlayingState) {
                                musicPlayer.pause()
                                text = "▶"
                                console.log("Music paused")
                            } else {
                                if (musicPlayer.source.toString() === "" && currentSongIndex === -1) {
                                    errorText.text = "Please select a song first"
                                    errorText.visible = true
                                } else {
                                    musicPlayer.play()
                                    text = "⏸"
                                    console.log("Music playing")
                                }
                            }
                        }
                        background: Rectangle {
                            color: "#4caf50"
                            radius: 40
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 30
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "►►"
                        width: 60
                        height: 60
                        onClicked: {
                            if (currentSongIndex < musicListModel.count - 1) {
                                currentSongIndex++
                                var nextSong = musicListModel.get(currentSongIndex)
                                musicPlayer.source = nextSong.filePath
                                musicPlayer.play()
                                playPauseButton.text = "⏸"
                                console.log("Playing next song:", nextSong.name)
                            }
                        }
                        enabled: currentSongIndex < musicListModel.count - 1
                        background: Rectangle {
                            color: enabled ? (Style.isDark ? "#424242" : "#ffffff") : (Style.isDark ? "#616161" : "#e0e0e0")
                            radius: 30
                            border.color: Style.isDark ? "#616161" : "#e0e0e0"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 20
                            color: parent.enabled ? (Style.isDark ? "#ffffff" : "#424242") : (Style.isDark ? "#757575" : "#bdbdbd")
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Button {
                    text: "Choose File"
                    width: 100
                    height: 50
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: fileDialog.open()
                    background: Rectangle {
                        color: "#2196f3"
                        radius: 25
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 18
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: {
                        musicPlayer.stop()
                        playPauseButton.text = "▶"
                        musicPopup.close()
                    }
                    background: Rectangle {
                        color: "transparent"
                        border.color: Style.isDark ? "#757575" : "#bdbdbd"
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#616161"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
    // Calendar popup for date selection, mimicking mobile/laptop calendar with dynamic day highlighting
        Popup {
            id: calendarPopup
            anchors.centerIn: parent
            width: 500
            height: 600
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            property int selectedDay: -1
            property var currentDate: new Date(2025, 6, 26, 19, 29) // Updated to current date and time: 07:29 PM EEST, June 26, 2025
            property int displayMonth: 0 // Setting default month to July (adjusted index 0 in new order)
            property int displayYear: 2025 // Setting default year to 2025

            Rectangle {
                anchors.fill: parent
                color: Style.isDark ? "#212121" : "#fafafa" // Adjusting background color based on dark/light mode
                radius: 20
                border.color: Style.isDark ? "#424242" : "#e0e0e0" // Adjusting border color based on dark/light mode
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                        text: "Calendar" // Displaying the calendar title
                        font.family: "Inter"
                        font.pixelSize: 24
                        font.bold: Font.Medium
                        color: Style.isDark ? "#ffffff" : "#212121" // Adjusting text color based on dark/light mode
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        ComboBox {
                            id: monthSelector
                            width: 150
                            model: ["July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May", "June"]
                            currentIndex: displayMonth // Ensuring initial display is July (index 0 in new order)
                            font.family: "Inter"
                            font.pixelSize: 18
                            Component.onCompleted: {
                                currentIndex = displayMonth; // Ensuring July is selected on startup
                            }
                            displayText: currentIndex >= 0 ? model[currentIndex] : "July" // Displaying "July" as default, showing selected month otherwise
                            onCurrentIndexChanged: {
                                displayMonth = currentIndex; // Updating display month when changed
                                updateDays(); // Refreshing days display
                            }
                        }

                        ComboBox {
                            id: yearSelector
                            width: 100
                            model: ListModel {
                                id: yearModel
                                Component.onCompleted: {
                                    for (var i = 1990; i <= 2040; i++) {
                                        yearModel.append({ "text": i }) // Populating year model from 1990 to 2040
                                    }
                                    currentIndex = yearModel.findIndex(function(item) { return item.text === displayYear; }) || 0; // Setting default to 2025
                                }
                            }
                            currentIndex: yearModel.findIndex(function(item) { return item.text === displayYear; }) || 0
                            font.family: "Inter"
                            font.pixelSize: 18
                            displayText: currentIndex >= 0 ? yearModel.get(currentIndex).text : "2025" // Displaying "2025" as default, showing selected year otherwise
                            onCurrentIndexChanged: {
                                displayYear = yearModel.get(currentIndex).text; // Updating display year when changed
                                updateDays(); // Refreshing days display
                            }
                        }
                    }

                    GridLayout {
                        id: daysGrid
                        columns: 7
                        rowSpacing: 10
                        columnSpacing: 10
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.margins: 20

                        Repeater {
                            model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                            Text {
                                Layout.fillWidth: true
                                text: modelData // Displaying day names
                                font.family: "Inter"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                color: Style.isDark ? "#ffffff" : "#212121" // Adjusting text color based on dark/light mode
                            }
                        }

                        Repeater {
                            id: daysRepeater
                            model: 31 // Setting model to 31 days for July
                            Item {
                                width: 50
                                height: 50

                                Button {
                                    id: dayButton
                                    anchors.fill: parent
                                    text: index + 1 // Displaying day number
                                    font.family: "Inter"
                                    font.pixelSize: 18
                                    onClicked: {
                                        calendarPopup.selectedDay = index + 1; // Setting selected day on click
                                    }

                                    background: Item {
                                        anchors.fill: parent

                                        Rectangle {
                                            id: dayBackground
                                            anchors.fill: parent
                                            color: {
                                                var dayDate = new Date(displayYear, displayMonth, index + 1); // Calculating date for the day
                                                var today = new Date(currentDate); // Getting current date

                                                dayDate.setHours(0, 0, 0, 0);
                                                today.setHours(0, 0, 0, 0);

                                                if (dayDate.getTime() === today.getTime()) {
                                                    return "#4CAF50"; // Highlighting current day with green
                                                } else if (calendarPopup.selectedDay === index + 1) {
                                                    return "#4CAF50"; // Highlighting selected day with green
                                                } else {
                                                    return Style.isDark ? "#424242" : "#ffffff"; // Default background color
                                                }
                                            }
                                            radius: 25
                                            border.color: Style.isDark ? "#616161" : "#e0e0e0" // Adjusting border color based on dark/light mode
                                            border.width: 1
                                        }

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 40
                                            height: 40
                                            radius: 20
                                            color: "transparent"
                                            border.color: {
                                                var dayDate = new Date(displayYear, displayMonth, index + 1); // Calculating date for the day
                                                var today = new Date(currentDate); // Getting current date

                                                dayDate.setHours(0, 0, 0, 0);
                                                today.setHours(0, 0, 0, 0);

                                                if (dayDate.getTime() === today.getTime() || calendarPopup.selectedDay === index + 1) {
                                                    return "#ffffff"; // Adding white border for current/selected day
                                                } else {
                                                    return "transparent";
                                                }
                                            }
                                            border.width: 2
                                            visible: border.color !== "transparent"
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font: parent.font
                                        color: {
                                            var dayDate = new Date(displayYear, displayMonth, index + 1); // Calculating date for the day
                                            var today = new Date(currentDate); // Getting current date

                                            dayDate.setHours(0, 0, 0, 0);
                                            today.setHours(0, 0, 0, 0);

                                            if (dayDate.getTime() === today.getTime() || calendarPopup.selectedDay === index + 1) {
                                                return "#2196F3"; // Sky blue text for current/selected day (changed from #ffffff)
                                            } else {
                                                return Style.isDark ? "#ffffff" : "#424242"; // Default text color based on dark/light mode
                                            }
                                        }
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        text: "Close" // Close button text
                        width: 120
                        height: 40
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 20
                        onClicked: calendarPopup.close() // Closing the popup on click
                        background: Rectangle {
                            color: "transparent"
                            border.color: Style.isDark ? "#757575" : "#bdbdbd" // Adjusting border color based on dark/light mode
                            border.width: 1
                            radius: 20
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 16
                            color: Style.isDark ? "#ffffff" : "#616161" // Adjusting text color based on dark/light mode
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    function updateDays() {
                        var daysInMonth = [31, 31, 30, 31, 30, 31, 31, 31, 30, 31, 30, 31]; // Array of days in each month (adjusted for new order)
                        var selectedMonth = displayMonth;
                        var selectedYear = displayYear;
                        var firstDay = new Date(selectedYear, selectedMonth, 1).getDay(); // Getting first day of the month
                        var adjustedFirstDay = (firstDay === 0) ? 6 : firstDay - 1; // Adjusting for week start on Monday

                        daysRepeater.model = daysInMonth[selectedMonth]; // Setting days model based on selected month

                        for (var i = 0; i < daysRepeater.count; i++) {
                            if (daysRepeater.itemAt(i)) {
                                daysRepeater.itemAt(i).visible = (i >= adjustedFirstDay); // Showing days from the first day
                            }
                        }
                        for (var j = 0; j < adjustedFirstDay; j++) {
                            if (daysRepeater.itemAt(j)) daysRepeater.itemAt(j).visible = false; // Hiding days before the first day
                        }
                    }

                    function isLeapYear(year) {
                        return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0); // Checking if the year is a leap year
                    }

                    Component.onCompleted: {
                        updateDays(); // Initializing days display
                        monthSelector.currentIndex = displayMonth; // Ensuring July is selected on startup
                    }

                    Timer {
                        interval: 86400000 // Setting interval to 24 hours in milliseconds
                        running: true
                        repeat: true
                        onTriggered: {
                            currentDate.setDate(currentDate.getDate() + 1); // Moving to the next day (e.g., 27)
                            updateDays(); // Refreshing days display
                        }
                    }
                }
            }
        }

    // Zoom meeting popup
    Popup {
        id: zoomPopup
        anchors.centerIn: parent
        width: 400
        height: 400
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            color: Style.isDark ? "#212121" : "#fafafa"
            radius: 20
            border.color: Style.isDark ? "#424242" : "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15


                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    text: "Zoom Meeting"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                TextField {
                    id: meetingLink
                    Layout.fillWidth: true
                    Layout.margins: 20
                    placeholderText: "Enter meeting link"
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                    background: Rectangle {
                        color: Style.isDark ? "#424242" : "#ffffff"
                        radius: 10
                        border.color: Style.isDark ? "#616161" : "#e0e0e0"
                        border.width: 1
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        text: "Join Meeting"
                        width: 150
                        height: 50
                        onClicked: console.log("Joining Zoom meeting:", meetingLink.text)
                        background: Rectangle {
                            color: "#2196f3"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Clear"
                        width: 100
                        height: 50
                        onClicked: meetingLink.text = ""
                        background: Rectangle {
                            color: "#f44336"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: zoomPopup.close()
                    background: Rectangle {
                        color: "transparent"
                        border.color: Style.isDark ? "#757575" : "#bdbdbd"
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#616161"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Messages popup
    Popup {
        id: messagesPopup
        anchors.centerIn: parent
        width: 500
        height: 700
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            color: Style.isDark ? "#212121" : "#fafafa"
            radius: 20
            border.color: Style.isDark ? "#424242" : "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    text: "Messages"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                TextField {
                    id: recipientField
                    Layout.fillWidth: true
                    Layout.margins: 20
                    placeholderText: "Recipient"
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                    background: Rectangle {
                        color: Style.isDark ? "#424242" : "#ffffff"
                        radius: 10
                        border.color: Style.isDark ? "#616161" : "#e0e0e0"
                        border.width: 1
                    }
                }

                TextField {
                    id: messageField
                    Layout.fillWidth: true
                    Layout.margins: 20
                    placeholderText: "Type your message..."
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                    background: Rectangle {
                        color: Style.isDark ? "#424242" : "#ffffff"
                        radius: 10
                        border.color: Style.isDark ? "#616161" : "#e0e0e0"
                        border.width: 1
                    }
                }

                GridLayout {
                    columns: 10
                    rowSpacing: 10
                    columnSpacing: 10
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.margins: 20

                    Repeater {
                        model: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
                                "a", "s", "d", "f", "g", "h", "j", "k", "l", ";",
                                "z", "x", "c", "v", "b", "n", "m", ",", ".", " ",
                                "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                        Button {
                            width: 40
                            height: 40
                            text: modelData
                            font.family: "Inter"
                            font.pixelSize: 18
                            onClicked: messageField.text += modelData
                            background: Rectangle {
                                color: Style.isDark ? "#424242" : "#ffffff"
                                radius: 20
                                border.color: Style.isDark ? "#616161" : "#e0e0e0"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: Style.isDark ? "#ffffff" : "#424242"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Button {
                        text: "Send"
                        width: 100
                        height: 50
                        onClicked: console.log("Sending message to", recipientField.text, ":", messageField.text)
                        background: Rectangle {
                            color: "#4caf50"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Backspace"
                        width: 100
                        height: 50
                        onClicked: messageField.text = messageField.text.slice(0, -1)
                        background: Rectangle {
                            color: "#ff9800"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Clear"
                        width: 100
                        height: 50
                        onClicked: {
                            recipientField.text = ""
                            messageField.text = ""
                        }
                        background: Rectangle {
                            color: "#f44336"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 18
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: messagesPopup.close()
                    background: Rectangle {
                        color: "transparent"
                        border.color: Style.isDark ? "#757575" : "#bdbdbd"
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#616161"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Caraoke songs popup
    Popup {
        id: caraokePopup
        anchors.centerIn: parent
        width: 400
        height: 500
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            color: Style.isDark ? "#212121" : "#fafafa"
            radius: 20
            border.color: Style.isDark ? "#424242" : "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    text: "Caraoke Songs"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 20
                    clip: true
                    model: ["Bohemian Rhapsody", "Sweet Caroline", "Livin' on a Prayer"]
                    delegate: Button {
                        width: parent.width
                        height: 60
                        text: modelData
                        font.family: "Inter"
                        font.pixelSize: 18
                        onClicked: console.log("Playing Caraoke song:", modelData)
                        background: Rectangle {
                            color: Style.isDark ? "#424242" : "#ffffff"
                            radius: 10
                            border.color: Style.isDark ? "#616161" : "#e0e0e0"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: Style.isDark ? "#ffffff" : "#424242"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: caraokePopup.close()
                    background: Rectangle {
                        color: "transparent"
                        border.color: Style.isDark ? "#757575" : "#bdbdbd"
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.family: "Inter"
                        font.pixelSize: 16
                        color: Style.isDark ? "#ffffff" : "#616161"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Theater mode popup for selecting streaming services
        Popup {
            id: theaterPopup
            anchors.centerIn: parent
            width: 400
            height: 500
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            // Background rectangle with theme-based styling
            Rectangle {
                anchors.fill: parent
                color: Style.isDark ? "#212121" : "#fafafa"
                radius: 20
                border.color: Style.isDark ? "#424242" : "#e0e0e0"
                border.width: 1

                // Main layout for theater mode controls
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15

                    // Title for the theater mode popup
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                        text: "Theater Mode"
                        font.family: "Inter"
                        font.pixelSize: 24
                        font.bold: Font.Medium
                        color: Style.isDark ? "#ffffff" : "#212121"
                    }

                    // List of streaming services
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 20
                        clip: true
                        model: ["Netflix", "YouTube", "Hulu"]
                        delegate: Button {
                            width: parent.width
                            height: 60
                            text: modelData
                            font.family: "Inter"
                            font.pixelSize: 18
                            // Log selection of streaming service
                            onClicked: {
                                console.log("Opening:", modelData)
                                logger.logMessage("Theater mode: " + modelData + " selected")
                            }
                            // Button background with theme-based styling
                            background: Rectangle {
                                color: Style.isDark ? "#424242" : "#ffffff"
                                radius: 10
                                border.color: Style.isDark ? "#616161" : "#e0e0e0"
                                border.width: 1
                            }
                            // Button text with theme-based color
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: Style.isDark ? "#ffffff" : "#424242"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // Close button for the popup
                    Button {
                        text: "Close"
                        width: 120
                        height: 40
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 20
                        onClicked: theaterPopup.close()
                        // Transparent background with themed border
                        background: Rectangle {
                            color: "transparent"
                            border.color: Style.isDark ? "#757575" : "#bdbdbd"
                            border.width: 1
                            radius: 20
                        }
                        // Button text with theme-based color
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 16
                            color: Style.isDark ? "#ffffff" : "#616161"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        // Toybox popup for selecting fun features and games
        Popup {
            id: toyboxPopup
            anchors.centerIn: parent
            width: 400
            height: 500
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            // Background rectangle with theme-based styling
            Rectangle {
                anchors.fill: parent
                color: Style.isDark ? "#212121" : "#fafafa"
                radius: 20
                border.color: Style.isDark ? "#424242" : "#e0e0e0"
                border.width: 1

                // Main layout for toybox controls
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15

                    // Title for the toybox popup
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                        text: "Toybox"
                        font.family: "Inter"
                        font.pixelSize: 24
                        font.bold: Font.Medium
                        color: Style.isDark ? "#ffffff" : "#212121"
                    }

                    // List of toybox features
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 20
                        clip: true
                        model: ["Chess", "Fart Sounds", "Santa Mode", "Light Show", "Sketchpad"]
                        delegate: Button {
                            width: parent.width
                            height: 60
                            text: modelData
                            font.family: "Inter"
                            font.pixelSize: 18
                            // Handle selection of toybox features
                            onClicked: {
                                console.log("Toybox item selected:", modelData)
                                logger.logMessage("Toybox: " + modelData + " selected")
                                if (modelData === "Chess") {
                                    console.log("Launching Chess game")
                                } else if (modelData === "Fart Sounds") {
                                    console.log("Playing funny sounds")
                                } else if (modelData === "Santa Mode") {
                                    console.log("Activating Santa Mode")
                                } else if (modelData === "Light Show") {
                                    console.log("Starting Light Show")
                                } else if (modelData === "Sketchpad") {
                                    console.log("Opening Sketchpad")
                                }
                            }
                            // Button background with theme-based styling
                            background: Rectangle {
                                color: Style.isDark ? "#424242" : "#ffffff"
                                radius: 10
                                border.color: Style.isDark ? "#616161" : "#e0e0e0"
                                border.width: 1
                            }
                            // Button text with theme-based color
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: Style.isDark ? "#ffffff" : "#424242"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // Close button for the popup
                    Button {
                        text: "Close"
                        width: 120
                        height: 40
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 20
                        onClicked: toyboxPopup.close()
                        // Transparent background with themed border
                        background: Rectangle {
                            color: "transparent"
                            border.color: Style.isDark ? "#757575" : "#bdbdbd"
                            border.width: 1
                            radius: 20
                        }
                        // Button text with theme-based color
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 16
                            color: Style.isDark ? "#ffffff" : "#616161"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        // Front defrost control popup
        Popup {
            id: frontDefrostPopup
            anchors.centerIn: parent
            width: 400
            height: 300
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            // Property to track front defrost state
            property bool isFrontDefrostOn: false

            // Background rectangle with theme-based styling
            Rectangle {
                anchors.fill: parent
                color: Style.isDark ? "#212121" : "#fafafa"
                radius: 20
                border.color: Style.isDark ? "#424242" : "#e0e0e0"
                border.width: 1

                // Main layout for front defrost controls
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15

                    // Title for the front defrost popup
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                        text: "Front Defrost Control"
                        font.family: "Inter"
                        font.pixelSize: 24
                        font.bold: Font.Medium
                        color: Style.isDark ? "#ffffff" : "#212121"
                    }

                    // Display current front defrost state
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: frontDefrostPopup.isFrontDefrostOn ? "Front Defrost: ON" : "Front Defrost: OFF"
                        font.family: "Inter"
                        font.pixelSize: 18
                        color: Style.isDark ? "#ffffff" : "#424242"
                    }

                    // Buttons for controlling front defrost
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        // Turn on front defrost
                        Button {
                            text: "Turn On"
                            width: 150
                            height: 50
                            enabled: !frontDefrostPopup.isFrontDefrostOn
                            onClicked: {
                                frontDefrostPopup.isFrontDefrostOn = true
                                console.log("Front Defrost turned ON")
                                logger.logMessage("Front Defrost turned ON")
                            }
                            // Button background with enabled/disabled styling
                            background: Rectangle {
                                color: enabled ? "#4caf50" : "#bdbdbd"
                                radius: 25
                            }
                            // Button text
                            contentItem: Text {
                                text: parent.text
                                font.family: "Inter"
                                font.pixelSize: 18
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Turn off front defrost
                        Button {
                            text: "Turn Off"
                            width: 150
                            height: 50
                            enabled: frontDefrostPopup.isFrontDefrostOn
                            onClicked: {
                                frontDefrostPopup.isFrontDefrostOn = false
                                console.log("Front Defrost turned OFF")
                                logger.logMessage("Front Defrost turned OFF")
                            }
                            // Button background with enabled/disabled styling
                            background: Rectangle {
                                color: enabled ? "#f44336" : "#bdbdbd"
                                radius: 25
                            }
                            // Button text
                            contentItem: Text {
                                text: parent.text
                                font.family: "Inter"
                                font.pixelSize: 18
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // Close button for the popup
                    Button {
                        text: "Close"
                        width: 120
                        height: 40
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 20
                        onClicked: frontDefrostPopup.close()
                        // Transparent background with themed border
                        background: Rectangle {
                            color: "transparent"
                            border.color: Style.isDark ? "#757575" : "#bdbdbd"
                            border.width: 1
                            radius: 20
                        }
                        // Button text with theme-based color
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 16
                            color: Style.isDark ? "#ffffff" : "#616161"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        // Rear defrost control popup
        Popup {
            id: rearDefrostPopup
            anchors.centerIn: parent
            width: 400
            height: 300
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            // Property to track rear defrost state
            property bool isRearDefrostOn: false

            // Background rectangle with theme-based styling
            Rectangle {
                anchors.fill: parent
                color: Style.isDark ? "#212121" : "#fafafa"
                radius: 20
                border.color: Style.isDark ? "#424242" : "#e0e0e0"
                border.width: 1

                // Main layout for rear defrost controls
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15

                    // Title for the rear defrost popup
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                        text: "Rear Defrost Control"
                        font.family: "Inter"
                        font.pixelSize: 24
                        font.bold: Font.Medium
                        color: Style.isDark ? "#ffffff" : "#212121"
                    }

                    // Display current rear defrost state
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: rearDefrostPopup.isRearDefrostOn ? "Rear Defrost: ON" : "Rear Defrost: OFF"
                        font.family: "Inter"
                        font.pixelSize: 18
                        color: Style.isDark ? "#ffffff" : "#424242"
                    }

                    // Buttons for controlling rear defrost
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        // Turn on rear defrost
                        Button {
                            text: "Turn On"
                            width: 150
                            height: 50
                            enabled: !rearDefrostPopup.isRearDefrostOn
                            onClicked: {
                                rearDefrostPopup.isRearDefrostOn = true
                                console.log("Rear Defrost turned ON")
                                logger.logMessage("Rear Defrost turned ON")
                            }
                            // Button background with enabled/disabled styling
                            background: Rectangle {
                                color: enabled ? "#4caf50" : "#bdbdbd"
                                radius: 25
                            }
                            // Button text
                            contentItem: Text {
                                text: parent.text
                                font.family: "Inter"
                                font.pixelSize: 18
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Turn off rear defrost
                        Button {
                            text: "Turn Off"
                            width: 150
                            height: 50
                            enabled: rearDefrostPopup.isRearDefrostOn
                            onClicked: {
                                rearDefrostPopup.isRearDefrostOn = false
                                console.log("Rear Defrost turned OFF")
                                logger.logMessage("Rear Defrost turned OFF")
                            }
                            // Button background with enabled/disabled styling
                            background: Rectangle {
                                color: enabled ? "#f44336" : "#bdbdbd"
                                radius: 25
                            }
                            // Button text
                            contentItem: Text {
                                text: parent.text
                                font.family: "Inter"
                                font.pixelSize: 18
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // Close button for the popup
                    Button {
                        text: "Close"
                        width: 120
                        height: 40
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 20
                        onClicked: rearDefrostPopup.close()
                        // Transparent background with themed border
                        background: Rectangle {
                            color: "transparent"
                            border.color: Style.isDark ? "#757575" : "#bdbdbd"
                            border.width: 1
                            radius: 20
                        }
                        // Button text with theme-based color
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 16
                            color: Style.isDark ? "#ffffff" : "#616161"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        // Left seat heater control popup
        Popup {
            id: leftSeatPopup
            anchors.centerIn: parent
            width: 400
            height: 300
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            // Property to track left seat heater state
            property bool isLeftSeatHeaterOn: false

            // Background rectangle with theme-based styling
            Rectangle {
                anchors.fill: parent
                color: Style.isDark ? "#212121" : "#fafafa"
                radius: 20
                border.color: Style.isDark ? "#424242" : "#e0e0e0"
                border.width: 1

                // Main layout for left seat heater controls
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15

                    // Title for the left seat heater popup
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                        text: "Left Seat Heater"
                        font.family: "Inter"
                        font.pixelSize: 24
                        font.bold: Font.Medium
                        color: Style.isDark ? "#ffffff" : "#212121"
                    }

                    // Display current left seat heater state
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: leftSeatPopup.isLeftSeatHeaterOn ? "Left Seat Heater: ON" : "Left Seat Heater: OFF"
                        font.family: "Inter"
                        font.pixelSize: 18
                        color: Style.isDark ? "#ffffff" : "#424242"
                    }

                    // Buttons for controlling left seat heater
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        // Turn on left seat heater
                        Button {
                            text: "Turn On"
                            width: 150
                            height: 50
                            enabled: !leftSeatPopup.isLeftSeatHeaterOn
                            onClicked: {
                                leftSeatPopup.isLeftSeatHeaterOn = true
                                console.log("Left Seat Heater turned ON")
                                logger.logMessage("Left Seat Heater turned ON")
                            }
                            // Button background with enabled/disabled styling
                            background: Rectangle {
                                color: enabled ? "#4caf50" : "#bdbdbd"
                                radius: 25
                            }
                            // Button text
                            contentItem: Text {
                                text: parent.text
                                font.family: "Inter"
                                font.pixelSize: 18
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Turn off left seat heater
                        Button {
                            text: "Turn Off"
                            width: 150
                            height: 50
                            enabled: leftSeatPopup.isLeftSeatHeaterOn
                            onClicked: {
                                leftSeatPopup.isLeftSeatHeaterOn = false
                                console.log("Left Seat Heater turned OFF")
                                logger.logMessage("Left Seat Heater turned OFF")
                            }
                            // Button background with enabled/disabled styling
                            background: Rectangle {
                                color: enabled ? "#f44336" : "#bdbdbd"
                                radius: 25
                            }
                            // Button text
                            contentItem: Text {
                                text: parent.text
                                font.family: "Inter"
                                font.pixelSize: 18
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // Close button for the popup
                    Button {
                        text: "Close"
                        width: 120
                        height: 40
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 20
                        onClicked: leftSeatPopup.close()
                        // Transparent background with themed border
                        background: Rectangle {
                            color: "transparent"
                            border.color: Style.isDark ? "#757575" : "#bdbdbd"
                            border.width: 1
                            radius: 20
                        }
                        // Button text with theme-based color
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 16
                            color: Style.isDark ? "#ffffff" : "#616161"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        // Heated steering wheel control popup
        Popup {
            id: heatedSteeringPopup
            anchors.centerIn: parent
            width: 400
            height: 300
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            // Property to track heated steering wheel state
            property bool isHeatedSteeringOn: false

            // Background rectangle with theme-based styling
            Rectangle {
                anchors.fill: parent
                color: Style.isDark ? "#212121" : "#fafafa"
                radius: 20
                border.color: Style.isDark ? "#424242" : "#e0e0e0"
                border.width: 1

                // Main layout for heated steering wheel controls
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15

                    // Title for the heated steering popup
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                        text: "Heated Steering Control"
                        font.family: "Inter"
                        font.pixelSize: 24
                        font.bold: Font.Medium
                        color: Style.isDark ? "#ffffff" : "#212121"
                    }

                    // Display current heated steering state
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: heatedSteeringPopup.isHeatedSteeringOn ? "Heated Steering: ON" : "Heated Steering: OFF"
                        font.family: "Inter"
                        font.pixelSize: 18
                        color: Style.isDark ? "#ffffff" : "#424242"
                    }

                    // Buttons for controlling heated steering
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        // Turn on heated steering
                        Button {
                            text: "Turn On"
                            width: 150
                            height: 50
                            enabled: !heatedSteeringPopup.isHeatedSteeringOn
                            onClicked: {
                                heatedSteeringPopup.isHeatedSteeringOn = true
                                console.log("Heated Steering turned ON")
                                logger.logMessage("Heated Steering turned ON")
                            }
                            // Button background with enabled/disabled styling
                            background: Rectangle {
                                color: enabled ? "#4caf50" : "#bdbdbd"
                                radius: 25
                            }
                            // Button text
                            contentItem: Text {
                                text: parent.text
                                font.family: "Inter"
                                font.pixelSize: 18
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Turn off heated steering
                        Button {
                            text: "Turn Off"
                            width: 150
                            height: 50
                            enabled: heatedSteeringPopup.isHeatedSteeringOn
                            onClicked: {
                                heatedSteeringPopup.isHeatedSteeringOn = false
                                console.log("Heated Steering turned OFF")
                                logger.logMessage("Heated Steering turned OFF")
                            }
                            // Button background with enabled/disabled styling
                            background: Rectangle {
                                color: enabled ? "#f44336" : "#bdbdbd"
                                radius: 25
                            }
                            // Button text
                            contentItem: Text {
                                text: parent.text
                                font.family: "Inter"
                                font.pixelSize: 18
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // Close button for the popup
                    Button {
                        text: "Close"
                        width: 120
                        height: 40
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 20
                        onClicked: heatedSteeringPopup.close()
                        // Transparent background with themed border
                        background: Rectangle {
                            color: "transparent"
                            border.color: Style.isDark ? "#757575" : "#bdbdbd"
                            border.width: 1
                            radius: 20
                        }
                        // Button text with theme-based color
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 16
                            color: Style.isDark ? "#ffffff" : "#616161"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        // Windshield wiper control popup
        Popup {
            id: wipersPopup
            anchors.centerIn: parent
            width: 400
            height: 300
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            // Property to track wiper state
            property bool areWipersOn: false

            // Background rectangle with theme-based styling
            Rectangle {
                anchors.fill: parent
                color: Style.isDark ? "#212121" : "#fafafa"
                radius: 20
                border.color: Style.isDark ? "#424242" : "#e0e0e0"
                border.width: 1

                // Main layout for wiper controls
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15

                    // Title for the wiper popup
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                        text: "Wiper Control"
                        font.family: "Inter"
                        font.pixelSize: 24
                        font.bold: Font.Medium
                        color: Style.isDark ? "#ffffff" : "#212121"
                    }

                    // Display current wiper state
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: wipersPopup.areWipersOn ? "Wipers: ON" : "Wipers: OFF"
                        font.family: "Inter"
                        font.pixelSize: 18
                        color: Style.isDark ? "#ffffff" : "#424242"
                    }

                    // Buttons for controlling wipers
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        // Turn on wipers
                        Button {
                            text: "Turn On"
                            width: 150
                            height: 50
                            enabled: !wipersPopup.areWipersOn
                            onClicked: {
                                wipersPopup.areWipersOn = true
                                console.log("Wipers turned ON")
                                logger.logMessage("Wipers turned ON")
                            }
                            // Button background with enabled/disabled styling
                            background: Rectangle {
                                color: enabled ? "#4caf50" : "#bdbdbd"
                                radius: 25
                            }
                            // Button text
                            contentItem: Text {
                                text: parent.text
                                font.family: "Inter"
                                font.pixelSize: 18
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Turn off wipers
                        Button {
                            text: "Turn Off"
                            width: 150
                            height: 50
                            enabled: wipersPopup.areWipersOn
                            onClicked: {
                                wipersPopup.areWipersOn = false
                                console.log("Wipers turned OFF")
                                logger.logMessage("Wipers turned OFF")
                            }
                            // Button background with enabled/disabled styling
                            background: Rectangle {
                                color: enabled ? "#f44336" : "#bdbdbd"
                                radius: 25
                            }
                            // Button text
                            contentItem: Text {
                                text: parent.text
                                font.family: "Inter"
                                font.pixelSize: 18
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // Close button for the popup
                    Button {
                        text: "Close"
                        width: 120
                        height: 40
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 20
                        onClicked: wipersPopup.close()
                        // Transparent background with themed border
                        background: Rectangle {
                            color: "transparent"
                            border.color: Style.isDark ? "#757575" : "#bdbdbd"
                            border.width: 1
                            radius: 20
                        }
                        // Button text with theme-based color
                        contentItem: Text {
                            text: parent.text
                            font.family: "Inter"
                            font.pixelSize: 16
                            color: Style.isDark ? "#ffffff" : "#616161"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
