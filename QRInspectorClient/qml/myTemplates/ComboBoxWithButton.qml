import QtQuick 2.12
import QtQuick.Controls 2.12

Row {
    id: row
    width: parent.width
    property alias model: combobox.model
    property alias enabled: combobox.enabled
    property alias box: combobox

    property alias labelText: label.text
    property alias labelWidth: label.width
    property alias labelLeftPadding: label.leftPadding
    property alias fontsize: label.font.pixelSize

    property alias buttonSource: img.source

    function buttonColor(color){ button.color=color }


    signal buttonClicked()
    spacing: 10
    Label {
        id: label
        leftPadding: 10
        text: "label"
        anchors.verticalCenter: parent.verticalCenter
    }
    Rectangle {
        height: label.height*2
        width: parent.parent.width-label.width-row.spacing-label.leftPadding
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        ComboBox {
            id: combobox
            width: parent.width-button.width
            height: parent.height
            indicator.height: height*0.8
            indicator.width: height
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: label.font.pixelSize
        }

        Rectangle {
            id: button
            width: parent.height
            height: width
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: combobox.right
            color: "#dedede"
            Image {
                id: img
                width: parent.width*0.7
                height: width
                anchors.centerIn: parent
                sourceSize.width: width
                sourceSize.height: width
            }
            MouseArea {
                id: buttonma
                anchors.fill: parent
                onPressed: parent.color="silver"
                onReleased: parent.color="#dedede"
                onClicked: buttonClicked()
            }
            onColorChanged: timer.start()
            Timer { id: timer; interval: 3000; running: false; repeat: false; onTriggered: button.color="#dedede"}
        }
    }
}
