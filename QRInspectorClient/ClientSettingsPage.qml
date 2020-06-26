import QtQuick 2.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12
import Qt.labs.settings 1.0

import MyExtentions 1.0
import "./qml/myTemplates" as My

Page {
    id: page
    title: "Client settings"
    focus: true
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            stackView.pop();
            event.accepted = true;
        }
    }
    property bool askSetPassword: false
    Component.onCompleted: askSetPassword ? mtf6.activeFocus(): {}
    My.SettingsHeader {
        id: msh
        headertext: qsTr("Settings")+mytrans.emptyString+mytrans.emptyString
        fontsize: fontSize
        backSource: "../images/back_bold.png"
        onBackClicked: stackView.pop();
    }

    Flickable {
        anchors {
            top: msh.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentWidth: parent.width
        contentHeight: 8*mtf1.height+7*column.spacing
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
            spacing: page.height/50
            property alias maxLabWidth: mtf6.labelWidth
            My.TextField {
                id: mtf1
                labelWidth: column.maxLabWidth
                labelText: qsTr("Inspector ID")+mytrans.emptyString
                placeholderText: globalSettings.checkpointID!==""?globalSettings.checkpointID:"ID"
                fontsize: fontSize
                selectByMouse: true
                onFieldTextChanged: globalSettings.checkpointID=fieldText
            }
            My.TextField {
                id: mtf2
                labelWidth: column.maxLabWidth
                labelText: qsTr("Re-auth. delay")+mytrans.emptyString
                placeholderText: globalSettings.recordDelay+" seconds"
                fontsize: fontSize
                selectByMouse: true
                inputMethodHints: Qt.ImhDigitsOnly
                onFieldTextChanged: globalSettings.recordDelay=fieldText
            }
            My.TextField {
                id: mtf3
                labelWidth: column.maxLabWidth
                labelText: qsTr("Client password")+mytrans.emptyString
                placeholderText: globalSettings.clientPassword!==""?"*****":"password"
                fontsize: fontSize
                selectByMouse: true
                onFieldTextChanged: globalSettings.clientPassword=fieldText
            }
            My.TextField {
                id: mtf4
                labelWidth: column.maxLabWidth
                labelText: qsTr("Server IP")+mytrans.emptyString
                placeholderText: globalSettings.serverIP!==""?globalSettings.serverIP:"IP"
                fontsize: fontSize
                selectByMouse: true
                inputMethodHints: Qt.ImhDigitsOnly
                onFieldTextChanged: globalSettings.serverIP=fieldText
            }
            My.TextField {
                id: mtf5
                labelWidth: column.maxLabWidth
                labelText: qsTr("Server port")+mytrans.emptyString
                placeholderText: globalSettings.serverPort!==""?globalSettings.serverPort:"port"
                fontsize: fontSize
                selectByMouse: true
                inputMethodHints: Qt.ImhDigitsOnly
                onFieldTextChanged: globalSettings.serverPort=fieldText
            }
            My.TextFieldWithButton {
                id: mtf6
                labelText: qsTr("Server password")+mytrans.emptyString
                fontsize: fontSize
                selectByMouse: true
                buttonSource: "../images/connect.png"
                onFieldTextChanged: globalSettings.serverPassword=fieldText
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
                bottomInset: column.spacing
                onVisibleChanged: visible ? timeres.start() : {}
                Timer { id: timeres; interval: 3000; running: false; repeat: false; onTriggered: errorText.visible=false}
            }
            My.ComboBoxWithButton {
                id: mcbwb
                labelText: qsTr("Entry sound")+mytrans.emptyString
                model: ["mute","sound1", "sound2", "sound3", "sound4", "sound5"]
                labelWidth: column.maxLabWidth
                fontsize: fontSize
                buttonSource: "../images/sound.png"
                box.onCurrentValueChanged: globalSettings.soundSource=box.currentText
                box.currentIndex: Number(globalSettings.soundSource[5])
                onButtonClicked: {
                    playSound.source="../sounds/"+box.currentText+".wav"
                    playSound.play()
                }
                SoundEffect {
                    id: playSound
                    volume: 1
                    source: "../sounds/sound1.wav"
                }
            }
            My.NextButton {
                text: qsTr("Change role")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                topline: true
                mousearea.onClicked: {
                    mainwindow.changeRole()
                }
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
                errorText.text=qsTr("Wrong server password")+mytrans.emptyString;
                errorText.visible=true;
            }
            else if (response=="ping")
                mtf6.buttonColor("limegreen")
            else
            {
                errorText.text=qsTr("Network error")+mytrans.emptyString;
                errorText.visible=true;
            }
        }
        onErrorFounded: {
            errorText.text=error;
            popupConnection.close()
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
                errorText.text=qsTr("Connection timed out")+mytrans.emptyString;
            }
        }
    }
}
