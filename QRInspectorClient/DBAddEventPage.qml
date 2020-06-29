import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4 as Old
import QtQuick.Controls.Styles 1.4

import MyExtentions 1.0
import "./qml/myTemplates" as My
import "../DBProfilesOpener.js" as Open

Page {
    title: "Add/Edit Event Page"
    id: page
    visible: true
    property var tempDate: new Date();
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            stackView.pop();
            event.accepted = true;
        }
    }
    property alias editEvent: page.editEvent
    property string editEvent: ""

    function update(){
        mcvgroups.update();
        mcvmembers.update();
    }

    My.SettingsHeader {
        id: msh
        headertext: page.editEvent=="" ? qsTr("Add Event")+mytrans.emptyString:qsTr("Edit Event")+mytrans.emptyString
        fontsize: fontSize
        backSource: "../images/close_black.png"
        onBackClicked: stackView.pop();
        acceptSource: page.editEvent=="" ? "../images/accept_black.png":"../images/save.png"
        onAcceptClicked: saveEvent()
    }

    function saveEvent() {
        if (mtf1.fieldText!="" && mtf5.fieldText!="")
            if (mtf2.fieldText.length==5 && mtf2.fieldText.indexOf(".")==2 && mtf3.fieldText.indexOf(".")==2)
            {
                var st = mtf2.fieldText.split(".");
                if (validTime(st[0], st[1]))
                {
                    var et = mtf3.fieldText.split(".");
                    if (validTime(et[0], et[1]))
                    {
                        var fd=new Date(); fd.setHours(st[0],st[1],0);
                        var ed=new Date(); ed.setHours(et[0],et[1],0);
                        if (fd<ed)
                        {
                            var curdate = new Date()
                            curdate.setHours(0,0,0)
                            var fielddate = Date.fromLocaleString(Qt.locale(), mtf4.fieldText, "dd.MM.yyyy")
                            fielddate.setHours(0,0,1)
                            if ((validDate(mtf4.fieldText) && (fielddate>curdate)) || dowb.mon || dowb.tue || dowb.wed || dowb.thu || dowb.fri || dowb.sat || dowb.sun)
                            {
                                if (mcvgroups.elementmodel.count==0 && mcvmembers.elementmodel.count==0)
                                    groupsNotSelectedDialog.open()
                                else
                                    //addToDatabase()
                                    createNewProfileDialog.open()
                                return;
                            }
                        }
                    }
                }
            }
        uncorrectFieldFoundedDialod.open();

    }

    function addToDatabase() {
        var query="";
        if (page.editEvent=="")
        {
            if (mtf4.fieldText!="")//date
                query+="INSERT INTO events (name, checkpoint, beginning, ending, date) VALUES ('"+mtf1.fieldText+"', '"+mtf5.fieldText+"', '"+mtf2.fieldText.replace(".",":")+"', '"+mtf3.fieldText.replace(".",":")+"', '"+mtf4.fieldText+"')";
            else//days of week
                query+="INSERT INTO events (name, checkpoint, beginning, ending, mon, tue, wed, thu, fri, sat, sun) VALUES ('"+mtf1.fieldText+"', '"+mtf5.fieldText+"', '"+mtf2.fieldText.replace(".",":")+"', '"+mtf3.fieldText.replace(".",":")+"', "+dowb.mon+", "+dowb.tue+", "+dowb.wed+", "+dowb.thu+", "+dowb.fri+", "+dowb.sat+", "+dowb.sun+")"
        }
        else
        {
            if (mtf4.fieldText!="")//date
                query+="UPDATE events SET name='"+mtf1.fieldText+"', checkpoint='"+mtf5.fieldText+"', beginning='"+mtf2.fieldText.replace(".",":")+"', ending='"+mtf3.fieldText.replace(".",":")+"', date='"+mtf4.fieldText+"', mon=NULL, tue=NULL , wed=NULL , thu=NULL , fri=NULL , sat=NULL , sun=NULL WHERE name='"+page.editEvent+"'"
            else//days of week
                query+="UPDATE events SET name='"+mtf1.fieldText+"', checkpoint='"+mtf5.fieldText+"', beginning='"+mtf2.fieldText.replace(".",":")+"', ending='"+mtf3.fieldText.replace(".",":")+"', date=NULL, mon="+dowb.mon+", tue="+dowb.tue+", wed="+dowb.wed+", thu="+dowb.thu+", fri="+dowb.fri+", sat="+dowb.sat+", sun="+dowb.sun+" WHERE name='"+page.editEvent+"'"

            query+=";"+"DELETE FROM invites WHERE eventid=(SELECT eventid FROM events WHERE name='"+mtf1.fieldText+"')"
        }
        if (mcvgroups.elementmodel.count!=0)
            for (var i=0; i<mcvgroups.elementmodel.count; i++)
            {
                var groupname = mcvgroups.elementmodel.get(i)["text"];
                query+=";"+"INSERT INTO invites (eventid, groupid) VALUES ((SELECT eventid FROM events WHERE name='"+mtf1.fieldText+"'), (SELECT groupid FROM groupnames WHERE name='"+groupname+"'))"
            }
        if (mcvmembers.elementmodel.count!=0)
            for (i=0; i<mcvmembers.elementmodel.count; i++)
            {
                var memberid = mcvmembers.elementmodel.get(i)["text"];
                memberid = memberid.substring(memberid.indexOf("(")+3, memberid.indexOf(")"))
                query+=";"+"INSERT INTO invites (eventid, memberid) VALUES ((SELECT eventid FROM events WHERE name='"+mtf1.fieldText+"'), "+memberid+")"
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
            contentHeight: 10*mtf1.height+9*column.spacing+mcvmembers.elementsHeight+mcvgroups.elementsHeight+parent.height/3
            clip: true
            onContentHeightChanged: console.log()
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
                    labelWidth: mtf5.labelWidth
                    labelText: qsTr("Title")+mytrans.emptyString
                    fontsize: fontSize
                }
                My.TextField {
                    id: mtf5
                    labelText: qsTr("Inspector ID")+mytrans.emptyString
                    fontsize: fontSize
                }
                My.TextField {
                    id: mtf2
                    labelWidth: mtf5.labelWidth
                    width: parent.width
                    labelText: qsTr("Start time")+mytrans.emptyString
                    fontsize: fontSize
                    placeholderText: "12.00"

                    inputMethodHints: Qt.ImhDigitsOnly
                }
                My.TextField {
                    id: mtf3
                    labelWidth: mtf5.labelWidth
                    labelText: qsTr("End time")+mytrans.emptyString
                    fontsize: fontSize
                    placeholderText: "13.30"
                    inputMethodHints: Qt.ImhDigitsOnly
                }
                My.TextFieldWithButton {
                    id: mtf4
                    labelWidth: mtf5.labelWidth
                    property int len: 0
                    labelText: qsTr("Date")+mytrans.emptyString
                    fontsize: fontSize
                    inputMethodHints: Qt.ImhDigitsOnly
                    placeholderText: Qt.formatDate(page.tempDate, "dd.MM.yyyy")
                    onTextFieldChanged:
                    {
                        if (len<fieldText.length)
                            dowb.clearAll()
                        len=fieldText.length;

                    }
                    buttonSource: "../images/calendar.png"
                    onButtonClicked: {
                        calpop.open();
                        if (fieldText!="")
                            calendar.selectedDate=Date.fromLocaleString(Qt.locale(), fieldText, "dd.MM.yyyy")
                    }
                }
                Popup {
                    id: calpop
                    width: Math.min(page.width, page.height)*0.8
                    height: width
                    x: (page.width-width)/2
                    y: (page.height-width)/2
                    padding: 0
                    Old.Calendar {
                        id: calendar
                        anchors.fill: parent
                        style: CalendarStyle  {
                            gridVisible: false
                            dayDelegate: Rectangle {
                                gradient: Gradient {
                                    GradientStop {
                                        position: 0.00
                                        color: styleData.selected ? "#111" : (styleData.visibleMonth && styleData.valid ? "#444" : "#666");
                                    }
                                    GradientStop {
                                        position: 1.00
                                        color: styleData.selected ? "#444" : (styleData.visibleMonth && styleData.valid ? "#111" : "#666");
                                    }
                                    GradientStop {
                                        position: 1.00
                                        color: styleData.selected ? "#777" : (styleData.visibleMonth && styleData.valid ? "#111" : "#666");
                                    }
                                }

                                Label {
                                    text: styleData.date.getDate()
                                    anchors.centerIn: parent
                                    color: styleData.valid ? "white" : "grey"
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: "#555"
                                    anchors.bottom: parent.bottom
                                }

                                Rectangle {
                                    width: 1
                                    height: parent.height
                                    color: "#555"
                                    anchors.right: parent.right
                                }
                            }
                        }

                        onClicked: {
                            var date = selectedDate;
                            var day =date.getDate()<=9 ? "0"+date.getDate() : date.getDate()
                            var month =(date.getMonth()+1)<=9 ? "0"+(date.getMonth()+1) : (date.getMonth()+1)
                            //console.log(day+"."+month+"."+date.getFullYear())
                            mtf4.fieldText=day+"."+month+"."+date.getFullYear()
                            calpop.close();
                        }
                    }
                }

                My.DaysOfWeekBox {
                    id: dowb
                    labelWidth: mtf5.labelWidth
                    width: parent.width
                    fontsize: fontSize
                    onSomeChecked: mtf4.fieldText=""
                }
                My.GroupComboView {
                    id: mcvgroups
                    labelWidth: mtf5.labelWidth
                    labelText: qsTr("Group")+mytrans.emptyString
                    listText: qsTr("Invited groups:")+mytrans.emptyString
                    fontsize: fontSize

                    expandSource: "../images/expand.png"
                    plusSource: "../images/plus_green.png"

                    ip: globalSettings.serverIP
                    port: globalSettings.serverPort
                    password: globalSettings.serverPassword
                    dbpassword: globalSettings.dbPassword
                    request: "select name from groupnames"
                    allowNew: false

                    onElementClicked:  Open.groupProfile(page, { "profileid": elementtext,
                                                             "ip": globalSettings.serverIP,
                                                             "port": globalSettings.serverPort,
                                                             "password": globalSettings.serverPassword,
                                                             "dbpassword": globalSettings.dbPassword})
                }
                My.GroupComboView {
                    id: mcvmembers
                    labelWidth: mtf5.labelWidth
                    labelText: qsTr("Member")+mytrans.emptyString
                    listText: qsTr("Invited members:")+mytrans.emptyString
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
                Button {
                    id: removebutton
                    text: qsTr("Delete event")+mytrans.emptyString
                    font.pixelSize: fontSize
                    font.bold: true
                    visible: page.editEvent!==""
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
                if (page.editEvent=="")
                {
                    successanimation.play()
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
            text: qsTr("Create/change a event?")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
        onAccepted: addToDatabase()
    }
    Dialog {
        id: deleteDialog
        title: qsTr("Warning")+mytrans.emptyString
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Deleting a (")+page.editEvent+qsTr(") event will <b>delete all found related data</b>!")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
        }
        onAccepted: sqlhandler.sendGetQuery("delete from events where name='"+page.editEvent+"'")
    }
//    Dialog {
//        id: queryExecutedDialog
//        title: qsTr("Info")+mytrans.emptyString
//        standardButtons: Dialog.No | Dialog.Yes
//        anchors.centerIn: parent
//        font.pixelSize: fontSize
//        Label {
//            text: "Event <b>successfully</b> created. Do you want to edit created event?"
//            anchors.fill: parent
//            font.pixelSize: fontSize
//            wrapMode: Text.WordWrap
//        }
//        onAccepted: {
//            page.editEvent=mtf1.fieldText;
//        }
//    }
    Dialog {
        id: queryNotExecutedDialog
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Database <b>error</b>! Event was not added.")+mytrans.emptyString
            anchors.fill: parent
            font.pixelSize: fontSize
            wrapMode: Text.WordWrap
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
            //stackView.push("DBAddEventPage.qml");
        }
    }
    Dialog {
        id: connectionErrorDialog
        title: qsTr("Error")+mytrans.emptyString
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        font.pixelSize: fontSize
        Label {
            text: qsTr("Network connection <b>error</b>! Event was not added.")+mytrans.emptyString
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
            text: qsTr("No groups or members added. No one will be invited to a new event.")+mytrans.emptyString
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
    function validTime(hh,mm) {
        if ((hh<24 && mm<60) || (hh==="24" && mm==="00"))
        {
            console.log("Введено корректное время! "+ hh+"."+mm);
            return true
        }
        else
            console.log("Введено некорректное время! "+ hh+"."+mm);
        return false
    }

    function validDate(date){ // date в формате 31.12.2014
        var d_arr = date.split('.');
        var d = new Date(d_arr[2]+'/'+d_arr[1]+'/'+d_arr[0]+''); // дата в формате 2014/12/31
        if (d_arr[2]!=d.getFullYear() || d_arr[1]!=(d.getMonth() + 1) || d_arr[0]!=d.getDate()) {
            console.log("Введена некорректная дата!");
            return false; // неккоректная дата
        };
        console.log("Введена корректная дата!");
        return true;
    }

    MySQLiteHandler {
        id: sqlhandlerEdit
        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        dbpassword: globalSettings.dbPassword
        onModelChanged: uploadToForm(data);
        Component.onCompleted: {
            if (page.editEvent!="")
                sendGetQuery("SELECT * FROM events LEFT JOIN (SELECT group_concat(name,', ') as groupnames FROM (SELECT name FROM groupnames g LEFT JOIN invites i ON g.groupid=i.groupid WHERE eventid=(SELECT eventid FROM events WHERE name='"+page.editEvent+"'))) LEFT JOIN (SELECT group_concat(name||' '||surname||' '||patronymic||' (id'||memberid||')',', ') as membernames FROM (SELECT * FROM members m LEFT JOIN invites i ON m.memberid=i.memberid WHERE eventid=(SELECT eventid FROM events WHERE name='"+page.editEvent+"')) WHERE eventid=(SELECT eventid FROM events WHERE name='"+page.editEvent+"')) WHERE eventid=(SELECT eventid FROM events WHERE name='"+page.editEvent+"')");
        }
        function uploadToForm(data)
        {
            var dataList = data.split("|||");
            var fields = dataList[1].split("|");
            mtf1.fieldText=fields[1];
            mtf5.fieldText=fields[2];
            mtf2.fieldText=fields[3].replace(":",".");
            mtf3.fieldText=fields[4].replace(":",".");
            if (fields[5]!==" ")
                mtf4.fieldText=fields[5];
            else
            {
                dowb.mon=fields[6]==="1";
                dowb.tue=fields[7]==="1";
                dowb.wed=fields[8]==="1";
                dowb.thu=fields[9]==="1";
                dowb.fri=fields[10]==="1";
                dowb.sat=fields[11]==="1";
                dowb.sun=fields[12]==="1";
            }
            var groups=fields[13].split(", ");
            if (fields[13]!==" ")
                for (var j=0; j<groups.length ; j++)
                    mcvgroups.elementmodel.append({ "text" : groups[j], "color": randomColor(), "unknown": false})
            var members=fields[14].split(", ");
            if (fields[14]!==" ")
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
