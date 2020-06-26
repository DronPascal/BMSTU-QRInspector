import QtQuick 2.12
import QtQuick.Controls 2.12

Row {
    id: row
    property alias placeholderText: textfield.placeholderText
    property alias selectByMouse: textfield.selectByMouse
    property alias fontsize: label.font.pixelSize
    property alias fieldText: textfield.text
    property alias fieldWidth: textfield.width
    property alias inputMask: textfield.inputMask
    property alias inputMethodHints: textfield.inputMethodHints

    property alias labelText: label.text
    property alias labelWidth: label.width
    function activeFocus() {
        textfield.forceActiveFocus()
    }

    signal textFieldChanged()
    spacing: 10
    Label {
        id: label
        leftPadding: 10
        text: "label"
        font.pixelSize: row.fontSize
        anchors.verticalCenter: parent.verticalCenter
        onClipChanged: textfield.forceActiveFocus()
    }
    TextField {
        id: textfield
        font.pixelSize: label.font.pixelSize
        selectByMouse: true
        height: label.height*2
        width: parent.parent.width-label.width-20
        onTextChanged: textFieldChanged()
    }
}
