import QtQuick 2.12
import QtQuick.Controls 2.12

import MyExtentions 1.0
import "./qml/myTemplates" as My
import "../DBProfilesOpener.js" as Open

Page {
    title: "Add/Edit Member Page"
    id: page
    visible: true
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            stackView.pop();
            event.accepted = true;
        }
    }
    property string memberqr: ""
    property alias editMember: page.editMember
    property string editMember: ""
    property bool nogroups: false
    property string oldphotosave: ""

    function setphotosource(src){
        if (src!=="")
        {
            newphoto.source=src
            previewph.text=src
        }
    }

    function update(){
        mcvevents.update();
        mcvgroups.update();
    }
    My.SettingsHeader {
        id: msh
        headertext: page.editMember=="" ?qsTr( "Add Member")+mytrans.emptyString:qsTr("Edit Member")+mytrans.emptyString
        fontsize: fontSize
        backSource: "../images/close_black.png"
        onBackClicked: stackView.pop();
        acceptSource: page.editMember=="" ? "../images/accept_black.png":"../images/save.png"
        onAcceptClicked: saveMember()
    }

    function saveMember() {
        if (mtf1.fieldText!=="" && mtf2.fieldText!=="")
        {
            if (mcvevents.elementmodel.count===0 && mcvgroups.elementmodel.count===0)
            {
                if (mcvevents.searchmodel.model.count!=0 || mcvgroups.searchmodel.model.count!=0 )
                    page.nogroups=false
                else
                    page.nogroups=true
                addToDatabase()
            }
            else
                addToDatabase()
        }
        else {
            nameNotSelectedDialog.open()
        }
    }

    function addToDatabase()
    {
        var query="";
        var qrcode;
        if (page.editMember=="")
        {
            qrcode = page.memberqr;
            if (mtf1.fieldText!=="" && mtf2.fieldText!=="")
                query+="INSERT INTO members (name, surname, patronymic, qrcode) VALUES ('"+mtf1.fieldText+"', '"+mtf2.fieldText+"', '"+mtf3.fieldText+"', '"+page.memberqr+"')";
        }
        else
        {
            qrcode=page.editMember
            query+="UPDATE members SET name='"+mtf1.fieldText+"', surname='"+mtf2.fieldText+"', patronymic='"+mtf3.fieldText+"' WHERE qrcode='"+page.editMember+"'"
            query+=";"+"DELETE FROM groups WHERE memberid=(SELECT memberid FROM members WHERE qrcode='"+page.editMember+"')"
            query+=";"+"DELETE FROM invites WHERE memberid=(SELECT memberid FROM members WHERE qrcode='"+page.editMember+"')"
        }
        if (mcvgroups.elementmodel.count!=0)
            for (var i=0; i<mcvgroups.elementmodel.count; i++)
            {
                var group =mcvgroups.elementmodel.get(i)["text"];
                query+=";"+"INSERT INTO groups (groupid, memberid) VALUES ((SELECT groupid FROM groupnames WHERE name='"+group+"'), (SELECT memberid FROM members WHERE qrcode='"+qrcode+"'))"
            }
        if (mcvevents.elementmodel.count!==0)
            for (i=0; i<mcvevents.elementmodel.count; i++)
            {
                var event = mcvevents.elementmodel.get(i)["text"];
                query+=";"+"INSERT INTO invites (eventid, memberid) VALUES ((SELECT eventid FROM events WHERE name='"+event+"'), (SELECT memberid FROM members WHERE qrcode='"+qrcode+"'))"
            }

        sqlhandler.sendGetQuery(query);
        if (newphoto.source!=="../images/new_photo.png")
        {
            imgSend.sendImage(qrcode, photosave)
            photopreview=""
            oldphotosave=photosave
            photosave=""
        }
        //        imgSend.sendImage(page.editMember!=""?page.editMember:page.memberqr,
        //                          (men.border.width==0 && women.border.width==0) ? "" : (men.border.width!=0?":/images/men.png": ":/images/women.png") )
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
            contentHeight: msh.height*9+newphoto.height+6*column.spacing+mcvgroups.elementsHeight+mcvevents.elementsHeight
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
                    labelText: qsTr("Name*")+mytrans.emptyString
                    fontsize: fontSize
                    labelWidth: mtf3.labelWidth
                }
                My.TextField {
                    id: mtf2
                    width: parent.width
                    labelText: qsTr("Surname*")+mytrans.emptyString
                    fontsize: fontSize
                    labelWidth: mtf3.labelWidth
                }
                My.TextField {
                    id: mtf3
                    labelText: qsTr("Patronymic")+mytrans.emptyString
                    fontsize: fontSize
                }
                My.GroupComboView {
                    id: mcvgroups
                    labelText: qsTr("Group")+mytrans.emptyString
                    listText: qsTr("Member groups:")+mytrans.emptyString
                    fontsize: fontSize
                    labelWidth: mtf3.labelWidth

                    expandSource: "../images/expand.png"
                    plusSource: "../images/plus_green.png"

                    ip: globalSettings.serverIP
                    port: globalSettings.serverPort
                    password: globalSettings.serverPassword
                    dbpassword: globalSettings.dbPassword
                    request: "select name from groupnames"

                    onElementClicked: {
                        var founded=false
                        for (var i =0; i<mcvgroups.searchmodel.model.count ; i++)
                            if (mcvgroups.searchmodel.model.get(i)["text"]===elementtext)
                            {
                                founded=true;
                            }
                        if (founded)
                            Open.groupProfile(page, { "profileid": elementtext,
                                                  "ip": globalSettings.serverIP,
                                                  "port": globalSettings.serverPort,
                                                  "password": globalSettings.serverPassword,
                                                  "dbpassword": globalSettings.dbPassword})
                    }
                }
                My.GroupComboView {
                    id: mcvevents
                    labelWidth: mtf3.labelWidth
                    labelText: qsTr("Event")+mytrans.emptyString
                    listText: qsTr("Member events:")+mytrans.emptyString
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

                Label {
                    id: avatarlabel
                    text: qsTr("Avatar:")+mytrans.emptyString
                    font.pixelSize: fontSize
                    leftPadding: 10
                }

                //                Row {
                //                    id: avatarRow
                //                    property int length: Math.min(parent.width,parent.height)
                //                    width: parent.width
                //                    spacing: parent.width/10
                //                    leftPadding: (parent.width-2*length/3-width/10)/2
                //                    Rectangle {
                //                        id: men
                //                        width: avatarRow.length/3
                //                        height: width
                //                        color: "transparent"
                //                        border.width: 0
                //                        radius: width/5
                //                        Image {
                //                            source: "../images/men.png"
                //                            anchors.fill: parent
                //                            sourceSize.height: width
                //                            sourceSize.width: width
                //                        }
                //                        MouseArea {
                //                            anchors.fill: parent
                //                            onClicked: {parent.border.width=5; women.border.width=0}
                //                        }
                //                    }
                //                    Rectangle {
                //                        id: women
                //                        width: avatarRow.length/3
                //                        height: width
                //                        color: "transparent"
                //                        border.width: 0
                //                        radius: width/5
                //                        Image {
                //                            source: "../images/women.png"
                //                            anchors.fill: parent
                //                            sourceSize.height: width
                //                            sourceSize.width: width
                //                        }
                //                        MouseArea {
                //                            anchors.fill: parent
                //                            onClicked: {parent.border.width=5; men.border.width=0}
                //                        }
                //                    }
                //                }
                Image {
                    id: newphoto
                    source: "../images/new_photo.png"
                    width: Math.min(page.width,page.height)/4
                    height: width
                    sourceSize.height: width
                    sourceSize.width: width
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectCrop
                    MouseArea {
                        id: newphotoma
                        anchors.fill: parent
                        onClicked: stackView.push("ProfileCameraPage.qml")
                    }
                    onSourceChanged: photopreview=="" ? newphotoma.enabled=true : newphotoma.enabled=false
                    Image {
                        visible: photopreview!=""
                        id: closephoto
                        source: "../images/closephoto.png"
                        width: parent.width/8
                        height: width
                        sourceSize.height: width
                        sourceSize.width: width
                        anchors.top: parent.top
                        anchors.right: parent.right
                        MouseArea {
                            anchors.fill:parent
                            onClicked: {
                                photopreview=""
                                newphoto.source="../images/new_photo.png"
                            }
                        }
                    }
                }
                Button {
                    id: removebutton
                    text: qsTr("Delete member")+mytrans.emptyString
                    font.pixelSize: fontSize
                    font.bold: true
                    visible: page.editMember!==""
                    background: Rectangle {
                        color: "indianred"
                        radius: height/6
                        border.color: "firebrick"
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: deleteDialog.open()

                }
            }
        }
    }

    My.SQListModel {
        id: qrgenerator
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        dbpassword: globalSettings.dbPassword
        request: "select qrcode from members where qrcode='"+makeid()+"'"
        onModelReady: model.count==0 ? console.log("Free qr founded: "+page.memberqr) : request="select qrcode from members where qrcode='"+makeid()+"'";
    }
    function makeid() {
        var text = "";
        var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

        for (var i = 0; i < 16; i++)
            text += possible.charAt(Math.floor(Math.random() * possible.length));
        console.log(text);
        page.memberqr = text;
        return text;
    }

    MySQLiteHandler {
        id: sqlhandlerEdit
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        dbpassword: globalSettings.dbPassword
        onModelChanged: uploadToForm(data);
        Component.onCompleted: {
            if (page.editMember!="")
                sendGetQuery("SELECT * FROM members LEFT JOIN (SELECT group_concat(name,', ') as groupnames FROM (SELECT name FROM groupnames n LEFT JOIN groups g ON n.groupid=g.groupid WHERE memberid=(SELECT memberid FROM members WHERE qrcode='"+page.editMember+"'))) WHERE qrcode='"+page.editMember+"'");
        }
        function uploadToForm(data)
        {
            var dataList = data.split("|||");
            var fields = dataList[1].split("|");
            mtf1.fieldText=fields[1];
            mtf2.fieldText=fields[2];
            mtf3.fieldText=fields[3];
            var groups=fields[5].split(", ");
            if (fields[5]!==" ")
                for (var j=0; j<groups.length ; j++)
                {
                    console.log(groups[j])
                    mcvgroups.elementmodel.append({ "text" : groups[j], "color": randomColor(), "unknown": false});
                }
            var events=fields[6].split(", ");
            if (fields[6]!==" ")
                for (j=0; j<events.length ; j++)
                    mcvevents.elementmodel.append({ "text" : events[j], "color": randomColor(), "unknown": false})
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

    MyClient {
        id: imgSend
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
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
                if (page.editMember=="")
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
            text: qsTr("Member <b>successfully</b> created")+(page.nogroups? qsTr(" <b>without any group access</b>"):"")+qsTr(". Do you want to <b>edit</b> created member?")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
        onAccepted: {
            page.editMember=page.memberqr;
            newphoto.source="../images/new_photo.png"
            imgSend.deleteImg(oldphotosave)
        }
        onRejected: {
            console.log("Updating qrcode")
            qrgenerator.request = "select qrcode from members where qrcode='"+makeid()+"'"
            qrgenerator.update()
            newphoto.source="../images/new_photo.png"
            imgSend.deleteImg(oldphotosave)
        }
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
            newphoto.update()
            stackView.push("DBAddMemberPage.qml");
        }
    }
    Dialog {
        id: deleteDialog
        title: qsTr("Warning")+mytrans.emptyString
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Deleting a member will <b>delete all found related data</b>!")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
        onAccepted: sqlhandler.sendGetQuery("delete from members where qrcode='"+page.editMember+"'")
    }
    Dialog {
        id: nameNotSelectedDialog
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Enter member name and surname at least!")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
    }
    Dialog {
        id: queryNotExecutedDialog
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Database <b>error</b>! Member was not added.")+mytrans.emptyString
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
            text: qsTr("Network connection <b>error</b>! Member was not added/edited.")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
    }
}
