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

    property bool hasphoto: false
    property int id: 0
    onHasphotoChanged:{
        console.log("hasphoto====="+page.hasphoto)
        //newphoto.rotat=0
        if (page.hasphoto)
        {
            console.log("serverImgProvider")
            photopreview="image://serverImgProvider/"+id++;
            newphoto.source= "image://serverImgProvider/"+id++;
            photosave=""
        }
        else
        {
            newphoto.source="../images/new_photo.png"
            photopreview=""
            photosave=""
        }
    }

    function setphotosource(src){
        if (src!=="")
        {
            //newphoto.source="none"
            newphoto.source=src
            //newphoto.update()
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
                //addToDatabase()
                createNewProfileDialog.open()
            }
            else
                //addToDatabase()
                createNewProfileDialog.open()
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
        if (photosave!="")
        {
            imgSend.sendImage(qrcode, photosave, newphoto.rotat)
            //photopreview=""
            oldphotosave=photosave
            photosave=""
        }
        else if (photopreview=="" && page.editMember!="")
            removephotoclient.sendGet(page.editMember, "delete photo")
        newphoto.rotat=0

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
                Rectangle {
                    id: photorect
                    color: "transparent"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(page.width,page.height)*(photopreview==""? 0.25: 0.8)
                    height: width
                    Image {
                        id: newphoto
                        property int rotat: 0
                        cache: false
                        anchors.fill: parent
                        source: "../images/new_photo.png"
                        sourceSize.height: width
                        sourceSize.width: width
                        fillMode: Image.PreserveAspectCrop
                        rotation: rotat*90
                        MouseArea {
                            id: newphotoma
                            enabled: photopreview==""
                            anchors.fill: parent
                            onClicked: stackView.push("ProfileCameraPage.qml")
                        }
                        Rectangle {
                            visible: photosave!=""
                            anchors.fill: parent
                            color: "transparent"
                            border.color: "#dbdbdb"
                            border.width: 3
                        }
                    }

                    Rectangle {
                        id: underimgrect
                        width: newphoto.width
                        height: newphoto.height/7
                        visible: photopreview!==""
                        color: "white"
                        opacity: 0.6
                        border.color: "#cccccc"
                        border.width: 3
                        anchors.bottom: photorect.bottom
                        Rectangle {
                            id: closephotobut
                            width: photosave!=="" ? parent.width/2 : parent.width
                            height: parent.height
                            anchors.left: parent.left
                            color: "pink"
                            Image{
                                anchors.centerIn: parent
                                height: parent.height*0.7
                                width: height
                                sourceSize.width: height
                                sourceSize.height: height
                                source: "../images/delete.png"
                            }
                            MouseArea {
                                anchors.fill:parent
                                onClicked: {
                                    newphoto.rotat=0
                                    console.log("STATUS="+page.hasphoto)
                                    if (page.hasphoto)
                                    {
                                        page.hasphoto=false
                                        console.log("HAS PHOTO NOW False")
                                    }
                                    else
                                    {
                                        newphoto.source="../images/new_photo.png"
                                        photopreview=""
                                        photosave=""
                                    }
                                }
                            }
                        }
                        Rectangle {
                            id: rotatephotobut
                            visible: photosave!==""
                            width: parent.width/2
                            height: parent.height
                            anchors.right: parent.right
                            Image{
                                anchors.centerIn: parent
                                height: parent.height*0.7
                                width: height
                                sourceSize.width: height
                                sourceSize.height: height
                                source: "../images/rotate.png"
                            }
                            MouseArea {
                                anchors.fill:parent
                                enabled: photosave!==""
                                onClicked: {
                                    newphoto.rotat++
                                }
                            }
                        }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#dddddd"
                            visible: photosave!==""
                            height: parent.height
                            width: 3
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

    MyClient {
        id: removephotoclient
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
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
                {
                    successanimation.play()
                    mtf1.fieldText=""
                    mtf2.fieldText=""
                    mtf3.fieldText=""

                    qrgenerator.request = "select qrcode from members where qrcode='"+makeid()+"'"
                    qrgenerator.update()
                    photosave=""
                    photopreview=""
                    newphoto.source="../images/new_photo.png"
                }//queryExecutedDialog.open();
                else
                    operationSuccessfullyCompletedDialog.open();
            }
            else
                queryNotExecutedDialog.open();
        }
        onErrorFounded: connectionErrorDialog.open();
    }
    Dialog {
        id: createNewProfileDialog
        title: qsTr("Warning")+mytrans.emptyString
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Create/change a member?")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
        onAccepted: addToDatabase()
    }

    //    Dialog {
    //        id: queryExecutedDialog
    //        title: qsTr("Info")+mytrans.emptyString
    //        standardButtons: Dialog.No | Dialog.Yes
    //        anchors.centerIn: parent
    //        font.pixelSize: fontSize
    //        Label {
    //            text: qsTr("Member <b>successfully</b> created")+(page.nogroups? qsTr(" <b>without any group access</b>"):"")+qsTr(". Do you want to <b>edit</b> created member?")+mytrans.emptyString
    //            anchors.fill: parent
    //            font.pixelSize: fontSize
    //            wrapMode: Text.WordWrap
    //        }
    //        onAccepted: {
    //            page.editMember=page.memberqr;
    //            photosave=""
    //            //imgSend.deleteImg(oldphotosave)
    //        }
    //        onRejected: {
    //            console.log("Updating qrcode")
    //            qrgenerator.request = "select qrcode from members where qrcode='"+makeid()+"'"
    //            qrgenerator.update()
    //            photosave=""
    //            photopreview=""
    //            newphoto.source="../images/new_photo.png"
    //            //imgSend.deleteImg(oldphotosave)
    //        }
    //    }
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
            //newphoto.update()
            photosave=""
            photopreview=""
            //newphoto.source="../images/new_photo.png"
            //stackView.push("DBAddMemberPage.qml");
            stackView.pop();
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
        onAccepted: {
            sqlhandler.sendGetQuery("delete from members where qrcode='"+page.editMember+"'")
            if (photopreview!=="")
                removephotoclient.sendGet(page.editMember, "delete photo")
        }
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
