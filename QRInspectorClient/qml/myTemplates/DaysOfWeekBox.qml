import QtQuick 2.12
import QtQuick.Controls 2.12
Item {
    id: mainitem
    height: label.height+mon.height
    property alias fontsize: label.font.pixelSize
    property alias labelWidth: mainlabel.width

    property alias mon: mon.checked
    property alias tue: tue.checked
    property alias wed: wed.checked
    property alias thu: thu.checked
    property alias fri: fri.checked
    property alias sat: sat.checked
    property alias sun: sun.checked

    signal someChecked()
    function clearAll() {
        mon.checked=false
        tue.checked=false
        wed.checked=false
        thu.checked=false
        fri.checked=false
        sat.checked=false
        sun.checked=false
    }

    Row {
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        Label {
            id: mainlabel
            text: qsTr("Days")+mytrans.emptyString
            font.pixelSize: label.font.pixelSize
            leftPadding: 10
            rightPadding: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        Flickable{
            interactive: boxrow.spacing==0
            anchors.verticalCenter: parent.verticalCenter
            flickableDirection: Flickable.HorizontalFlick
            width: mainitem.width-mainlabel.width-20
            height: label.height+mon.height

            contentWidth: label.width*8
            contentHeight: height
            clip: true
            Row {
                id: boxrow
                anchors.verticalCenter: parent.verticalCenter
                spacing: (mainitem.width-30-mainlabel.width-label.width*7)/7 > mainitem.width/30 ? mainitem.width/30 : (mainitem.width-30-mainlabel.width-label.width*7)/7>0 ? (mainitem.width-30-mainlabel.width-label.width*7)/7 : 0
                Column {
                    Label {
                        id: label
                        text: qsTr("Mon")+mytrans.emptyString
                        verticalAlignment: Text.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: mon.checked=!mon.checked
                        }
                    }
                    CheckBox {
                        id: mon
                        padding: 0
                        onCheckedChanged: checked ? someChecked() : {}
                        anchors.horizontalCenter: parent.horizontalCenter
                        indicator.width: fontsize*1.6
                        indicator.height: fontsize*1.6
                        indicator.implicitHeight: fontsize*1.6
                        indicator.implicitWidth: fontsize*1.6
                    }
                }
                Column {
                    Label {
                        text: qsTr("Tue")+mytrans.emptyString
                        font.pixelSize: label.font.pixelSize
                        verticalAlignment: Text.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: tue.checked=!tue.checked
                        }
                    }
                    CheckBox {
                        id: tue
                        padding: 0
                        onCheckedChanged: checked ? someChecked() : {}
                        indicator.width: fontsize*1.6
                        indicator.height: fontsize*1.6
                        indicator.implicitHeight: fontsize*1.6
                        indicator.implicitWidth: fontsize*1.6
                    }
                }
                Column {
                    Label {
                        text: qsTr("Wed")+mytrans.emptyString
                        font.pixelSize: label.font.pixelSize
                        verticalAlignment: Text.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: wed.checked=!wed.checked
                        }
                    }
                    CheckBox {
                        id: wed
                        padding: 0
                        onCheckedChanged: checked ? someChecked() : {}
                        indicator.width: fontsize*1.6
                        indicator.height: fontsize*1.6
                        indicator.implicitHeight: fontsize*1.6
                        indicator.implicitWidth: fontsize*1.6
                    }
                }
                Column {
                    Label {
                        text: qsTr("Thu")+mytrans.emptyString
                        font.pixelSize: label.font.pixelSize
                        verticalAlignment: Text.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: thu.checked=!thu.checked
                        }
                    }
                    CheckBox {
                        id: thu
                        padding: 0
                        onCheckedChanged: checked ? someChecked() : {}
                        indicator.width: fontsize*1.6
                        indicator.height: fontsize*1.6
                        indicator.implicitHeight: fontsize*1.6
                        indicator.implicitWidth: fontsize*1.6
                    }
                }
                Column {
                    Label {
                        text: qsTr("Fri")+mytrans.emptyString
                        font.pixelSize: label.font.pixelSize
                        verticalAlignment: Text.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: fri.checked=!fri.checked
                        }
                    }
                    CheckBox {
                        id: fri
                        padding: 0
                        onCheckedChanged: checked ? someChecked() : {}
                        indicator.width: fontsize*1.6
                        indicator.height: fontsize*1.6
                        indicator.implicitHeight: fontsize*1.6
                        indicator.implicitWidth: fontsize*1.6
                    }
                }
                Column {
                    Label {
                        id: satl
                        text: qsTr("Sat")+mytrans.emptyString
                        font.pixelSize: label.font.pixelSize
                        verticalAlignment: Text.AlignVCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        background: Rectangle {color: "mistyrose"}
                        width: sat.width
                        MouseArea {
                            anchors.fill: parent
                            onClicked: sat.checked=!sat.checked
                        }
                    }
                    CheckBox {
                        id: sat
                        //background: Rectangle {color: "mistyrose"}
                        padding: 0
                        //width: satl.width
                        onCheckedChanged: checked ? someChecked() : {}
                        indicator.width: fontsize*1.6
                        indicator.height: fontsize*1.6
                        indicator.implicitHeight: fontsize*1.6
                        indicator.implicitWidth: fontsize*1.6
                    }
                }
                Column {
                    Label {
                        id: sunl
                        text: qsTr("Sun")+mytrans.emptyString
                        font.pixelSize: label.font.pixelSize
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: sun.width
                        background: Rectangle {color: "mistyrose"}
                        MouseArea {
                            anchors.fill: parent
                            onClicked: sun.checked=!sun.checked
                        }
                    }
                    CheckBox {
                        id: sun
                        //background: Rectangle {color: "mistyrose"}
                        //width: sunl.width
                        padding: 0
                        onCheckedChanged: checked ? someChecked() : {}
                        indicator.width: fontsize*1.6
                        indicator.height: fontsize*1.6
                        indicator.implicitHeight: fontsize*1.6
                        indicator.implicitWidth: fontsize*1.6
                    }
                }
            }
        }
    }
}
