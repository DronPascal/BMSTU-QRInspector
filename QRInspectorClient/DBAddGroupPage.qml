import QtQuick 2.12
import QtQuick.Controls 2.12

import MyExtentions 1.0
import "./qml/myTemplates" as My
import "../DBProfilesOpener.js" as Open

Page {
    title: "Add/Edit Group Page"
    id: page
    visible: true
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            stackView.pop();
            event.accepted = true;
        }
    }
    property alias editGroup: page.editGroup
    property string editGroup: ""

    function update(){
        mcvevents.update();
        mcvmembers.update();
    }

    My.SettingsHeader {
        id: msh
        headertext: page.editGroup=="" ? qsTr("Add Group")+mytrans.emptyString:qsTr("Edit Group")+mytrans.emptyString
        fontsize: fontSize
        backSource: "../images/close_black.png"
        onBackClicked: stackView.pop();
        acceptSource: page.editGroup=="" ? "../images/accept_black.png":"../images/save.png"
        onAcceptClicked: saveGroup()
    }

    function saveGroup() {
        if (mtf1.fieldText!="")
            if (mcvevents.elementmodel.count===0 && mcvmembers.elementmodel.count===0)
                groupsNotSelectedDialog.open()
            else
                addToDatabase()
    }

    function addToDatabase() {
        var query="";
        var group;
        if (page.editGroup=="")
        {
            group = mtf1.fieldText;
            if (mtf1.fieldText!=="")//date
                query+="INSERT INTO groupnames (name) VALUES ('"+mtf1.fieldText+"')";
        }
        else
        {
            group=page.editGroup
            query+="UPDATE groupnames SET name='"+mtf1.fieldText+"' WHERE name='"+page.editGroup+"'"
            query+=";"+"DELETE FROM groups WHERE groupid=(SELECT groupid FROM groupnames WHERE name='"+page.editGroup+"')"
            query+=";"+"DELETE FROM invites WHERE groupid=(SELECT groupid FROM groupnames WHERE name='"+page.editGroup+"')"
        }
        if (mcvmembers.elementmodel.count!=0)
            for (var i=0; i<mcvmembers.elementmodel.count; i++)
            {
                var memberid = mcvmembers.elementmodel.get(i)["text"]
                memberid = memberid.substring(memberid.indexOf("(")+3, memberid.indexOf(")"))
                query+=";"+"INSERT INTO groups (groupid, memberid) VALUES ((SELECT groupid FROM groupnames WHERE name='"+group+"'), "+memberid+")"
            }
        if (mcvevents.elementmodel.count!==0)
            for (i=0; i<mcvevents.elementmodel.count; i++)
            {
                var event = mcvevents.elementmodel.get(i)["text"];
                query+=";"+"INSERT INTO invites (eventid, groupid) VALUES ((SELECT eventid FROM events WHERE name='"+event+"'), (SELECT groupid FROM groupnames WHERE name='"+group+"'))"
            }
        sqlhandler.sendGetQuery(query);
    }

    Rectangle {
        anchors {
            top: msh.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        Flickable {
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: mtf1.height*5+4*column.spacing+mcvmembers.elementsHeight+mcvevents.elementsHeight+parent.height/3
            clip: true
            Pane {
                anchors.fill: parent
                focusPolicy: Qt.ClickFocus
            }
            Column {
                id: column
                anchors.fill: parent
                spacing: page.height/50
                topPadding: 10
                My.TextField {
                    id: mtf1
                    labelWidth: mcvmembers.labelWidth
                    labelText: qsTr("Title")
                    fontsize: fontSize
                }
                My.GroupComboView {
                    id: mcvmembers
                    labelText: qsTr("Member")+mytrans.emptyString
                    listText: qsTr("Group members:")+mytrans.emptyString
                    fontsize: fontSize

                    expandSource: "../images/expand.png"
                    plusSource: "../images/plus_green.png"

                    ip: globalSettings.serverIP
                    port: globalSettings.serverPort
                    password: globalSettings.serverPassword
                    dbpassword: globalSettings.dbPassword
                    request: "select name || ' ' || surname || ' ' || patronymic ||' (id' || memberid || ')' AS fullname from members"
                    allowNew: false
                    elementScaling: Math.floor((parent.width-20)/fontSize)

                    onElementClicked: {
                        var memberid = elementtext.substring(elementtext.indexOf("(")+3, elementtext.indexOf(")"));
                        Open.memberProfile(page, { "profileid": memberid,
                                               "ip": globalSettings.serverIP,
                                               "port": globalSettings.serverPort,
                                               "password": globalSettings.serverPassword,
                                               "dbpassword": globalSettings.dbPassword})
                    }
                }
                My.GroupComboView {
                    id: mcvevents
                    labelWidth: mcvmembers.labelWidth
                    labelText: qsTr("Event")+mytrans.emptyString
                    listText: qsTr("Group events:")+mytrans.emptyString
                    fontsize: fontSize

                    expandSource: "../images/expand.png"
                    plusSource: "../images/plus_green.png"

                    ip: globalSettings.serverIP
                    port: globalSettings.serverPort
                    password: globalSettings.serverPassword
                    dbpassword: globalSettings.dbPassword
                    request: "select name from events"
                    allowNew: false
                    elementScaling: Math.floor((parent.width-20)/2/fontSize)

                    onElementClicked: Open.eventProfile(page, { "profileid": elementtext,
                                                            "ip": globalSettings.serverIP,
                                                            "port": globalSettings.serverPort,
                                                            "password": globalSettings.serverPassword,
                                                            "dbpassword": globalSettings.dbPassword})
                }
                Button {
                    id: removebutton
                    text: qsTr("Delete group")+mytrans.emptyString
                    font.pixelSize: fontSize
                    font.bold: true
                    visible: page.editGroup!==""
                    background: Rectangle {
                        color: "indianred"
                        radius: height/6
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: deleteDialog.open()

                }
            }
        }
    }
    MySQLiteHandler {
        id: sqlhandler
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        dbpassword: globalSettings.dbPassword
        onModelChanged: {
            console.log(data);
            if (data==="request executed")
            {
                if (page.editGroup=="")
                    queryExecutedDialog.open();
                else
                    operationSuccessfullyCompletedDialog.open();
            }
            else
                queryNotExecutedDialog.open();
        }
        onErrorFounded: connectionErrorDialog.open();
    }
    Dialog {
        id: queryExecutedDialog
        title: qsTr("Info")+mytrans.emptyString
        standardButtons: Dialog.No | Dialog.Yes
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Group <b>successfully</b> created. Do you want to <b>edit</b> created group?")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
        onAccepted: {
            page.editGroup=mtf1.fieldText;
        }
    }

    Dialog {
        id: queryNotExecutedDialog
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Database <b>error</b>! Group was not added.")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
    }
    Dialog {
        id: connectionErrorDialog
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Network connection <b>error</b>! Member was not added.")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
    }
    Dialog {
        id: groupsNotSelectedDialog
        title: qsTr("Warning")+mytrans.emptyString
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("No members and events added. The group will be created without members and access to events.")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
        onAccepted: addToDatabase()
    }
    Dialog {
        id: uncorrectFieldFoundedDialod
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("The field is empty or incorrect data is entered. Сheck the input is correct!")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
    }

    Dialog {
        id: deleteDialog
        title: qsTr("Warning")+mytrans.emptyString
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Deleting a (")+page.editGroup+qsTr(") group will delete all found related data!")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
        onAccepted: sqlhandler.sendGetQuery("delete from groupnames where name='"+page.editGroup+"'")
    }
    Dialog {
        id: operationSuccessfullyCompletedDialog
        title: qsTr("Info")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Operation completed <b>successfully</b>.")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
        onClosed: {
            stackView.pop();
            stackView.push("DBAddGroupPage.qml");
        }
    }

    MySQLiteHandler {
        id: sqlhandlerEdit
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        dbpassword: globalSettings.dbPassword
        onModelChanged: uploadToForm(data);
        Component.onCompleted: {
            if (page.editGroup!="")
                sendGetQuery("SELECT * FROM groupnames LEFT JOIN (SELECT group_concat(name,', ') as eventnames FROM (SELECT name FROM events e LEFT JOIN invites i ON e.eventid=i.eventid WHERE groupid=(SELECT groupid FROM groupnames WHERE name='"+page.editGroup+"'))) LEFT JOIN (SELECT group_concat(name||' '||surname||' '||patronymic||' (id'||memberid||')',', ') as membernames FROM (SELECT * FROM members m LEFT JOIN groups g ON m.memberid=g.memberid WHERE groupid=(SELECT groupid FROM groupnames WHERE name='"+page.editGroup+"'))) WHERE groupid=(SELECT groupid FROM groupnames WHERE name='"+page.editGroup+"')");
        }
        function uploadToForm(data)
        {
            var dataList = data.split("|||");
            var fields = dataList[1].split("|");
            mtf1.fieldText=fields[1];

            var events=fields[2].split(", ");
            if (fields[2]!==" ")
                for (var j=0; j<events.length ; j++)
                    mcvevents.elementmodel.append({ "text" : events[j], "color": randomColor(), "unknown": false})
            var members=fields[3].split(", ");
            if (fields[3]!==" ")
                for (j=0; j<members.length ; j++)
                    mcvmembers.elementmodel.append({ "text" : members[j], "color": randomColor(), "unknown": false})
        }
        function randomColor(){
            var r=Math.floor(Math.random() * (150)+106);
            var g=Math.floor(Math.random() * (150)+106);
            var b=Math.floor(Math.random() * (150)+106);
            var c='#' + r.toString(16) + g.toString(16) + b.toString(16);
            console.log(c);
            return c;
        }
    }
}
