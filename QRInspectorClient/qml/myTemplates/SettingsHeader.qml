import QtQuick 2.12
import QtQuick.Controls 2.12

Label {
    id: label

    property alias headertext: label.text
    property alias backSource: backimg.source
    property alias acceptSource: acceptimg.source
    property alias fontsize: label.fontsize
    property int fontsize: 10

    signal backClicked();
    signal acceptClicked();

    anchors.horizontalCenter: parent.horizontalCenter
    bottomPadding: 10
    topPadding: 10
    width: parent.width
    font.pixelSize: fontsize+5
    horizontalAlignment: Text.AlignHCenter
    font.bold: true
    Rectangle {
        height: label.height
        width: backimg.width*2
        anchors.left: parent.left
        anchors.top: parent.top
        Image {
            id: backimg
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height/2
            width: height
            sourceSize.width: width
            sourceSize.height: width
        }
        MouseArea {
            z:10
            anchors.fill: parent
            onClicked: {
                forceActiveFocus()
                backClicked()
            }
        }
    }
    Rectangle {
        height: label.height
        width: acceptimg.width*2
        anchors.right: parent.right
        anchors.top: parent.top
        Image {
            id: acceptimg
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height/2
            width: height
            sourceSize.width: width
            sourceSize.height: width
        }
        MouseArea {
            z:10
            anchors.fill: parent
            onClicked: {
                forceActiveFocus()
                acceptClicked()
            }
        }
    }
    Rectangle {
        id: botline
        height: 1
        width: label.width
        color: "#eeeeee"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }
}
