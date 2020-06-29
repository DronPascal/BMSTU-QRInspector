import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.0
import QtMultimedia 5.12
import QtGraphicalEffects 1.12

import QZXing 2.3
import MyExtentions 1.0
import "./qml/myTemplates" as My
import MyLang 1.0

ApplicationWindow
{
    id: window
    visible: true
    width: 400
    height: 600
    property alias fontSize: stackView.fontSize
    property alias stackView : stackView
    property alias globalSettings : globalSettings
    property alias initSettings : initSettings
    property alias mainwindow: window

    property alias photopreview: window.photopreview
    property string photopreview: ""
    property alias photosave: window.photosave
    property string photosave: ""

    Component.onCompleted: {
        setLanguage(globalSettings.lang)
        if (globalSettings.guide)
            instructor.pageGuide(stackView.currentItem.title)
    }

    Settings {
        id: globalSettings

        property string checkpointID: ""
        property string clientPassword: ""
        property double recordDelay: 10

        property string serverIP: ""
        property string serverPort: ""
        property string serverPassword: ""
        property string dbPassword: ""
        property string sudoPassword: ""
        property string soundSource: "sound1"

        property string nameConfiguratorText: ""
        property string cliPasConfiguratorText:""
        property string ipConfiguratorText: ""
        property string portConfiguratorText:""
        property string passConfiguratorText: ""

        property int cameraPosition: 1

        property bool debug: false
        property bool locked : false
        property bool connectedToServer: false
        property string lang: ""
        property bool guide: initSettings.initItem==="StartPage.qml"
        onLangChanged: setLanguage(globalSettings.lang)
        //onGuideChanged: guide=false
    }

    StackView {
        id: stackView
        property int fontSize: Math.min(height, width)/22
        property int prevDepth: 0
        initialItem: initSettings.initItem
        anchors.fill: parent
        Settings{
            id: initSettings
            property string initItem: "StartPage.qml"
        }
        Component.onDestruction: {
            initSettings.initItem = stackView.initialItem
        }
        onCurrentItemChanged: {
            if (depth===0)
                push("StartPage.qml")
            if (window.globalSettings.guide)
            {
                console.log(window.globalSettings.guide)
                instructor.pageGuide(currentItem.title)
            }
            if (prevDepth>depth)
                currentItem.update();
            prevDepth=depth;
            hideImg();

            if (currentItem.title==="Add/Edit Member Page")
                currentItem.setphotosource(photopreview)
        }
    }
    My.AppInstructor {
        id: instructor
        parent: stackView
        anchors.fill: parent
        anchors.centerIn: parent
        fontsize: fontSize
    }

    MyClient {
        id: myclient
        property bool reactOnImg: false
        property alias myclient : myclient
        property int id: 0
        ip: globalSettings.serverIP.toString()
        port: globalSettings.serverPort.toString()
        password: globalSettings.serverPassword
        onGetServerResponse: {
            if (response=="defaultface")
            {
                photoImage.source= "../images/default_face.png"
                consoleImg.source = "../images/default_face.png"
                playSound.play()
                photoImageShowAnim.start();
                grantedAnim.restart();
            }
            else if (response=="404")
            {
                photoImage.source= "../images/nokey.png"
                consoleImg.source = "../images/nokey.png"
                photoImageShowAnim.start();
            }
            else if (response=="ping")
            {
                pingGoodTimer.start()
            }
            else
            {
                if (response=="accessdenied")
                    photoImage.source= "../images/accessdenied.png"
                else if (response=="databaseerror")
                    photoImage.source= "../images/crash.png"
                consoleText.text += "\n"+response;
                photoImageShowAnim.start();
            }
        }
        onGetImgFromServer: {
            consoleImg.source = "image://serverImgProvider/"+id++;
            photoImage.source = "image://serverImgProvider/"+id++;
            playSound.play()
            photoImageShowAnim.start();
            grantedAnim.restart();
        }
        onErrorFounded: {
            photoImage.source= "../images/connecterror.png"
            consoleText.text+=error;
        }

    }
    Timer {
        id: pingGoodTimer
        interval: 1000; running: false; repeat: false
        onTriggered: {
            photoImage.source= "../images/checked.png"
            consoleImg.source = "../images/checked.png"
            photoImageShowAnim.start();
        }
    }

    SoundEffect {
        id: playSound
        volume: 1
        source: "../sounds/"+globalSettings.soundSource+".wav"
    }

    function showImg(path){
        photoImage.source= path
        photoImageShowAnim.start();
        photoShowTimer.restart();
    }
    function hideImg()
    {
        photoImageShowAnim.stop();
        photoImageaHideAnim.restart()
    }
    function setLanguage(lang)
    {

        if (lang==="Russian")
            mytrans.updateLanguage(MyLang.RU)
        else
            mytrans.updateLanguage(MyLang.EN)
    }
    function changeRole(){
        initSettings.initItem="StartPage.qml"
        stackView.clear()
        stackView.push("StartPage.qml")
    }

    //ФОТО ВОШЕДШЕГО    //ФОТО ВОШЕДШЕГО    //ФОТО ВОШЕДШЕГО    //ФОТО ВОШЕДШЕГО    //ФОТО ВОШЕДШЕГО    //ФОТО ВОШЕДШЕГО
    Rectangle{
        id: photoArea
        width: parent.width/1.2
        visible: false
        height: width
        color: "ghostwhite"
        anchors.centerIn: parent
        radius: width/2
        border.width: 2
        border.color: "black"
        Image  {
            id: photoImage
            parent: photoArea
            opacity: photoArea.opacity
            width: parent.width
            height: width
            sourceSize.width: width
            sourceSize.height: width
            anchors.centerIn: parent
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: photoImage.width
                    height: width
                    Rectangle {
                        anchors.centerIn: parent
                        width: photoImage.width
                        height: width
                        radius: width/2
                    }
                }
            }
        }
        OpacityMask {
            id: roundedPhoto
            anchors.fill: parent
            source: photoImage
            maskSource: parent
            visible: (photoImage.status==Image.Ready)
        }
        Timer {
            id: photoShowTimer
            interval: 4000; running: false; repeat: false
            onTriggered: photoImageaHideAnim.restart();
        }
    }
    PropertyAnimation {
        id: photoImageShowAnim
        targets: photoArea
        properties: "opacity"
        from:0
        to: 0.8
        duration: 500
        running: false
        onStarted: {
            photoShowTimer.restart();
            photoImageaHideAnim.stop();
            photoArea.visible=true;
        }
    }
    PropertyAnimation {
        id: photoImageaHideAnim
        targets: photoArea
        properties: "opacity"
        from: photoImage.opacity
        to: 0
        duration: 500
        running: false
        onFinished: photoArea.visible=false
    }

    Image {
        id: granted
        width: photoImage.width*0.7
        height: width
        z:10
        opacity: 0
        visible: false
        sourceSize.width: width
        sourceSize.height: width
        anchors.centerIn: parent
        source: "../images/accept_light.png"

    }
    PropertyAnimation {
        id:  grantedAnim
        onStarted: {
            grantedAnimHide.stop()
            granted.visible=true
        }
        targets: granted
        properties: "opacity"
        from: 0
        to: 1
        duration: 500
        onFinished: grantedAnimHide.start()
    }
    PropertyAnimation {
        id:  grantedAnimHide
        onStarted: granted.visible=true
        targets: granted
        properties: "opacity"
        from: granted.opacity
        to: 0
        duration: 1500
        onFinished: granted.visible=false
    }

    //БЛОКИРОВКА    //БЛОКИРОВКА    //БЛОКИРОВКА    //БЛОКИРОВКА    //БЛОКИРОВКА    //БЛОКИРОВКА    //БЛОКИРОВКА

    MouseArea {
        id: mainMouseArea
        enabled: globalSettings.locked
        anchors.fill: parent
        onPressed: {
            passwordPopup.open();
            passwordText.forceActiveFocus();
            lockingAnimation.start()
        }
    }
    Image {
        id: lockImage
        anchors.horizontalCenter: stackView.horizontalCenter
        y: parent.height/2
        z: 3
        opacity: 1
        visible: globalSettings.locked
        source: "../images/locked.png"
        width: parent.width/2
        height: width
        sourceSize.width: width
        sourceSize.height: width
        onVisibleChanged: lockingAnimation.start()
    }
    Timer {
        id: lockShowTimer
        interval: 3000; running: false; repeat: false
        onTriggered: lockImage.opacity=0
    }
    PropertyAnimation {
        id: lockingAnimation
        target: lockImage
        properties: "opacity"
        from: 0
        to: 1
        duration: 500
        running: false
        onFinished: lockShowTimer.start()
    }
    Popup {
        id: passwordPopup
        anchors.centerIn: parent
        width: stackView.width/2
        background: Rectangle {}
        modal: true
        TextField {
            id: passwordText
            anchors.centerIn: parent
            placeholderText: qsTr("password")+mytrans.emptyString

            background: Rectangle {anchors.fill: parent; radius: height/3; width: parent.width*1.1}
            font.pixelSize: fontSize
            width: stackView.width/2
            onAccepted: if (text === globalSettings.clientPassword) {
                            text="";
                            passwordPopup.close();
                            globalSettings.locked = false;
                        }
                        else {
                            textAnimation.start();
                            textAnimation2.start();
                        }
        }
        PropertyAnimation {
            id: textAnimation
            target: passwordPopup
            properties: "scale"
            easing.type: Easing.OutInBounce
            from:1
            to: 1.2
            duration: 200
            running: false
        }
        PropertyAnimation {
            id: textAnimation2
            target: passwordPopup
            properties: "scale"
            easing.type: Easing.OutInBounce
            from:1.2
            to: 1
            duration: 200
            running: false
        }
    }

    Rectangle {
        id: myconsole
        property alias consoleText: consoleText
        z: 10
        width: parent.width*0.6
        height: parent.height*0.15
        visible: globalSettings.debug
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0.7
        Flickable {
            id: flickable
            flickableDirection: Flickable.VerticalFlick
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: consoleField.top
            }
            TextArea.flickable: TextArea {
                id: consoleText
                text: "Console log\n"
                readOnly: true
                onTextChanged: { consoleText.cursorPosition = consoleText.length }
            }
            ScrollBar.vertical: ScrollBar { }
        }
        TextField {
            id: consoleField
            height: fontSize*2.5
            font.pixelSize: fontSize
            width:flickable.width
            selectByMouse: true
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: consoleButt.left
            onAccepted: myconsole.exec()
        }
        Rectangle {
            id: consoleButt
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: consoleField.height
            width: parent.width*0.2
            border.color: "darkgrey"
            Image {
                id: execbut
                anchors.centerIn: parent
                height: parent.height*0.8
                width: height
                sourceSize.width: height
                sourceSize.height: height
                source: "../images/execute.png"
            }
            MouseArea {
                anchors.fill: parent
                onPressed: myconsole.exec()
            }
        }
        function exec()
        {
            consoleText.text+="\nexec: "+consoleField.text;
            if (consoleField.text ==="reset")
            {
                globalSettings.lang=""
                globalSettings.guide="true"
                instructor.reset()
                initSettings.initItem="StartPage.qml"
                stackView.clear()
                stackView.clear()
                stackView.push("StartPage.qml")
            }
            else if (consoleField.text === "test")
                myclient.sendGet("cat");
            else if (consoleField.text.indexOf("images/")!==-1)
                myclient.sendGet(consoleField.text);
            else if (consoleField.text==="close")
                globalSettings.debug=false;
            else if (consoleField.text==="ping")
                myclient.sendGet("","ping");
            else if (consoleField.text.indexOf(", new visit")!==-1)
                myclient.sendGet(consoleField.text.split(", ")[0],consoleField.text.split(", ")[1]);
            else
                consoleText.text+="\ncommand not founded";
        }

        Image  {
            id: consoleImg
            visible: true
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            anchors.top: parent.top
            anchors.right: parent.right
            width: parent.height*0.5
            height: width
            onSourceChanged: consoleImgTimer.start()
        }

        Timer {
            id: consoleImgTimer
            interval: 2000; running: false; repeat: false
            onTriggered: {
                consoleImg.source=":/none"
            }
        }
    }


    //##########################################
    property alias successanimation: successanimation
    AnimatedImage {
        id: successanimation;
        z:11
        width: parent.width
        height: width
        visible: false
        paused: true
        anchors.centerIn: parent
        source: "../gif/success.gif"
        onCurrentFrameChanged: {
            if (currentFrame==frameCount-1)
            {
                paused=true;
                visible=false
            }
        }
        //onPlayingChanged: playing ? visible=true : {}
        function play(){
            currentFrame=0
            successanimation.paused=false
            successanimation.visible=true
        }
    }

}
