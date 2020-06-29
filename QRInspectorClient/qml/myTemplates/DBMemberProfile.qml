import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

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

    property bool hasphoto: false

    onClosed: item.destroy()
    Rectangle {
        anchors.fill: parent
        color: "white"
        border.color: "#efefef"
        //visible: item.parent.parent.currentItem!=="DBAddMemberPage.qml"
        SettingsHeader {
            id: msh
            anchors.top: parent.top
            fontsize: item.fontsize
            headertext:qsTr("Profile #")+item.infoRow[0]+mytrans.emptyString
            backSource: "../../images/close_black.png"
            onBackClicked: item.destroy()
            acceptSource: "../../images/edit.png"
            onAcceptClicked: {
                item.destroy()
                item.parent.parent.push("../../DBAddMemberPage.qml",{"editMember" : infoRow[4], "hasphoto" : item.hasphoto})
                console.log(item.hasphoto)
            }
        }

        Flickable {
            id: flick
            anchors {
                top: msh.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            contentWidth: parent.width
            contentHeight: 5*lbl1.height+groupsrect.height+eventsrect.height+img.height+column.spacing*3
            clip: true
            //boundsBehavior: Flickable.StopAtBounds

            Column {
                id: column
                anchors.fill: parent
                spacing: item.height/50
                topPadding: 10
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: img.height
                    width: parent.width
                    Image  {
                        id: img
                        width: Math.min(item.width,item.height)/2
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        sourceSize.width: parent.width
                        sourceSize.height: parent.height
                        layer.effect: OpacityMask {
                            maskSource: Item {
                                width: img.width
                                height: img.height
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: img.width
                                    height: width
                                    radius: width/2
                                }
                            }
                        }
                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            onDoubleClicked: {
                                img.layer.enabled=false
                                img.source="image://QZXing/encode/"+infoRow[4];
                            }
                        }
                    }
                    Image {
                        id: changerect
                        visible: false
                        source: "../../images/switchpersqr.png"
                        height: img.width/4
                        width: height
                        x: item.width-(item.width-img.width)/2+20
                        anchors.verticalCenter: img.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log(img.source)
                                if (img.source.toString().indexOf("image://qzxing/encode/")!==-1)
                                {
                                    img.layer.enabled=true
                                    img.source="image://serverImgProvider/"+photoclient.id++
                                }
                                else
                                {
                                    img.layer.enabled=false
                                    img.source="image://QZXing/encode/"+infoRow[4]
                                }
                            }
                        }
                    }
                }
                Text {
                    id: lbl1
                    width: parent.width
                    fontSizeMode: Text.Fit
                    text: item.infoRow[1]+" "+item.infoRow[2]+" "+item.infoRow[3];
                    font.pixelSize: fontsize+5
                    font.weight: Font.ExtraBold
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                TextInput  {
                    id: lbl4
                    width: parent.width
                    //fontSizeMode: Text.Fit
                    readOnly: true
                    selectByMouse: true
                    text: "QR("+item.infoRow[4]+")"
                    font.pixelSize: fontsize+4
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Label   {
                    id: lbl2
                    text: qsTr("Member groups: ")+mytrans.emptyString
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
                                        onClicked:{ item.destroy(); Open.groupProfile(item.parent, { "profileid": model.text,
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
                    text: qsTr("Member events: ")+mytrans.emptyString
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
                                        onClicked:{ item.destroy(); Open.eventProfile(item.parent, { "profileid": model.text,
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
        id: photoclient
        property int id: 0
        ip: item.ip
        port: item.port
        password: item.password
        onGetImgFromServer: {
            img.layer.enabled=true
            changerect.visible=true
            img.source = "image://serverImgProvider/"+id++;
            item.hasphoto=true
            console.log(item.hasphoto)
        }
        onGetServerResponse: img.source="image://QZXing/encode/"+infoRow[4];
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
        Component.onCompleted: sendGetQuery("SELECT * FROM (SELECT * FROM members WHERE memberid="+item.profileid+") LEFT JOIN (SELECT group_concat(name,', ') as groupnames FROM (SELECT name FROM groupnames n LEFT JOIN groups g ON n.groupid=g.groupid WHERE memberid="+item.profileid+")) LEFT JOIN (SELECT group_concat(name,', ') as eventnames FROM (SELECT name FROM events WHERE eventid in (SELECT eventid FROM invites WHERE (groupid in (SELECT groupid FROM groups WHERE memberid="+item.profileid+")) OR memberid="+item.profileid+")))")
    }
    function uploadToTable(data)
    {
        var dataList = data.split("|||");
        var fields = dataList[1].split("|");
        infoRow=fields;
        var groups=infoRow[5].split(", ");
        if (infoRow[5]!==" ")
            for (var j=0; j<groups.length ; j++)
                groupmodel.append({ "text" : groups[j], "color": randomColor(), "unknown": false})
        var events=infoRow[6].split(", ");
        if (infoRow[6]!==" ")
            for (j=0; j<events.length ; j++)
                eventsmodel.append({ "text" : events[j], "color": randomColor(), "unknown": false})
        photoclient.sendGet("images/"+infoRow[4]+".jpg");
        console.log("COUNT "+ eventsmodel.count)
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
