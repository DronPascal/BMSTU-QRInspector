import QtQuick 2.12
import QtQuick.Controls 2.12

Row {
    id: row
    property alias placeholderText: textfield.placeholderText
    property alias selectByMouse: textfield.selectByMouse
    property alias fontsize: label.font.pixelSize
    property alias fieldText: textfield.text
    property alias textfield: textfield

    property alias fieldWidth: textfield.width
    property alias inputMask: textfield.inputMask
    property alias inputMethodHints: textfield.inputMethodHints

    property alias labelText: label.text
    property alias labelWidth: label.width
    property alias labelLeftPadding: label.leftPadding

    property alias buttonSource: img.source

    function activeFocus() {
        textfield.forceActiveFocus()
    }
    function buttonColor(color){ button.color=color }


    signal textFieldChanged()
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
        width: parent.parent.width-label.width-20
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        TextField {
            id: textfield
            font.pixelSize: label.font.pixelSize
            selectByMouse: true
            width: parent.width-button.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            onTextChanged: textFieldChanged()
        }
        Rectangle {
            id: button
            width: parent.height
            height: width
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: textfield.right
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
                onClicked: {
                    forceActiveFocus();
                    buttonClicked()
                }
            }
            onColorChanged: timer.start()
            Timer { id: timer; interval: 3000; running: false; repeat: false; onTriggered: button.color="#dedede"}
        }
    }
}
