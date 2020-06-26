import QtQuick 2.12
import QtQuick.Controls 2.12
import MyExtentions 1.0

import "./qml/myTemplates" as My

Page {
    title: "Database Settings"
    id: page
    visible: true
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            stackView.pop();
            event.accepted = true;
        }
    }

    My.SettingsHeader {
        id: msh
        headertext: qsTr("Database Settings")+mytrans.emptyString
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
        contentHeight: 15*mtf1.height
        clip: true
        Pane {
            anchors.fill: parent
            focusPolicy: Qt.ClickFocus
        }
        Column {
            id: column
            anchors.fill: parent
            topPadding: 10
            My.TextField {
                id: mtf1
                labelText: qsTr("Password")+mytrans.emptyString
                //fieldText: globalSettings.dbPassword
                placeholderText: globalSettings.dbPassword!=="" ? "*****" : qsTr("db password")+mytrans.emptyString
                fontsize: fontSize
                onTextFieldChanged: globalSettings.dbPassword=fieldText
            }
            Rectangle{
                height: page.height/50
                width: 1
                color: "transparent"
            }
            Text {
                id: lbl1
                width: parent.width
                fontSizeMode: Text.Fit
                text: qsTr("Add")+mytrans.emptyString
                color: "mediumseagreen"
                font.pixelSize: fontSize+3
                leftPadding: 10
                font.weight: Font.ExtraBold
                horizontalAlignment: Text.AlignLeft
                anchors.horizontalCenter: parent.horizontalCenter
            }
            My.NextButton {
                text: qsTr(" Member")+mytrans.emptyString
                topline: true
                imageSource: "../images/forward.png"
                fontsize: fontSize
                mousearea.onClicked: checkdbAndPush("DBAddMemberPage.qml");
            }
            My.NextButton {
                text: qsTr(" Group")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                mousearea.onClicked: checkdbAndPush("DBAddGroupPage.qml");
            }
            My.NextButton {
                text: qsTr(" Event")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                mousearea.onClicked: checkdbAndPush("DBAddEventPage.qml");
            }
            Text {
                id: lbl2
                width: parent.width
                height: mtf1.height
                fontSizeMode: Text.Fit
                text: qsTr("View and Edit")+mytrans.emptyString
                color: "goldenrod"
                font.pixelSize: fontSize+3
                leftPadding: 10
                font.weight: Font.ExtraBold
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
            My.NextButton {
                text: qsTr(" Members table")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                topline: true
                mousearea.onClicked: checkdbAndPush("DBTableMembersPage.qml");
            }
            My.NextButton {
                text: qsTr(" Groups table")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                mousearea.onClicked: checkdbAndPush("DBTableGroupsPage.qml");
            }
            My.NextButton {
                text: qsTr(" Events table")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                mousearea.onClicked: checkdbAndPush("DBTableEventsPage.qml");
            }
            Text {
                id: lbl3
                width: parent.width
                height: mtf1.height
                fontSizeMode: Text.Fit
                text: qsTr("Statistics")+mytrans.emptyString
                color: "dodgerblue"
                font.pixelSize: fontSize+3
                leftPadding: 10
                font.weight: Font.ExtraBold
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
            My.NextButton {
                text: qsTr(" Visits table")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                topline: true
                mousearea.onClicked: checkdbAndPush("DBTableVisitsPage.qml");
            }
            Text {
                id: lbl4
                width: parent.width
                height: mtf1.height
                fontSizeMode: Text.Fit
                text: "Sudo"
                color: "darkred"
                font.pixelSize: fontSize+3
                leftPadding: 10
                font.weight: Font.ExtraBold
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
            My.NextButton {
                text: qsTr(" Superuser menu")+mytrans.emptyString
                imageSource: "../images/forward.png"
                fontsize: fontSize
                topline: true
                mousearea.onClicked: checkdbAndPush("DBSudoSettingsPage.qml");
            }
        }
    }


    MySQLiteHandler {
        id: sqlPing
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        dbpassword: globalSettings.dbPassword
        onModelChanged: {
            if (data=="ERROR: Wrong DB Password")
                dbWrongPassword.open()
            else
                stackView.push(goToPage)
        }
        onErrorFounded: serverConnectionErrorDialog.open()

    }
    Dialog {
        id: serverConnectionErrorDialog
        title: qsTr("Info")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        TextArea {
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
            text: qsTr("Can't connect to server! Try  again later.")+mytrans.emptyString
        }
    }
    Dialog {
        id: dbPasswordIsEmptyDialog
        title: qsTr("Info")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        TextArea {
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
            text: qsTr("Database password field is empty!")+mytrans.emptyString
        }
        onClosed: mtf1.activeFocus()
    }
    Dialog {
        id: dbWrongPassword
        title: qsTr("Info")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        TextArea {
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
            text: qsTr("Database password is wrong!")+mytrans.emptyString
        }
        onClosed: mtf1.activeFocus()
    }

    property string goToPage: ""
    function checkdbAndPush(page){
        goToPage=page;
        if (mtf1.placeholderText=="db password")
            dbPasswordIsEmptyDialog.open()
        else
            sqlPing.sendGetQuery("select null")
    }
}


