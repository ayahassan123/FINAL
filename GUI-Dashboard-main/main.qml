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

ApplicationWindow {
    id: root
    property var logger: Logger
    property var theme: Style
    property bool isFrunkOpen: false
    property bool isTrunkOpen: false
    property bool isLocked: false
    property bool isCharging: false

    width: 1920
    height: 1200
    visible: true
    title: qsTr("Tesla Screen")

    FontLoader {
        id: uniTextFont
        source: "qrc:/Fonts/Unitext Regular.ttf"
    }

    background: Loader {
        anchors.fill: parent
        sourceComponent: theme.mapAreaVisible ? backgroundRect : backgroundImage
    }

    Header {
        id: headerLayout
        z: 99
    }

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

    TopLeftButtonIconColumn {
        z: 99
        anchors {
            left: parent.left
            top: headerLayout.bottom
            leftMargin: 18
        }
    }

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
    RowLayout {
        id: mapLayout
        visible: theme.mapAreaVisible
        spacing: 0
        anchors.fill: parent

        Item {
            id: carSpeedLayer
            Layout.preferredWidth: 620
            Layout.fillHeight: true

            // دمج الصورة والعداد كـ Layer واحد
            Item {
                id: integratedCarSpeed
                anchors.fill: parent

                Image {
                    id: carImage
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        topMargin: -60 // إزالة المسافة فوق الصورة
                    }
                    source: theme.isDark ? "qrc:/icons/light/sidebar.png" : "qrc:/icons/dark/sidebar-light.png"
                    width: 900
                    height: 1200
                    fillMode: Image.PreserveAspectFit
                }

                Item {
                    id: speedometerContainer
                    width: 180
                    height: 180
                    anchors {
                        top: carImage.bottom
                        horizontalCenter: parent.horizontalCenter
                        topMargin: -380 // تقليل المسافة لتبدو متكاملة
                    }

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
                            ctx.fillStyle = "#87CEEB"; // لون أزرق سماوي
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

        NavigationMapHelperScreen {
            Layout.fillWidth: true
            Layout.fillHeight: true
            runMenuAnimation: true
        }
    }

    // مؤقت بسرعة تغيير 5000 مللي ثانية مع قفزات ثابتة (20, 40, 60, ...)
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

    function animateSpeedChange(newSpeed) {
        speedAnimation.from = speedometerNeedle.currentSpeed;
        speedAnimation.to = newSpeed;
        speedAnimation.start();
    }

    NumberAnimation {
        id: speedAnimation
        target: speedometerNeedle
        property: "currentSpeed"
        duration: 800
        easing.type: Easing.OutQuad
    }

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
    MediaPlayer {
        id: musicPlayer
        source: ""
        onError: {
            errorText.text = "Error: " + errorString
            errorText.visible = true
            console.log("MediaPlayer error:", errorString)
        }
    }

    FileDialog {
        id: fileDialog
        title: "Choose an MP3 file"
        folder: "file:///C:/Users/Dell/Downloads" // يفتح مجلد Downloads مباشرة
        nameFilters: ["MP3 files (*.mp3)"]
        onAccepted: {
            musicPlayer.source = fileDialog.fileUrl
            errorText.visible = false
            console.log("Selected file:", musicPlayer.source)
        }
    }
    ListModel {
        id: radioListModel
        ListElement { name: "BBC Radio 1"; streamUrl: "http://stream.live.vc.bbcmedia.co.uk/bbc_radio_one" }
        ListElement { name: "Jazz FM"; streamUrl: "https://jazz-wr-icecast.musicradio.com/JazzFMMP3" }
        ListElement { name: "Radio Sawa"; streamUrl: "https://mbnvoice-2.mbn.org/stream/sawa/sawa_64k" }
        ListElement { name: "NPR"; streamUrl: "https://npr-ice.streamguys1.com/live.mp3" }
        ListElement { name: "Radio France"; streamUrl: "https://icecast.radiofrance.fr/fip-midfi.mp3" }
    }

    ListModel {
        id: musicListModel
        // استبدل song1.mp3, song2.mp3, song3.mp3 بأسماء الملفات الفعلية
        ListElement { name: "Song 1"; filePath: "file:///C:/Users/Dell/Downloads/song1.mp3" }
        ListElement { name: "Song 2"; filePath: "file:///C:/Users/Dell/Downloads/song2.mp3" }
        ListElement { name: "Song 3"; filePath: "file:///C:/Users/Dell/Downloads/song3.mp3" }
        ListElement { name: "Song 4"; filePath: "file:///C:/Users/Dell/Downloads/song4.mp3" }
        ListElement { name: "Song 5"; filePath: "file:///C:/Users/Dell/Downloads/song5.mp3" }
    }

    Component {
        id: backgroundRect
        Rectangle {
            color: "#171717"
            anchors.fill: parent
        }
    }

    Component {
        id: backgroundImage
        Image {
            source: theme.getImageBasedOnTheme()
            Button {
                id: lockButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -350
                    horizontalCenterOffset: 37
                }
                icon.source: theme.isDark ? "qrc:/icons/car_action_icons/dark/lock.svg" : "qrc:/icons/car_action_icons/lock.svg"
                icon.color: root.isLocked ? "#ff0000" : "#00ff00"
                background: Rectangle {
                    color: "transparent"
                }
                onClicked: {
                    root.isLocked = !root.isLocked
                    logger.logMessage("Vehicle " + (root.isLocked ? "locked" : "unlocked"))
                    console.log("Vehicle " + (root.isLocked ? "locked" : "unlocked"))
                }
            }

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

            Button {
                id: chargeButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -250
                    horizontalCenterOffset: 150
                }
                icon.source: theme.isDark ? "qrc:/icons/car_action_icons/dark/charge.svg" : "qrc:/icons/car_action_icons/charge.svg"
                icon.color: root.isCharging ? "#00ff00" : "#ff0000"
                background: Rectangle {
                    color: "transparent"
                }
                onClicked: {
                    root.isCharging = !root.isCharging
                    logger.logMessage("Charge " + (root.isCharging ? "started" : "stopped"))
                    console.log("Charge " + (root.isCharging ? "started" : "stopped"))
                    forceActiveFocus()
                    root.update()
                }
            }

            Icon {
                icon.source: theme.isDark ? "qrc:/icons/car_action_icons/dark/Power.svg" : "qrc:/icons/car_action_icons/Power.svg"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -77
                    horizontalCenterOffset: 550
                }
            }

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
                    }BusyIndicator {
                        id: radioLoadingIndicator
                        Layout.alignment: Qt.AlignHCenter
                        running: radioPlayer.status === MediaPlayer.Loading
                        visible: running
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
    Popup {
        id: calendarPopup
        anchors.centerIn: parent
        width: 500
        height: 600
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property int selectedDay: -1
        property var currentDate: new Date() // تخزين التاريخ الحالي للمقارنة

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
                    text: "Calendar"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    ComboBox {
                        id: monthSelector
                        width: 150
                        model: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
                        currentIndex: currentDate.getMonth()
                        font.family: "Inter"
                        font.pixelSize: 18
                        onCurrentIndexChanged: updateDays()
                    }

                    ComboBox {
                        id: yearSelector
                        width: 100
                        model: ListModel {
                            id: yearModel
                        }
                        currentIndex: 0
                        font.family: "Inter"
                        font.pixelSize: 18
                        Component.onCompleted: {
                            for (var i = 2020; i <= 2030; i++) {
                                yearModel.append({ "text": i })
                            }
                            currentIndex = yearModel.findIndex(function(item) { return item.text === currentDate.getFullYear(); }) || 0;
                        }
                        onCurrentIndexChanged: updateDays()
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
                            text: modelData
                            font.family: "Inter"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            color: Style.isDark ? "#ffffff" : "#212121"
                        }
                    }

                    Repeater {
                        id: daysRepeater
                        model: 0
                        Item {
                            width: 50
                            height: 50

                            Button {
                                id: dayButton
                                anchors.fill: parent
                                text: index + 1
                                font.family: "Inter"
                                font.pixelSize: 18
                                onClicked: {
                                    calendarPopup.selectedDay = index + 1;
                                }

                                background: Item {
                                    anchors.fill: parent

                                    Rectangle {
                                        id: dayBackground
                                        anchors.fill: parent
                                        color: {
                                            var dayDate = new Date(yearSelector.currentText, monthSelector.currentIndex, index + 1);
                                            var today = new Date();

                                            // Reset time components for accurate comparison
                                            dayDate.setHours(0,0,0,0);
                                            today.setHours(0,0,0,0);

                                            if (dayDate.getTime() === today.getTime()) {
                                                return "#4CAF50"; // أزرق لليوم الحالي
                                            } else if (calendarPopup.selectedDay === index + 1) {
                                                return "#4CAF50"; // أخضر لليوم المختار
                                            } else {
                                                return Style.isDark ? "#424242" : "#ffffff";
                                            }
                                        }
                                        radius: 25
                                        border.color: Style.isDark ? "#616161" : "#e0e0e0"
                                        border.width: 1
                                    }

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: "transparent"
                                        border.color: {
                                            var dayDate = new Date(yearSelector.currentText, monthSelector.currentIndex, index + 1);
                                            var today = new Date();

                                            dayDate.setHours(0,0,0,0);
                                            today.setHours(0,0,0,0);

                                            if (dayDate.getTime() === today.getTime() || calendarPopup.selectedDay === index + 1) {
                                                return "#ffffff"; // إطار أبيض لليوم الحالي والمختار
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
                                        var dayDate = new Date(yearSelector.currentText, monthSelector.currentIndex, index + 1);
                                        var today = new Date();

                                        dayDate.setHours(0,0,0,0);
                                        today.setHours(0,0,0,0);

                                        if (dayDate.getTime() === today.getTime() || calendarPopup.selectedDay === index + 1) {
                                            return "#ffffff"; // نص أبيض لليوم الحالي والمختار
                                        } else {
                                            return Style.isDark ? "#ffffff" : "#424242";
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
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: calendarPopup.close()
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

                function updateDays() {
                    var daysInMonth = [31, isLeapYear(yearSelector.currentText) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
                    var selectedMonth = monthSelector.currentIndex;
                    var selectedYear = yearSelector.currentText;
                    var firstDay = new Date(selectedYear, selectedMonth, 1).getDay();
                    var adjustedFirstDay = (firstDay === 0) ? 6 : firstDay - 1;

                    daysRepeater.model = daysInMonth[selectedMonth];

                    for (var i = 0; i < daysRepeater.count; i++) {
                        if (daysRepeater.itemAt(i)) {
                            daysRepeater.itemAt(i).visible = (i >= adjustedFirstDay);
                        }
                    }
                    for (var j = 0; j < adjustedFirstDay; j++) {
                        if (daysRepeater.itemAt(j)) daysRepeater.itemAt(j).visible = false;
                    }
                }

                function isLeapYear(year) {
                    return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
                }

                Component.onCompleted: updateDays()

                Timer {
                    interval: 86400000 // 24 hours
                    running: true
                    repeat: true
                    onTriggered: {
                        currentDate = new Date(); // تحديث التاريخ الحالي
                        updateDays(); // تحديث التقويم
                    }
                }
            }
        }
    }
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

    Popup {
        id: theaterPopup
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
                    text: "Theater Mode"
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
                    model: ["Netflix", "YouTube", "Hulu"]
                    delegate: Button {
                        width: parent.width
                        height: 60
                        text: modelData
                        font.family: "Inter"
                        font.pixelSize: 18
                        onClicked: console.log("Opening:", modelData)
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
                    onClicked: theaterPopup.close()
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

    Popup {
        id: toyboxPopup
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
                    text: "Toybox"
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
                    model: ["Chess", "Fart Sounds", "Santa Mode", "Light Show", "Sketchpad"]
                    delegate: Button {
                        width: parent.width
                        height: 60
                        text: modelData
                        font.family: "Inter"
                        font.pixelSize: 18
                        onClicked: {
                            console.log("Toybox item selected:", modelData);
                            // يمكنك إضافة وظائف لكل عنصر هنا
                            if (modelData === "Chess") {
                                console.log("Launching Chess game");
                            } else if (modelData === "Fart Sounds") {
                                console.log("Playing funny sounds");
                            } else if (modelData === "Santa Mode") {
                                console.log("Activating Santa Mode");
                            }
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
                        }
                    }
                }

                Button {
                    text: "Close"
                    width: 120
                    height: 40
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                    onClicked: toyboxPopup.close()
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

    Popup {
        id: frontDefrostPopup
        anchors.centerIn: parent
        width: 400
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property bool isFrontDefrostOn: false

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
                    text: "Front Defrost Control"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: frontDefrostPopup.isFrontDefrostOn ? "Front Defrost: ON" : "Front Defrost: OFF"
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        text: "Turn On"
                        width: 150
                        height: 50
                        enabled: !frontDefrostPopup.isFrontDefrostOn
                        onClicked: {
                            frontDefrostPopup.isFrontDefrostOn = true
                            console.log("Front Defrost turned ON")
                        }
                        background: Rectangle {
                            color: enabled ? "#4caf50" : "#bdbdbd"
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
                        text: "Turn Off"
                        width: 150
                        height: 50
                        enabled: frontDefrostPopup.isFrontDefrostOn
                        onClicked: {
                            frontDefrostPopup.isFrontDefrostOn = false
                            console.log("Front Defrost turned OFF")
                        }
                        background: Rectangle {
                            color: enabled ? "#f44336" : "#bdbdbd"
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
                    onClicked: frontDefrostPopup.close()
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

    Popup {
        id: rearDefrostPopup
        anchors.centerIn: parent
        width: 400
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property bool isRearDefrostOn: false

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
                    text: "Rear Defrost Control"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: rearDefrostPopup.isRearDefrostOn ? "Rear Defrost: ON" : "Rear Defrost: OFF"
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        text: "Turn On"
                        width: 150
                        height: 50
                        enabled: !rearDefrostPopup.isRearDefrostOn
                        onClicked: {
                            rearDefrostPopup.isRearDefrostOn = true
                            console.log("Rear Defrost turned ON")
                        }
                        background: Rectangle {
                            color: enabled ? "#4caf50" : "#bdbdbd"
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
                        text: "Turn Off"
                        width: 150
                        height: 50
                        enabled: rearDefrostPopup.isRearDefrostOn
                        onClicked: {
                            rearDefrostPopup.isRearDefrostOn = false
                            console.log("Rear Defrost turned OFF")
                        }
                        background: Rectangle {
                            color: enabled ? "#f44336" : "#bdbdbd"
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
                    onClicked: rearDefrostPopup.close()
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

    Popup {
        id: leftSeatPopup
        anchors.centerIn: parent
        width: 400
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property bool isLeftSeatHeaterOn: false

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
                    text: "Left Seat Heater"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: leftSeatPopup.isLeftSeatHeaterOn ? "Left Seat Heater: ON" : "Left Seat Heater: OFF"
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        text: "Turn On"
                        width: 150
                        height: 50
                        enabled: !leftSeatPopup.isLeftSeatHeaterOn
                        onClicked: {
                            leftSeatPopup.isLeftSeatHeaterOn = true
                            console.log("Left Seat Heater turned ON")
                        }
                        background: Rectangle {
                            color: enabled ? "#4caf50" : "#bdbdbd"
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
                        text: "Turn Off"
                        width: 150
                        height: 50
                        enabled: leftSeatPopup.isLeftSeatHeaterOn
                        onClicked: {
                            leftSeatPopup.isLeftSeatHeaterOn = false
                            console.log("Left Seat Heater turned OFF")
                        }
                        background: Rectangle {
                            color: enabled ? "#f44336" : "#bdbdbd"
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
                    onClicked: leftSeatPopup.close()
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

    Popup {
        id: heatedSteeringPopup
        anchors.centerIn: parent
        width: 400
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property bool isHeatedSteeringOn: false

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
                    text: "Heated Steering Control"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: heatedSteeringPopup.isHeatedSteeringOn ? "Heated Steering: ON" : "Heated Steering: OFF"
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        text: "Turn On"
                        width: 150
                        height: 50
                        enabled: !heatedSteeringPopup.isHeatedSteeringOn
                        onClicked: {
                            heatedSteeringPopup.isHeatedSteeringOn = true
                            console.log("Heated Steering turned ON")
                        }
                        background: Rectangle {
                            color: enabled ? "#4caf50" : "#bdbdbd"
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
                        text: "Turn Off"
                        width: 150
                        height: 50
                        enabled: heatedSteeringPopup.isHeatedSteeringOn
                        onClicked: {
                            heatedSteeringPopup.isHeatedSteeringOn = false
                            console.log("Heated Steering turned OFF")
                        }
                        background: Rectangle {
                            color: enabled ? "#f44336" : "#bdbdbd"
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
                    onClicked: heatedSteeringPopup.close()
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

    Popup {
        id: wipersPopup
        anchors.centerIn: parent
        width: 400
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property bool areWipersOn: false

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
                    text: "Wiper Control"
                    font.family: "Inter"
                    font.pixelSize: 24
                    font.bold: Font.Medium
                    color: Style.isDark ? "#ffffff" : "#212121"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: wipersPopup.areWipersOn ? "Wipers: ON" : "Wipers: OFF"
                    font.family: "Inter"
                    font.pixelSize: 18
                    color: Style.isDark ? "#ffffff" : "#424242"
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        text: "Turn On"
                        width: 150
                        height: 50
                        enabled: !wipersPopup.areWipersOn
                        onClicked: {
                            wipersPopup.areWipersOn = true
                            console.log("Wipers turned ON")
                        }
                        background: Rectangle {
                            color: enabled ? "#4caf50" : "#bdbdbd"
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
                        text: "Turn Off"
                        width: 150
                        height: 50
                        enabled: wipersPopup.areWipersOn
                        onClicked: {
                            wipersPopup.areWipersOn = false
                            console.log("Wipers turned OFF")
                        }
                        background: Rectangle {
                            color: enabled ? "#f44336" : "#bdbdbd"
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
                    onClicked: wipersPopup.close()
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
}
