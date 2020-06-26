import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4 as Old
import QtQuick.Controls.Styles 1.4
Popup {
    id: item
    width: parent.width*0.8//parent.height < parent.width ? height*0.7 : parent.width*0.8
    height: parent.height*0.7
    anchors.centerIn: parent
    padding: 1
    property alias model: fieldbox.model

    property alias fontsize: item.fontsize
    property int fontsize: 10
    SettingsHeader {
        id: msh
        headertext: qsTr("Select")+mytrans.emptyString
        fontsize: fontSize
        backSource: "../../images/close_black.png"
        onBackClicked: close()
        acceptSource: "../../images/accept_black.png"
        onAcceptClicked: startFiltering()
    }

    function startFiltering() {
        if (column.type==="text")
        {
            item.parent.sortModelTextFields(fieldbox.currentText, tfld1.text, matchb.checked, lcaseb.checked, ascb.checked, descb.checked)
            close();
        }
        else if (column.type==="date")
        {
            if (validDate(tfld2.text) || validDate(tfld3.text) || dtascb.checked || dtdescb.checked)
            {
                item.parent.sortModelDateFields(fieldbox.currentText, tfld2.text, tfld3.text, dtascb.checked, dtdescb.checked)
                close();
            }
        }
        else if (column.type==="time")
        {
            if (validTime(tfld2.text.split(".")[0], tfld2.text.split(".")[1]) || validTime(tfld3.text.split(".")[0], tfld3.text.split(".")[1]) || dtascb.checked || dtdescb.checked)
            {
                item.parent.sortModelTimeFields(fieldbox.currentText, tfld2.text, tfld3.text, dtascb.checked, dtdescb.checked)
                close();
            }
        }
    }

    function validTime(hh,mm) {
        if ((hh<24 && mm<60) || (hh==="24" && mm==="00"))
            return true
        return false
    }

    function validDate(date){ // date в формате 31.12.2014
        var d_arr = date.split('.');
        var d = new Date(d_arr[2]+'/'+d_arr[1]+'/'+d_arr[0]+''); // дата в формате 2014/12/31
        if (d_arr[2]!=d.getFullYear() || d_arr[1]!=(d.getMonth() + 1) || d_arr[0]!=d.getDate())
            return false
        return true;
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
            contentHeight: fieldbox.height*4+10*4
            clip: true
            Column {
                id: column
                anchors.fill: parent
                spacing: 0
                topPadding: 0
                property int elheight: lbl1.height*2
                property int labwidth: lbl2.width
                property string type: fieldbox.currentValue==="date" ? "date" : (fieldbox.currentValue==="time" || fieldbox.currentValue==="beginning" || fieldbox.currentValue==="ending") ? "time" : "text"
                Row {
                    spacing: padding
                    padding: 10
                    Label {
                        id: lbl1
                        text: qsTr("Field")+mytrans.emptyString
                        width: column.labwidth
                        font.pixelSize: item.fontsize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ComboBox {
                        id: fieldbox
                        height: tfld1.height
                        width: item.width-lbl1.width-parent.spacing*3
                        font.pixelSize: item.fontsize
                        indicator.implicitHeight: height*0.8
                        indicator.implicitWidth: height
                        delegate: ItemDelegate {
                            text: fieldbox.model[index]
                            font.pixelSize: fontsize
                            width: parent.width
                            background: Rectangle { id: backr  }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: backr.color="#eeeeee"
                                onExited: backr.color="white"
                                onClicked: {
                                    fieldbox.currentIndex=index;
                                    column.forceActiveFocus()
                                    if (fieldbox.model[index]==="time" || fieldbox.model[index]==="date")
                                    {tfld2.text=""; tfld3.text=""}
                                }
                            }
                        }
                    }
                }
                Row {
                    spacing: padding
                    padding: 10
                    visible: column.type=="text"
                    Label {
                        id: lbl2
                        text: qsTr("Sorting")+mytrans.emptyString
                        font.pixelSize: item.fontsize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Image {
                        id: asc
                        height: column.elheight*0.8
                        width: height
                        source: "../../images/asc.png"
                        sourceSize.width: height
                        sourceSize.height: height
                    }
                    CheckBox {
                        id: ascb
                        padding: 0
                        onClicked: (descb.checked) ? descb.checked=false : {}
                        anchors.verticalCenter: parent.verticalCenter
                        indicator.width: column.elheight*0.8
                        indicator.height: column.elheight*0.8
                        indicator.implicitHeight: column.elheight*0.8
                        indicator.implicitWidth: column.elheight*0.8
                    }
                    Image {
                        id: desc
                        height: column.elheight*0.8
                        width: height
                        source: "../../images/desc.png"
                        sourceSize.width: height
                        sourceSize.height: height
                    }
                    CheckBox {
                        id: descb
                        padding: 0
                        onClicked: (ascb.checked) ? ascb.checked=false : {}
                        anchors.verticalCenter: parent.verticalCenter
                        indicator.width: column.elheight*0.8
                        indicator.height: column.elheight*0.8
                        indicator.implicitHeight: column.elheight*0.8
                        indicator.implicitWidth: column.elheight*0.8
                    }
                }
                Row {
                    spacing: padding
                    padding: 10
                    visible: column.type=="text"
                    Label {
                        id: lbl3
                        text: qsTr("Filter")+mytrans.emptyString
                        width: column.labwidth
                        font.pixelSize: item.fontsize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    TextField {
                        id: tfld1
                        height: lbl3.height*2
                        width: item.width-lbl3.width-parent.spacing*3
                        font.pixelSize: item.fontsize
                    }
                }
                Row {
                    spacing: padding
                    padding: 10
                    visible: column.type=="text"
                    Rectangle {height: 1; width: column.labwidth; color: "transparent"}
                    Image {
                        id: lcase
                        height: column.elheight*0.8
                        width: height
                        source: "../../images/lettercase.png"
                        sourceSize.width: height
                        sourceSize.height: height
                    }
                    CheckBox {
                        id: lcaseb
                        padding: 0
                        onCheckedChanged: {}
                        anchors.verticalCenter: parent.verticalCenter
                        indicator.width: column.elheight*0.8
                        indicator.height: column.elheight*0.8
                        indicator.implicitHeight: column.elheight*0.8
                        indicator.implicitWidth: column.elheight*0.8
                    }
                    Image {
                        id: match
                        height: column.elheight*0.8
                        width: height
                        source: "../../images/match.png"
                        sourceSize.width: height
                        sourceSize.height: height
                    }
                    CheckBox {
                        id: matchb
                        padding: 0
                        onCheckedChanged: {}
                        anchors.verticalCenter: parent.verticalCenter
                        indicator.width: column.elheight*0.8
                        indicator.height: column.elheight*0.8
                        indicator.implicitHeight: column.elheight*0.8
                        indicator.implicitWidth: column.elheight*0.8
                    }
                }
                Row {
                    id: afterrow
                    spacing: padding
                    padding: 10
                    visible: column.type=="date" ||  column.type=="time"
                    Label {
                        id: lbl4
                        text: qsTr("After")+mytrans.emptyString
                        width: column.labwidth
                        font.pixelSize: item.fontsize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Row {
                        padding: 0
                        width: item.width-lbl4.width-afterrow.spacing*3
                        TextField {
                            id: tfld2
                            height: lbl4.height*2
                            placeholderText: column.type=="date" ? "21.06.2020" : "12.04"
                            width: item.width-lbl4.width-afterrow.spacing*3-button.width
                            font.pixelSize: item.fontsize
                            inputMethodHints: Qt.ImhDigitsOnly
                        }
                        Rectangle {
                            id: button
                            width: height
                            height: column.type=="date" ? parent.height : 0
                            visible: column.type=="date"
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#dedede"
                            Image {
                                source: "../../images/calendar.png"
                                width: parent.width*0.7
                                height: width
                                anchors.centerIn: parent
                                sourceSize.width: width
                                sourceSize.height: width
                            }
                            MouseArea {
                                anchors.fill: parent
                                onPressed: parent.color="silver"
                                onReleased: parent.color="#dedede"
                                onClicked: {
                                    forceActiveFocus();
                                    calpop.befororafter=0
                                    calpop.open()
                                }
                            }
                        }
                    }
                }
                Row {
                    id: beforerow
                    spacing: padding
                    padding: 10
                    visible: column.type=="date" ||  column.type=="time"
                    Label {
                        id: lbl5
                        text: qsTr("Before")+mytrans.emptyString
                        width: column.labwidth
                        font.pixelSize: item.fontsize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Row {
                        width: item.width-lbl3.width-beforerow.spacing*3
                        TextField {
                            id: tfld3
                            height: lbl5.height*2
                            placeholderText: column.type=="date" ? "28.07.2020" : "18.23"
                            width: item.width-lbl3.width-beforerow.spacing*3-button2.width
                            font.pixelSize: item.fontsize
                            inputMethodHints: Qt.ImhDigitsOnly
                        }
                        Rectangle {
                            id: button2
                            width: height
                            height: column.type=="date" ? parent.height : 0
                            visible: column.type=="date"
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#dedede"
                            Image {
                                source: "../../images/calendar.png"
                                width: parent.width*0.7
                                height: width
                                anchors.centerIn: parent
                                sourceSize.width: width
                                sourceSize.height: width
                            }
                            MouseArea {
                                anchors.fill: parent
                                onPressed: parent.color="silver"
                                onReleased: parent.color="#dedede"
                                onClicked: {
                                    forceActiveFocus();
                                    calpop.befororafter=1
                                    calpop.open()
                                }
                            }
                        }
                    }
                }
                Row {
                    spacing: padding
                    padding: 10
                    visible: column.type=="date" ||  column.type=="time"
                    Rectangle {height: 1; width: column.labwidth; color: "transparent"}
                    Image {
                        id: dtasc
                        height: column.elheight*0.8
                        width: height
                        source: "../../images/asc.png"
                        sourceSize.width: height
                        sourceSize.height: height
                    }
                    CheckBox {
                        id: dtascb
                        padding: 0
                        onClicked: (dtdescb.checked) ? dtdescb.checked=false : {}
                        anchors.verticalCenter: parent.verticalCenter
                        indicator.width: column.elheight*0.8
                        indicator.height: column.elheight*0.8
                        indicator.implicitHeight: column.elheight*0.8
                        indicator.implicitWidth: column.elheight*0.8
                    }
                    Image {
                        id: dtdesc
                        height: column.elheight*0.8
                        width: height
                        source: "../../images/desc.png"
                        sourceSize.width: height
                        sourceSize.height: height
                    }
                    CheckBox {
                        id: dtdescb
                        padding: 0
                        onClicked: (dtascb.checked) ? dtascb.checked=false : {}
                        anchors.verticalCenter: parent.verticalCenter
                        indicator.width: column.elheight*0.8
                        indicator.height: column.elheight*0.8
                        indicator.implicitHeight: column.elheight*0.8
                        indicator.implicitWidth: column.elheight*0.8
                    }
                }
            }
        }
    }
    Popup {
        property int befororafter: 0
        id: calpop
        width: Math.min(item.width, item.height)*0.8
        height: width
        anchors.centerIn: parent
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
                var dayetext = day+"."+month+"."+date.getFullYear()
                if (calpop.befororafter===0)
                {
                    tfld2.text = dayetext
                    if (tfld3.text=="")
                        tfld3.text = dayetext
                }
                else if (calpop.befororafter===1)
                {
                    tfld3.text = dayetext
                    if (tfld2.text=="")
                        tfld2.text = dayetext
                }
                calpop.close();
            }
        }
    }
}

