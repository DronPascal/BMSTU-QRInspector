import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
Column {
    id:column
    width: parent.width
    spacing: 5
    visible: searchmodel.model.count!=0
    property alias currentText: combobox.currentText
    //property alias validator: combotext.validator

    property alias fontsize: label.font.pixelSize
    property alias labelText: label.text
    property alias labelWidth: label.width
    property alias elementsHeight: elementsRect.height

    property alias plusSource: plus.source
    property alias plusma: plusma

    property alias expandSource: column.expandsource
    property string expandsource: ""


    property alias ip: searchmodel.ip
    property alias port: searchmodel.port
    property alias password: searchmodel.password
    property alias dbpassword: searchmodel.dbpassword
    property alias request: searchmodel.request

    property alias elementmodel: listmodel
    property alias searchmodel: searchmodel
    //property alias elementClicked: elementClicked
    signal elementClicked(int index, string elementtext);

    property alias allowNew: column.allowNew
    property bool allowNew: false

    property alias elementScaling: column.elementScaling
    property int elementScaling: 7

    function update() {
        searchmodel.model.clear()
        searchmodel.update()
    }

    Row {
        id: row
        width: parent.width
        //property alias minussource: minus.source
        spacing: 10
        Label {
            id: label
            leftPadding: 10
            text: "label"
            anchors.verticalCenter: parent.verticalCenter
        }


        ComboBox {
            id: combobox
            height: label.height*2
            width:parent.parent.width-label.width-30-plusrect.width
            font.pixelSize: label.font.pixelSize
            editable: true
            selectTextByMouse: true

            indicator.width: combobox.height
            indicator.height: combobox.height*0.8
            indicator.implicitHeight: combobox.height*0.8
            indicator.implicitWidth: combobox.height
            onModelChanged: currentIndex= -1

            delegate: Rectangle {
                id: backr
                onVisibleChanged: {
                    if (combobox.focus && visible)
                        forceActiveFocus()
                }
                width: parent.width
                height: label.height*2
                Text {
                    leftPadding: 10
                    anchors.fill: parent
                    text: model.text
                    color: hasElement(model.text) ? "lightgray" : "black"
                    font.pixelSize: label.font.pixelSize
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: backr.color="#eeeeee"
                    onExited: backr.color="white"
                    onClicked: {
                        if (!hasElement(model.text))
                        {
                            combobox.currentIndex=index;
                            column.forceActiveFocus()
                            addElement(currentText)
                        }
                    }
                }
                //onVisibleChanged: visible ? combobox.indicator.forceActiveFocus() : {}
            }
        }


        SQListModel {
            id: searchmodel
            ip: globalSettings.serverIP
            port: globalSettings.serverPort
            password: globalSettings.serverPassword
            onModelReady: { combobox.model=model; updateElementModel()}
        }
        ListModel {
            id: filteredmodel
        }

        Rectangle {
            id: plusrect
            width: height
            height: combobox.height
            anchors.verticalCenter: parent.verticalCenter
            Image {
                id: plus
                anchors.centerIn: parent
                width: parent.height*0.8
                height: width
                sourceSize.height: width
                sourceSize.width: width
                MouseArea {
                    id: plusma
                    anchors.fill: parent
                    onClicked: {
                        forceActiveFocus()
                        if (combobox.currentText!=="")
                            addElement(combobox.currentText)
                    }
                }
            }
        }
    }
    function addElement(elem){
        if (!hasElement(elem) && groupExists(elem))
            listmodel.append({ "text" : elem, "color": randomColor(), "unknown": false})
        combobox.currentIndex=-1;
    }

    function randomColor(){
        var r=Math.floor(Math.random() * (150)+106);
        var g=Math.floor(Math.random() * (150)+106);
        var b=Math.floor(Math.random() * (150)+106);
        var c='#' + r.toString(16) + g.toString(16) + b.toString(16);
        //console.log(c);
        return c;
    }

    function hasElement(str)
    {
        for (var i=0; i<listmodel.count; i++)
            if (listmodel.get(i)["text"]===str)
                return true;
        return false;
    }

    function groupExists(name){
        for (var i=0; i<searchmodel.model.count; i++)
            if (searchmodel.model.get(i)["text"]===name)
                return true;
        return false;
    }

    property alias errorText: errorlabel.text
    Label   {
        id: errorlabel
        font.pixelSize: label.font.pixelSize/1.5
        anchors.horizontalCenter: parent.horizontalCenter
        color: "red"
        visible: false
        Timer {
            id: errorTimer
            interval: 2000; running: false; repeat: false
            onTriggered: parent.visible=false
        }
        onVisibleChanged: visible ? errorTimer.start() :{}
    }
    property alias listText: listlabel.text
    Label   {
        id: listlabel
        font.pixelSize: label.font.pixelSize
        leftPadding: 10
        visible: listmodel.count>0
    }
    //    Rectangle {
    //         id: screen
    //         property int pixelSize: screen.height * 1.25
    //         property color textColor: "#ee9797"
    //         property string text: "www.QML.ucoz.com     "
    //         width: parent.width/3; height: 40
    //         color: "steelblue"
    //         Row {
    //             y: -screen.height / 13.5
    //             width: parent.width
    //             NumberAnimation on x { from: 0; to: -text.width ; duration: 10000; loops: Animation.Infinite }
    //             Text { id: text;font.pixelSize: pixelSize; color: screen.textColor; text: screen.text }
    //             Text { color: screen.textColor; font.pixelSize: pixelSize; text: screen.text ;styleColor: "#ee1818" }
    //             Text { font.pixelSize: pixelSize;color: screen.textColor; text: screen.text }
    //         }
    //     }
    Rectangle {
        id: elementsRect
        width: parent.width
        height: visible ? view.cellHeight*Math.ceil(listmodel.count/Math.floor(view.width/view.cellWidth)) : 0
        visible: listlabel.visible

        ListModel {
            id: listmodel
        }

        GridView {
            id: view
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            cellHeight: label.height*2
            cellWidth: label.font.pixelSize*column.elementScaling
            model: listmodel
            clip: true
            highlightFollowsCurrentItem: false

            interactive: false

            //                highlight: Rectangle {
            //                    color: "skyblue"
            //                }

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
                        id: delegatetext
                        height: parent.height
                        anchors.left: parent.left
                        anchors.right: closerect.left
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        font.pixelSize: label.font.pixelSize
                        leftPadding: height/5
                        //renderType: Text.NativeRendering
                        //wrapMode: Text.Wrap
                        //contentWidth: width
                        text: model.text
                        MouseArea {
                            id: delegatema
                            anchors.fill: parent
                            onClicked: {
                                //view.currentIndex = model.index
                                elementClicked(model.index, model.text);
                            }
                        }
                    }
                    Rectangle {
                        id: closerect
                        height: 3*parent.height/4
                        width: height
                        color: "transparent"
                        opacity: 0.5
                        anchors.rightMargin: parent.height/8
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true
                        radius: width/2
                        Image {
                            id: closeimg
                            source: "../../images/close.png"
                            visible: true
                            width: parent.width*0.6
                            height: width
                            sourceSize.height: width
                            sourceSize.width: width
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            id: closema
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: closerect.color="white"
                            onExited: closerect.color="transparent"
                            onClicked:{console.log("press"); listmodel.remove(model.index)}
                        }
                    }
                }
            }
        }
    }
    function updateElementModel()
    {
        //обновление элементов
        for (var i=0;i<listmodel.count; i++)
        {
            var contains = false
            for (var j=0;j<searchmodel.model.count; j++)
            {
                if (searchmodel.model.get(j)["text"]===listmodel.get(i)["text"])
                    contains=true;
            }
            if (!contains)
                elementmodel.remove(i--)
        }
    }
}



