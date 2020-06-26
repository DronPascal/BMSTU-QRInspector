import QtQuick 2.12
import QtQuick.Controls 2.12
import MyExtentions 1.0

import "./qml/myTemplates" as My

Page {
    title: "Superuser menu"
    id: page
    visible: true
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            stackView.pop();
            event.accepted = true;
        }
    }
    property string curDBName: ""

    My.SettingsHeader {
        id: msh
        headertext: qsTr("Superuser menu")+mytrans.emptyString
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
        contentHeight: 15*mtf1.height+mysqlview.height
        clip: true
        Pane {
            anchors.fill: parent
            focusPolicy: Qt.ClickFocus
        }
        Column {
            id: column
            anchors.fill: parent
            topPadding: 10

            My.TextFieldWithButton {
                id: mtf1
                labelText: qsTr("Password")+mytrans.emptyString
                placeholderText: globalSettings.sudoPassword===""? qsTr("sudo password")+mytrans.emptyString :"*****"
                fontsize: fontSize
                selectByMouse: true
                buttonSource: "../images/connect.png"
                onTextFieldChanged: globalSettings.sudoPassword=fieldText
                onButtonClicked: dbnameclient.sendGet("rootpassword/"+globalSettings.sudoPassword, "get name")
            }
            Rectangle{
                height: page.height/50
                width: 1
                color: "transparent"
            }
            Label {
                id: curdbname
                font.pixelSize: fontSize
                text: ""
                width: parent.width
                leftPadding: 10
                visible: text!=""
            }

            My.NextButton {
                id: wipebut
                text: qsTr("Wipe database")+mytrans.emptyString
                topline: true
                visible: curdbname.text!==""
                imageSource: "../images/forward.png"
                fontsize: fontSize
                mousearea.onClicked: curdbname!=="" ? resetDatabaseDialog.open() : {}
            }
            My.NextButton {
                text: qsTr("Change database")+mytrans.emptyString
                visible: curdbname.text!==""
                imageSource: "../images/forward.png"
                fontsize: fontSize
                mousearea.onClicked: setDatabaseDialog.open()
            }
            My.MenuSwitch {
                id: dbswitch
                text: qsTr("Block new visits processing")+mytrans.emptyString
                visible: curdbname.text!==""
                fontsize: fontSize
                mousearea.onClicked: myswitch.checked=!myswitch.checked

                myswitch.onCheckedChanged: {
                    if (myswitch.checked)
                        dbstatusclient.sendGet("rootpassword/"+globalSettings.sudoPassword, "set dbstatus=1")
                    else
                        dbstatusclient.sendGet("rootpassword/"+globalSettings.sudoPassword, "set dbstatus=0")
                }
            }
            My.TextFieldWithButton {
                id: newquery
                visible: curdbname.text!==""
                labelText: "Query"+mytrans.emptyString
                buttonSource: "../images/run.png"
                fontsize: fontSize
                height: wipebut.height
                textfield.onFocusChanged: textfield.focus ? queryInputDialog.open() :{}
                onButtonClicked: {
                    mysqlview.request=fieldText
                    mysqlview.update()
                }
            }
            Rectangle {
                id: tablerect
                width: page.width-20
                anchors.horizontalCenter: parent.horizontalCenter
                height: Math.max(page.height,page.width)/2
                border.color: "gray"
                visible: mysqlview.model.count!=0
                My.SQLTableView {
                    id:mysqlview
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    height: parent.height-1
                    width: parent.width-1

                    fontsize: fontSize

                    ip: globalSettings.serverIP
                    port: globalSettings.serverPort
                    password: globalSettings.serverPassword
                    dbpassword: globalSettings.dbPassword

                    onSqlErrorFounded: {
                        sqleta.text=sqlerror.replace("ERROR: ", "")
                        sqlErrorDialog.open()
                    }
                }
            }
        }
    }
    Dialog {
        id: setDatabaseDialog
        title: qsTr("Input")+mytrans.emptyString
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            TextArea {
                id: sta
                font.pixelSize: fontSize
                wrapMode: Text.WordWrap
                text: qsTr("Enter database name to select")+mytrans.emptyString
                anchors.horizontalCenter: parent.horizontalCenter
            }
            TextField {
                id: dbtoselect
                width: parent.width*0.9
                font.pixelSize: fontSize
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        onAccepted: {
            if (dbtoselect.text!=="" && dbtowipe.text!==page.curDBName)
                sudoclient.sendGet("rootpassword/"+globalSettings.sudoPassword, "set dbname="+dbtoselect.text)
        }
    }
    Dialog {
        id: resetDatabaseDialog
        title: qsTr("Warning")+mytrans.emptyString
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                text: qsTr("This action will delete ALL information in the current database!")+mytrans.emptyString
                color: "red"
                width: parent ? parent.width : 100
                font.pixelSize: fontSize
                wrapMode: Text.WordWrap
                anchors.horizontalCenter: parent.horizontalCenter
            }
            TextArea {
                id: ta
                font.pixelSize: fontSize
                wrapMode: Text.WordWrap
                text: qsTr("Enter database name to wipe.")+mytrans.emptyString
                anchors.horizontalCenter: parent.horizontalCenter
            }
            TextField {
                id: dbtowipe
                width: parent.width*0.9
                font.pixelSize: fontSize
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        onAccepted: {
            if (dbtowipe.text!=="" && dbtowipe.text===page.curDBName)
                sudoclient.sendGet("rootpassword/"+globalSettings.sudoPassword, "wipe table")
        }
    }
    Dialog {
        id: wrongSudoPasswordDialog
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        TextArea {
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
            text: qsTr("Wrong sudo password.")+mytrans.emptyString
        }
        onClosed: mtf1.activeFocus()
    }
    Dialog {
        id: operationSuccessfullyCompletedDialog
        title: qsTr("Info")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        TextArea {
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
            text: qsTr("Operation completed successfully.")+mytrans.emptyString
        }
    }
    Dialog {
        id: queryNotExecutedDialog
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        TextArea {
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
            text: qsTr("Database error!")+mytrans.emptyString
        }
    }
    Dialog {
        id: queryInputDialog
        title: qsTr("Input")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        width: parent.width*0.8
        height: parent.height*0.7
        font.pixelSize: fontSize
        Flickable {
            id: flickable
            flickableDirection: Flickable.VerticalFlick
            anchors.fill: parent
            contentHeight: queryte.implicitHeight
            TextArea.flickable: TextArea {
                id: queryte

                placeholderText: "query..."
                font.pixelSize: fontSize-2
                width: 100
                height: 100
                wrapMode: Text.Wrap
                selectByMouse: true
                background: Rectangle {
                    anchors.fill: parent
                    border.color: "#eeeeee"
                }
            }
            ScrollBar.vertical: ScrollBar { }
        }
        onAccepted:{
            newquery.fieldText=queryte.text.replace("\n"," ")
            newquery.forceActiveFocus()
        }
        onClosed: {
            newquery.fieldText=queryte.text.replace("\n"," ")
            newquery.forceActiveFocus()
        }
    }
    Dialog {
        id: sqlErrorDialog
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        TextArea {
            id: sqleta
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
            text: ""
        }
    }
    MyClient {
        id: sudoclient
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        onGetServerResponse:{
            if (response == "accessdenied")
                wrongSudoPasswordDialog.open()
            else if (response == "request executed")
            {
                operationSuccessfullyCompletedDialog.open()
                dbnameclient.sendGet("rootpassword/"+globalSettings.sudoPassword, "get name")
            }
            else
                queryNotExecutedDialog.open()
        }
    }
    MyClient {
        id: dbnameclient
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        onGetServerResponse: {
            if (response === "accessdenied")
            {
                mtf1.buttonColor("red")
                curdbname.text=""
            }
            else
            {
                mtf1.buttonColor("green")
                curdbname.text="<b>"+qsTr("Current db name")+mytrans.emptyString+": </b>"+response
                page.curDBName=response
            }
        }
        Component.onCompleted: sendGet("rootpassword/"+globalSettings.sudoPassword, "get name")
    }
    MyClient {
        id: dbstatusclient
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        onGetServerResponse: {
            if (response === "1")
                dbswitch.myswitch.checked=true
            else if (response === "0")
                dbswitch.myswitch.checked=false
        }
        Component.onCompleted: sendGet("rootpassword/"+globalSettings.sudoPassword, "get dbstatus")
    }
}
