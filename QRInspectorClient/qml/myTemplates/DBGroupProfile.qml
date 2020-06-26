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
            headertext:qsTr("Group #")+mytrans.emptyString+item.infoRow[0]
            backSource: "../../images/close_black.png"
            onBackClicked: item.destroy();
            acceptSource: "../../images/edit.png"
            onAcceptClicked: {
                item.destroy();
                item.parent.parent.push("../../DBAddGroupPage.qml",{"editGroup":infoRow[1]})
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
            contentHeight: 4*lbl1.height+membersrect.height+eventsrect.height+column.spacing*3
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
                    text: qsTr("<b>Name: </b>")+mytrans.emptyString+item.infoRow[1]
                    font.pixelSize: fontsize+4
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                ///++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                Label   {
                    id: lbl2
                    text: qsTr("Group events: ")+mytrans.emptyString
                    font.pixelSize: fontsize
                    leftPadding: 10
                    font.weight: Font.DemiBold
                    visible: eventsmodel.count>0
                }
                Rectangle {
                    id: eventsrect
                    width: parent.width
                    height: visible ? view2.cellHeight*Math.ceil(eventsmodel.count/Math.floor(view2.width/view2.cellWidth)) : 0
                    visible: lbl3.visible

                    ListModel {
                        id: eventsmodel
                    }

                    GridView {
                        id: view2
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        cellHeight: fontsize*2
                        cellWidth: (parent.width-20)/2
                        model: eventsmodel
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
                                        onClicked: { item.destroy(); Open.eventProfile(item.parent, { "profileid": model.text,
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
                    text: qsTr("Group members: ")+mytrans.emptyString
                    font.pixelSize: fontsize
                    leftPadding: 10
                    font.weight: Font.DemiBold
                    visible: membersmodel.count>0
                }
                Rectangle {
                    id: membersrect
                    width: parent.width
                    height: visible ? view.cellHeight*Math.ceil(membersmodel.count/Math.floor(view.width/view.cellWidth)) : 0
                    visible: lbl3.visible

                    ListModel {
                        id: membersmodel
                    }
                    GridView {
                        id: view
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
        Component.onCompleted: sendGetQuery("SELECT * FROM groupnames LEFT JOIN (SELECT group_concat(name,', ') as eventnames FROM (SELECT name FROM events e LEFT JOIN invites i ON e.eventid=i.eventid WHERE groupid=(SELECT groupid FROM groupnames WHERE name='"+item.profileid+"'))) LEFT JOIN (SELECT group_concat(name||' '||surname||' '||patronymic||' (id'||memberid||')',', ') as membernames FROM (SELECT * FROM members m LEFT JOIN groups g ON m.memberid=g.memberid WHERE groupid=(SELECT groupid FROM groupnames WHERE name='"+item.profileid+"'))) WHERE groupid=(SELECT groupid FROM groupnames WHERE name='"+item.profileid+"')")
    }
    function uploadToTable(data)
    {
        var dataList = data.split("|||");
        var roleNames = dataList[0].split("|");
        var fields = dataList[1].split("|");

        infoRow=fields;
        var events=infoRow[2].split(", ");
        if (infoRow[2]!==" ")
            for (var j=0; j<events.length ; j++)
                eventsmodel.append({ "text" : events[j], "color": randomColor(), "unknown": false})
        var members=infoRow[3].split(", ");
        if (infoRow[3]!==" ")
            for (j=0; j<members.length ; j++)
            {
                console.log(members[j])
                membersmodel.append({ "text" : members[j], "color": randomColor(), "unknown": false})
            }
        //console.log("COUNT "+ eventsmodel.count)

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
