import QtQuick 2.12
import QtQuick.Controls 2.12

import QZXing 2.3
import MyExtentions 1.0
import "../../DBProfilesOpener.js" as Open
Popup {
    id: item
    width: parent.width*0.8//parent.height < parent.width ? height*0.7 : parent.width*0.8
    height: parent.height*0.7//Math.min(parent.height,parent.width)*0.7
    anchors.centerIn: parent
    padding: 1
    property alias profileid: item.profileid
    property string profileid: ""

    property alias ip: item.ip
    property alias port: item.port
    property alias password: item.password
    property alias dbpassword: item.dbpassword

    property string ip: ""
    property string port: ""
    property string password: ""
    property string dbpassword: ""

    property int fontsize: height/25
    property var infoRow

    onClosed: item.destroy()
    Rectangle {
        anchors.fill: parent
        color: "white"
        border.color: "#efefef"
        SettingsHeader {
            id: msh
            anchors.top: parent.top
            fontsize: item.fontsize
            headertext:qsTr("Event #")+mytrans.emptyString+item.infoRow[0]
            backSource: "../../images/close_black.png"
            onBackClicked: item.destroy();
            acceptSource: "../../images/edit.png"
            onAcceptClicked: {
                item.destroy();
                item.parent.parent.push("../../DBAddEventPage.qml",{"editEvent":infoRow[1]})
            }
        }
        Flickable {
            anchors {
                top: msh.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            contentWidth: parent.width
            contentHeight: 6*lbl1.height+groupsrect.height+membersrect.height+column.spacing*7
            clip: true
            //boundsBehavior: Flickable.StopAtBounds

            Column {
                id: column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: msh.bottom
                spacing: item.height/50
                topPadding: 10
                Text {
                    id: lbl1
                    width: parent.width
                    fontSizeMode: Text.Fit
                    text: item.infoRow[1]
                    font.pixelSize: fontsize+4
                    font.weight: Font.ExtraBold
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    id: lbl4
                    width: parent.width
                    fontSizeMode: Text.Fit
                    text: (item.infoRow[5]!==" "? (qsTr("<b>Date: </b>")+item.infoRow[5]+"   "): "")+qsTr("<b>Time: </b>")+item.infoRow[3]+" - "+item.infoRow[4]+mytrans.emptyString
                    font.pixelSize: fontsize
                    leftPadding: 10
                    horizontalAlignment: Text.AlignLeft
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    id: lbl5
                    width: parent.width
                    fontSizeMode: Text.Fit
                    text: qsTr("<b>Place: </b>")+item.infoRow[2]+mytrans.emptyString
                    font.pixelSize: fontsize
                    leftPadding: 10
                    horizontalAlignment: Text.AlignLeft
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    id: lbl6
                    function dow(i){return item.infoRow[i]==="1"?"\u2705":"\u274C"}
                    visible: item.infoRow[5]===" "
                    width: parent.width
                    fontSizeMode: Text.Fit
                    text: qsTr("Days of week: ")+mytrans.emptyString+dow(6)+dow(7)+dow(8)+dow(9)+dow(10)+dow(11)+dow(12)
                    font.pixelSize: fontsize
                    font.weight: Font.Bold
                    leftPadding: 10
                    horizontalAlignment: Text.AlignLeft
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                ///++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                Label   {
                    id: lbl2
                    text: qsTr("Event groups: ")+mytrans.emptyString
                    font.pixelSize: fontsize
                    leftPadding: 10
                    font.weight: Font.DemiBold
                    visible: groupmodel.count>0
                }
                Rectangle {
                    id: groupsrect
                    width: parent.width
                    height: visible ? view.cellHeight*Math.ceil(groupmodel.count/Math.floor(view.width/view.cellWidth)) : 0
                    visible: lbl2.visible

                    ListModel {
                        id: groupmodel
                    }
                    GridView {
                        id: view
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        cellHeight: fontsize*2
                        cellWidth: (parent.width-20)/2
                        model: groupmodel
                        clip: true
                        highlightFollowsCurrentItem: false

                        interactive: false

                        delegate: Item {
                            property var view: GridView.view
                            property var isCurrent: GridView.isCurrentItem

                            height: view.cellHeight
                            width: view.cellWidth

                            Rectangle {
                                anchors.margins: 5
                                anchors.fill: parent
                                color: model.color
                                border {
                                    color: model.unknown ? "brown" : "black"
                                    width: 2
                                }
                                radius: height/5

                                Text {
                                    anchors.fill: parent
                                    anchors.verticalCenter: parent.verticalCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    font.pixelSize: fontsize
                                    leftPadding: height/5
                                    text: model.text
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: { item.destroy(); Open.groupProfile(item.parent, { "profileid": model.text,
                                                                                           "ip": item.ip,
                                                                                           "port": item.port,
                                                                                           "password": item.password,
                                                                                           "dbpassword": item.dbpassword})
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                ///++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                Label   {
                    id: lbl3
                    text: qsTr("Event members: ")+mytrans.emptyString
                    font.pixelSize: fontsize
                    leftPadding: 10
                    font.weight: Font.DemiBold
                    visible: membersmodel.count>0
                }
                Rectangle {
                    id: membersrect
                    width: parent.width
                    height: visible ? view2.cellHeight*Math.ceil(membersmodel.count/Math.floor(view2.width/view2.cellWidth)) : 0
                    visible: lbl3.visible

                    ListModel {
                        id: membersmodel
                    }
                    GridView {
                        id: view2
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        cellHeight: fontsize*2
                        cellWidth: parent.width-20
                        model: membersmodel
                        clip: true
                        highlightFollowsCurrentItem: false

                        interactive: false

                        delegate: Item {

                            height: view2.cellHeight
                            width: view2.cellWidth

                            Rectangle {
                                anchors.margins: 5
                                anchors.fill: parent
                                color: model.color
                                border {
                                    color: model.unknown ? "brown" : "black"
                                    width: 2
                                }
                                radius: height/5

                                Text {
                                    anchors.fill: parent
                                    anchors.verticalCenter: parent.verticalCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    font.pixelSize: fontsize
                                    leftPadding: height/5
                                    text: model.text
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            var memberid = model.text.substring(model.text.indexOf("(")+3, model.text.indexOf(")"));
                                            item.destroy();
                                            Open.memberProfile(item.parent, { "profileid": memberid,
                                                                   "ip": item.ip,
                                                                   "port": item.port,
                                                                   "password": item.password,
                                                                   "dbpassword": item.dbpassword})
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    MyClient {
        id: myclient
        property int id: 0
        ip: item.ip
        port: item.port
        password: item.password
        onGetImgFromServer: img.source = "image://serverImgProvider/"+(id++);
        Component.onCompleted: sendGet("images/"+infoRow[4]+".jpg");
    }

    MySQLiteHandler {
        id: sqlhandler
        ip: item.ip
        port: item.port
        password: item.password
        dbpassword: item.dbpassword
        onErrorFounded: {}
        onSqlErrorFounded: {}
        onModelChanged: uploadToTable(data);
        Component.onCompleted: sendGetQuery("SELECT * FROM events LEFT JOIN (SELECT group_concat(name,', ') as groupnames FROM (SELECT name FROM groupnames g LEFT JOIN invites i ON g.groupid=i.groupid WHERE eventid=(SELECT eventid FROM events WHERE name='"+item.profileid+"'))) LEFT JOIN (SELECT group_concat(name||' '||surname||' '||patronymic||' (id'||memberid||')',', ') as membernames FROM (SELECT * FROM members m LEFT JOIN invites i ON m.memberid=i.memberid WHERE eventid=(SELECT eventid FROM events WHERE name='"+item.profileid+"')) WHERE eventid=(SELECT eventid FROM events WHERE name='"+item.profileid+"')) WHERE eventid=(SELECT eventid FROM events WHERE name='"+item.profileid+"')")
    }
    function uploadToTable(data)
    {
        var dataList = data.split("|||");
        var fields = dataList[1].split("|");

        infoRow=fields;
        var groups=infoRow[13].split(", ");
        if (infoRow[13]!==" ")
            for (var j=0; j<groups.length ; j++)
                groupmodel.append({ "text" : groups[j], "color": randomColor(), "unknown": false})
        var members=infoRow[14].split(", ");
        if (infoRow[14]!==" ")
            for (j=0; j<members.length ; j++)
                membersmodel.append({ "text" : members[j], "color": randomColor(), "unknown": false})

    }
    function randomColor(){
        var r=Math.floor(Math.random() * (150)+106);
        var g=Math.floor(Math.random() * (150)+106);
        var b=Math.floor(Math.random() * (150)+106);
        var c='#' + r.toString(16) + g.toString(16) + b.toString(16);
        console.log(c);
        return c;
    }

    Component.onCompleted: open()
}
