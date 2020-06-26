import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0
import QZXing 2.3
import QtMultimedia 5.12
import MyExtentions 1.0

import "./qml/myTemplates" as My

Page {
    id: page
    title: "Admin menu"
    focus: true
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            stackView.pop();
            event.accepted = true;
        }
    }

    My.SettingsHeader {
        id: msh
        headertext: qsTr("Admin menu")+mytrans.emptyString
        fontsize: fontSize
    }

    Flickable {
        anchors {
            top: msh.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentWidth: parent.width
        contentHeight: 7*mtf1.height+5*column.space
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        Pane {
            anchors.fill: parent
            focusPolicy: Qt.ClickFocus
        }
        Column {
            id: column
            anchors.fill: parent
            topPadding: 10
            property int space: page.height/50
            My.TextField {
                id: mtf1
                labelWidth: mtf3.labelWidth
                labelText: qsTr("Server IP")+mytrans.emptyString
                placeholderText: globalSettings.serverIP!==""?globalSettings.serverIP:"ip"
                fontsize: fontSize
                selectByMouse: true
                inputMethodHints: Qt.ImhDigitsOnly
                onTextFieldChanged: globalSettings.serverIP=fieldText
            }
            Rectangle {height: column.space; width: height ; color: "transparent"}
            My.TextField {
                id: mtf2
                labelWidth: mtf3.labelWidth
                labelText: qsTr("Server port")+mytrans.emptyString
                placeholderText: globalSettings.serverPort!==""?globalSettings.serverPort:"port"
                fontsize: fontSize
                selectByMouse: true
                inputMethodHints: Qt.ImhDigitsOnly
                onTextFieldChanged: globalSettings.serverPort=fieldText
            }
            Rectangle {height: column.space; width: height; color: "transparent"}
            My.TextFieldWithButton {
                id: mtf3
                labelText: qsTr("Server password")+mytrans.emptyString
                fontsize: fontSize
                selectByMouse: true
                buttonSource: "../images/connect.png"
                onTextFieldChanged: globalSettings.serverPassword=fieldText
                placeholderText: globalSettings.serverPassword!==""?"*****":"password"
                onButtonClicked: {
                    connectCheck.sendGet("","ping");
                    popupConnection.open()
                }
            }
            Label {
                id: errorText
                text: qsTr("Can't connect to server")+mytrans.emptyString
                anchors.horizontalCenter: parent.horizontalCenter
                color: "red"
                font.pixelSize: fontSize/1.5
                visible: false
                onVisibleChanged: visible ? timeres.start() : {}
                Timer { id: timeres; interval: 3000; running: false; repeat: false; onTriggered: errorText.visible=false}
            }
            Rectangle {height: errorText.height; width: height ;visible: !errorText.visible; color: "transparent"}

            //            My.NextButton {
            //                text: "Get personal QR code"
            //                imageSource: "../images/forward.png"
            //                fontsize: fontSize
            //                mousearea.onClicked: inputDialog.open()
            //                topline: true
            //            }
            My.NextButton {
                text: qsTr("Create inspector configuration qrcode")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                topline: true
                mousearea.onClicked: pingForConf.sendGet("","ping")
            }
            MyClient {
                id: pingForConf
                ip: globalSettings.serverIP
                port: globalSettings.serverPort
                password: globalSettings.serverPassword
                onGetServerResponse: {
                    if (response=="ping")
                        configureDialog.open()
                    else if (response=="404")
                        wrongPasswordDialog.open()
                    else
                        connectionErrorDialog.open()
                }
            }
            Dialog {
                id: wrongPasswordDialog
                title: qsTr("Info")+mytrans.emptyString
                standardButtons: Dialog.Ok
                anchors.centerIn: parent
                font.pixelSize: fontSize
                Label {
                    text: qsTr("Wrong password!")+mytrans.emptyString
                    width: parent ? parent.width : 100
                    font.pixelSize: fontSize
                    wrapMode: Text.WordWrap
                }
                onClosed: mtf3.activeFocus()
            }
            My.NextButton {
                text: qsTr("Database settings")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                mousearea.onClicked: connectdbCheck.sendGet("","ping")
            }
            My.NextButton {
                text: qsTr("Change role")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                mousearea.onClicked: stackView.push("StartPage.qml");
            }
        }
    }
    MyClient {
        id: connectCheck
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        onGetServerResponse: {
            timerConnection.stop();
            popupConnection.close();
            if (response=="404") {
                errorText.text=qsTr("Wrong server password")+mytrans.emptyString
                errorText.visible=true;
            }
            else if (response=="ping")
                mtf3.buttonColor("limegreen")
            else
            {
                errorText.text=qsTr("Network error")+mytrans.emptyString
                errorText.visible=true;
            }

        }
        onErrorFounded: {
            errorText.text=error;
            popupConnection.close()
        }
    }
    MyClient {
        id: connectdbCheck
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        onGetServerResponse:{
            if (response=="ping")
                stackView.push("DBSettingsPage.qml")
            else if (response=="404")
                wrongPasswordDialog.open()
            else
                connectionErrorDialog.open()
        }
    }
    Dialog {
        id: connectionErrorDialog
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Cant connect to server. Check connection settings or network connection")+mytrans.emptyString
            width: parent ? parent.width : 100
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
    }
    Popup {
        id: popupConnection
        anchors.centerIn: parent
        width: parent.width/4
        height: width
        modal: true
        focus: true
        background: Rectangle {anchors.fill: parent; color: "transparent"}
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        BusyIndicator {
            anchors.fill: parent
            running: true
        }
        onOpened: timerConnection.start()
        onClosed: timerConnection.stop()
        Timer {
            id: timerConnection
            interval: 3000; running: false; repeat: false
            onTriggered: {
                popupConnection.close();
                errorText.visible = true;
                errorText.text=qsTr("Connection timed out")+mytrans.emptyString
            }
        }
    }

    Dialog {
        id: inputDialog
        parent: Overlay.overlay
        modal: true
        title: qsTr("Input")+mytrans.emptyString
        font.pixelSize: fontSize
        standardButtons: Dialog.Ok | Dialog.Cancel
        closePolicy: Popup.NoAutoClose

        ColumnLayout {
            anchors.fill: parent
            Label {
                elide: Label.ElideRight
                text: qsTr("Enter personal ID:")+mytrans.emptyString
                font.pixelSize: fontSize
                Layout.fillWidth: true
                bottomPadding: 10
            }

            TextField {
                id: idtext
                placeholderText: "ID"
                font.pixelSize: fontSize
                selectByMouse: true
                Layout.fillWidth: true
            }
            Label {
                id: errortext
                text: "ID"+qsTr(" was not found. Try again.")+mytrans.emptyString
                color: "red"
                font.pixelSize: fontSize/1.5
                visible: false
            }
        }
        onAccepted: {
            imageEncoded2.source= "image://QZXing/encode/"+idtext.text;
            popupQR2.open()
        }
        //onClosed: {idtext.text = ""; errortext.visible = false;}
    }

    Dialog {
        id: configureDialog
        anchors.centerIn: parent
        modal: true
        title: qsTr("Input")
        font.pixelSize: fontSize
        standardButtons: Dialog.Ok | Dialog.Cancel
        closePolicy: Popup.NoAutoClose

        ColumnLayout {
            anchors.fill: parent
            Label {
                id: labelName
                elide: Label.ElideRight
                text: qsTr("Configurabe Inspector ID:")+mytrans.emptyString
                font.pixelSize: fontSize
                Layout.fillWidth: true
                bottomPadding: 0
            }
            TextField {
                id: nameText
                placeholderText: qsTr("name")+mytrans.emptyString
                height: mcbwb.height
                font.pixelSize: fontSize
                selectByMouse: true
                Layout.fillWidth: true
                Settings {
                    property alias nameText: nameText.text
                }
            }
            Label {
                id: clientPass
                elide: Label.ElideRight
                text: qsTr("Client password: ")+mytrans.emptyString
                font.pixelSize: fontSize
                Layout.fillWidth: true
                bottomPadding: 0
            }
            TextField {
                id: clientPassText
                height: mcbwb.height
                placeholderText: qsTr("password")+mytrans.emptyString
                font.pixelSize: fontSize
                selectByMouse: true
                Layout.fillWidth: true
                Settings {
                    property alias passText: clientPassText.text
                }
            }
            Label {
                id: labelDelay
                elide: Label.ElideRight
                text: qsTr("Re-authorization delay:")+mytrans.emptyString
                font.pixelSize: fontSize
                Layout.fillWidth: true
                bottomPadding: 0
            }
            TextField {
                id: delayText
                height: labelDelay.height*2
                placeholderText: qsTr("seconds")+mytrans.emptyString
                font.pixelSize: fontSize
                selectByMouse: true
                inputMethodHints: Qt.ImhDigitsOnly
                Layout.fillWidth: true
                Settings {
                    property alias delayTime: delayText.text
                }
            }
            //            Label {
            //                id: labelCam
            //                elide: Label.ElideRight
            //                text: qsTr("Camera:")
            //                font.pixelSize: fontSize
            //                Layout.fillWidth: true
            //                bottomPadding: 0
            //            }
            //            ComboBox {
            //                id: comboCal
            //                model: ["Back camera", "Front camera"]
            //                font.pixelSize: fontSize
            //                Layout.fillWidth: true
            //                Settings {
            //                    property alias currentIndex: comboCal.currentIndex
            //                }
            //            }
            My.ComboBoxWithButton {
                id: mcbwb
                labelText: qsTr("Sound")+mytrans.emptyString
                model: ["mute","sound1", "sound2", "sound3", "sound4", "sound5"]
                labelWidth: column.maxLabWidth
                fontsize: fontSize
                buttonSource: "../images/sound.png"
                box.onCurrentValueChanged: globalSettings.soundSource=box.currentText
                box.currentIndex: Number(globalSettings.soundSource[5])
                labelLeftPadding: 0
                onButtonClicked: {
                    playSound.source="../sounds/"+box.currentText+".wav"
                    playSound.play()
                }
                SoundEffect {
                    id: playSound
                    volume: 0.2
                    source: "../sounds/sound1.wav"
                }
            }
        }
        onAccepted: {
            if (nameText.text!=="" && delayText.text!=="" && clientPassText.text!=="" /*&& comboCal.currentIndex!=""*/ && clientPass.text!="" && globalSettings.serverIP!="" && globalSettings.serverPort!="" && globalSettings.serverPassword!="" && mcbwb.box.currentValue!="")
            {
                let confstr = "image://QZXing/encode/settings|"+nameText.text +"|"+delayText.text+"|1|"+clientPassText.text+"|"+globalSettings.serverIP+"|"+globalSettings.serverPort+"|"+globalSettings.serverPassword+"|"+mcbwb.box.currentValue+"?correctionLevel=H&format=qrcode";
                console.log(confstr);
                imageEncoded.source=confstr;
                popupQR.open();
            }
            else if (nameText.text==="")
                nameText.forceActiveFocus()
            else if (delayText.text==="")
                delayText.forceActiveFocus()
            else if (clientPassText.text==="")
                clientPassText.forceActiveFocus()
        }
    }


    Popup {
        id: popupQR
        anchors.centerIn: parent
        width: parent.width
        height: width
        modal: true
        focus: true
        background: Rectangle {anchors.fill: parent; color: "white"}

        //        BusyIndicator {
        //            anchors.centerIn: parent
        //            height: parent.width/4
        //            width: height
        //            running: imageEncoded.status === Image.Loading
        //        }
        Image{
            id: imageEncoded
            anchors.centerIn: parent
            visible: true
            cache: false
            sourceSize.width: parent.width/1.1
            sourceSize.height: parent.width/1.1
            //onSourceChanged: visible=true
        }
        onClosed: configureDialog.open()
    }
    Popup {
        id: popupQR2
        anchors.centerIn: parent
        width: parent.width
        height: width
        modal: true
        focus: true
        background: Rectangle {anchors.fill: parent; color: "white"}

        //        BusyIndicator {
        //            anchors.centerIn: parent
        //            height: parent.width/4
        //            width: height
        //            running: imageEncoded.status === Image.Loading
        //        }
        Image{
            id: imageEncoded2
            anchors.centerIn: parent
            visible: true
            cache: false
            sourceSize.width: parent.width/1.1
            sourceSize.height: parent.width/1.1
            //onSourceChanged: visible=true
        }
    }
}

