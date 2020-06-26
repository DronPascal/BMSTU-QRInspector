import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    property alias text: nameLabel.text
    property alias color: nameLabel.color
    property alias imageSource:  image.source
    property alias fontsize: nameLabel.font.pixelSize
    property alias mousearea: mousearea
    property alias topline: topline.visible
    height: nameLabel.height*2.3
    width: parent.width
    Rectangle {
        anchors.fill: parent
        Rectangle{
            width: parent.width*0.92
            height: 1
            color: "#eeeeee"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }
        Rectangle{
            id: topline
            width: parent.width*0.95
            height: 1
            color: "#eeeeee"
            visible: false
            anchors.top: parent.top
            anchors.right: parent.right
        }
        MouseArea {
            id: mousearea
            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                parent.color = "#eeeeee"
                colort.restart()
            }
            onEntered:  {
                parent.color = "#eeeeee"
                colort.restart()
            }
            onExited: parent.color = "white"

            Timer {id: colort; interval: 500; running: false; repeat: false; onTriggered: parent.parent.color = "white"}
            onClicked: forceActiveFocus()
        }
        Label {
            id: nameLabel
            font.pixelSize: fontsize
            leftPadding: 10
            anchors.verticalCenter: parent.verticalCenter
        }
        Image {
            id: image
            x: 24*parent.width/25-width/2
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height/2
            width: height
            source: "../images/forward.png"
            sourceSize.width: width
            sourceSize.height: width
        }
    }
}
