import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import Qt.labs.settings 1.0

import QZXing 2.3

Page {
    id: page
    title: "Viewer Page"
    visible: true

    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            //            stackView.pop();
            event.accepted = true;
        }
    }
    property int detectedTags: 0
    property string lastTag: ""
    property int detectedUnicTags: 0
    Component.onCompleted: {
        showAdvButtons.start()
    }
    Rectangle {
        id: bgRect
        color: "gray"
        anchors.fill: videoOutput
    }

    Camera
    {
        id: camera
        position: globalSettings.cameraPosition
        focus.focusMode: Camera.FocusContinuous
        focus.focusPointMode: Camera.FocusPointCenter
        viewfinder.maximumFrameRate: 5
        onPositionChanged: globalSettings.cameraPosition = camera.position
    }

    QZXingFilter
    {
        id: zxingFilter
        mirroring: globalSettings.cameraPosition === Camera.FrontFace
        captureRect: videoOutput.sourceRect
        decoder {
            enabledDecoders: QZXing.DecoderFormat_QR_CODE
            onTagFound: {

                var res = checkTag(tag, 1000*globalSettings.recordDelay);
                if (res==1)
                {
                    if (tag.indexOf("settings|")!=-1)
                        configureClient(tag);
                    else
                        myclient.sendGet(tag+"|"+globalSettings.checkpointID.toString(), "new visit");
                    page.lastTag = tag;
                    detectedUnicTags++;
                }
                detectedTags++;
                console.log(tag + " | " + decoder.foundedFormat() + " | " + decoder.charSet());
            }
            tryHarder: false
        }
        property int framesDecoded: 0
        property real timePerFrameDecode: 0
        onDecodingFinished:
        {
            timePerFrameDecode = (decodeTime + framesDecoded * timePerFrameDecode) / (framesDecoded + 1);
            framesDecoded++;
            if(succeeded)
                console.log("frame finished: " + succeeded, decodeTime, timePerFrameDecode, framesDecoded);
        }
    }

    ListModel {
        id: tagsHistory
    }

    function checkTag(curTag, delay)
    {
        var founded=false;
        var curTime = new Date().getTime();
        for (var i = 0; i < tagsHistory.count; i++)
        {
            console.log(i+") Tag:"+tagsHistory.get(i)["tag"]+"   Time:"+tagsHistory.get(i)["time"]);
            if (tagsHistory.get(i)["tag"] === curTag)
            {
                founded=true;
                console.log("Проверяем дубликат...  Его время:"+tagsHistory.get(i)["time"]+"    Сейчас:"+curTime+"  Задержка:"+delay);
                if ((curTime - tagsHistory.get(i)["time"])>delay)
                {
                    console.log("Учтен! Обновляем время");
                    //page.detectedUnicTags++;
                    tagsHistory.setProperty(i, "time", curTime)
                    return 1;
                }
                else return -1;
            }
            else if ((curTime - tagsHistory.get(i)["time"])>delay)
            {
                console.log("Удаляем устаревший");
                tagsHistory.remove(i);
                i--;
            }
        }
        if (!founded)
        {
            tagsHistory.append( { "tag" : curTag, "time" : curTime } );
            console.log("Уникальный! Добавляем в список"+ curTag.toString()+" "+ curTime);
            //page.detectedUnicTags++;
            return 1;
        }
        return 0;
    }

    //CONFIGURE

    function configureClient(tag) {
        var confArr = tag.split("|");
        if (globalSettings.clientPassword==="" || globalSettings.clientPassword===confArr[4])
            if (confArr.length===9) {
                globalSettings.checkpointID=confArr[1];
                globalSettings.recordDelay=confArr[2];
                //globalSettings.cameraPosition= (confArr[3]===1) ? Camera.FrontFace : Camera.BackFace;
                globalSettings.clientPassword=confArr[4];
                globalSettings.serverIP=confArr[5];
                globalSettings.serverPort=confArr[6];
                globalSettings.serverPassword=confArr[7];
                globalSettings.soundSource=confArr[8];
            }
       mainwindow.showImg("../images/configured.png")
       myclient.sendGet("","ping");
    }

    VideoOutput
    {
        id: videoOutput
        source: camera
        //opacity: !globalSettings.locked
        //transform: Rotation { origin.x: videoOutput.width/2; origin.y: videoOutput.height/2; axis { x: 0; y: 1; z: 0 } angle: imgRotation }
        anchors.fill: parent
        autoOrientation: true
        fillMode: VideoOutput.PreserveAspectCrop
        filters: [ zxingFilter ]
        MouseArea {
            anchors.fill: parent
            onClicked: {
                //                camera.focus.customFocusPoint = Qt.point(mouse.x / width,  mouse.y / height);
                //                camera.focus.focusMode = CameraFocus.FocusMacro;
                //                camera.focus.focusPointMode = CameraFocus.FocusPointCustom;
                hideAdvButtons.stop()
                showAdvButtons.start()
            }
        }
    }


    PropertyAnimation {
        id: showAdvButtons
        targets: [debugButton, settingsButton, lockButton, switchButton]
        properties: "opacity"
        from: debugButton.opacity
        to: 1
        duration: 1000
        running: false
        onStarted:  advButShowTimer.restart()
    }
    Timer {
        id: advButShowTimer
        interval: 5000; running: false; repeat: false
        onTriggered: hideAdvButtons.restart()
    }
    PropertyAnimation {
        id: hideAdvButtons
        targets: [debugButton, settingsButton, lockButton, switchButton]
        properties: "opacity"
        from: debugButton.opacity
        to: 0
        duration: 1000
        running: false
    }

    Image {
        id: debugButton
        source: "../images/debug.png"
        x: 10
        y: 7
        width: parent.width/10
        height: width
        z: 3
        sourceSize.height: width
        sourceSize.width: width
        visible: !globalSettings.locked
        Rectangle {
            z:parent.z-1
            anchors.centerIn: parent
            height: parent.height*2.1
            width: height
            color: "white"
            opacity: 0.2
            radius: height/2
        }
        MouseArea {
            anchors.fill: parent
            onClicked: globalSettings.debug=!globalSettings.debug
        }
    }
    Image {
        id: settingsButton
        source: "../images/settings_bold.png"
        x: parent.width-10-width
        y: 10
        width: parent.width/10
        height: width
        z: 4
        sourceSize.height: width
        sourceSize.width: width
        visible: !globalSettings.locked
        Rectangle {
            z:parent.z-1
            anchors.centerIn: parent
            height: parent.height*2.1
            width: height
            color: "white"
            opacity: 0.2
            radius: height/2
        }
        MouseArea {
            anchors.fill: parent
            onClicked: stackView.push("ClientSettingsPage.qml")
        }
    }
    Image {
        id: lockButton
        source: "../images/unlocked.png"
        x: 10
        y: parent.height-height-10
        width: parent.width/10
        height: width
        z: 3
        sourceSize.height: width
        sourceSize.width: width
        visible: !globalSettings.locked
        Rectangle {
            z:parent.z-1
            anchors.centerIn: parent
            height: parent.height*2.1
            width: height
            color: "white"
            opacity: 0.2
            radius: height/2
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("Trying to lock the app");
                (globalSettings.clientPassword!=="") ? globalSettings.locked=true : console.log("password: "+ globalSettings.clientPassword)
            }
        }
    }
    Image {
        id: switchButton
        source: "../images/camera.png"
        x: parent.width-width-10
        y: parent.height-width-10
        width: parent.width/10
        height: width
        z: 3
        sourceSize.height: width
        sourceSize.width: width
        visible: !globalSettings.locked
        Rectangle {
            z:parent.z-1
            anchors.centerIn: parent
            height: parent.height*2.1
            width: height
            color: "white"
            opacity: 0.2
            radius: height/2
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (globalSettings.cameraPosition === Camera.FrontFace) {
                    globalSettings.cameraPosition = Camera.BackFace
                    zxingFilter.mirroring = false
                    console.log("changed to back");
                } else {
                    globalSettings.cameraPosition = Camera.FrontFace
                    zxingFilter.mirroring = true
                    console.log("changed to front");
                }
            }
        }
    }

    Rectangle {
        id: debugRect
        width: parent.width
        height:debugColumn.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: globalSettings.debug
        z: 3
        Column{
            id: debugColumn
            width: parent.width
            opacity: 0.5
            RowLayout{
                width: parent.width
                Text
                {
                    id: text1
                    wrapMode: Text.Wrap
                    font.pixelSize: 20
                    Layout.alignment: Qt.AlignLeft
                    text: "Tags detected: " + page.detectedTags +"    Registered: " + page.detectedUnicTags
                }
                Text
                {
                    id: fps
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight
                    z:5
                    text: (1000 / zxingFilter.timePerFrameDecode).toFixed(0) + "fps"
                }
            }
            Text {
                id: text2
                wrapMode: Text.Wrap
                font.pixelSize: 20
                text: "Last tag: " + page.lastTag
            }
            TextArea {
                id: textArea
            }
        }
    }
}
