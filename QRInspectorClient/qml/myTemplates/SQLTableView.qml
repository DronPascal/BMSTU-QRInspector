import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4 as C
import QtGraphicalEffects 1.12

import MyExtentions 1.0


Item {
    id: sqlview
    property alias sqlhandler: sqlhandler
    property alias ip: sqlhandler.ip
    property alias port: sqlhandler.port
    property alias password: sqlhandler.password
    property alias dbpassword: sqlhandler.dbpassword
    property alias model: tablemodel

    property alias request: sqlview.request
    property string request: ""
    property alias fontsize: sqlview.fontsize
    property int fontsize: 10

    property alias headercolor: sqlview.headercolor
    property color headercolor: "mediumaquamarine"
    property alias separatorcolor: sqlview.separatorcolor
    property color separatorcolor: "white"

    signal tableFillCompleted()
    signal rowDoubleClicked(string memberid, string name)
    signal someColumnWidthChanged(int index, int colwidth)
    signal sqlErrorFounded(string sqlerror)

    property int headerWidth: 0
    property var headersWidth: []
    property alias fieldNames: sqlview.fieldNames
    property var fieldNames: []

    property bool headerReady: false

    function update()
    {
        tablemodel.clear()
        sqlhandler.sendGetQuery(sqlview.request)
    }
    Label {
        anchors.centerIn: parent
        visible: tablemodel.count===0
        font.pixelSize: fontsize
        text: "The table is empty"
    }

    MySQLiteHandler {
        id: sqlhandler
        onSqlErrorFounded: {}
        onModelChanged: {
            if (data.indexOf("ERROR: ")!==-1)
            {
                console.log("sending error")
                sqlview.sqlErrorFounded(data)
            }
            uploadToTable(data)
        }
        Component.onCompleted: sqlview.request!=="" ? sendGetQuery(sqlview.request) : {}
    }

    function uploadToTable(data)
    {
        var midLength=[]
        var dataList = data.split("|||");
        var roleNames = dataList[0].split("|");
        mysqlview.headerList=roleNames;

        for(var i=0; i<roleNames.length; i++)
        {
            sqlview.fieldNames[i]=roleNames[i]
            midLength[i]=roleNames[i].length
            sqlview.headersWidth[i]=0
        }
        if (data.indexOf("|||")!==-1 && dataList[1]!=="")
        {
            var rowsList = dataList[1].split("||");
            for (i=0; i<rowsList.length; i++)
            {
                var rowList = rowsList[i].split("|");
                var row_obj={};

                for (var j=0; j<roleNames.length; j++)
                {
                    row_obj[roleNames[j]] = rowList[j];

                    midLength[j]=(midLength[j]+rowList[j].length)/2
                }
                //console.log(midLength[0])
                tablemodel.append(row_obj);
            }
        }
        if (!mysqlview.headerReady)
        {
            for( i=0; i<roleNames.length; i++)
            {
                var role  = roleNames[i];
                tableview.addColumn(columnComponent.createObject(tableview,
                                                                 { "role": role,
                                                                     "title": role,
                                                                     "midlength": Math.max(midLength[i], roleNames[i].length),
                                                                     "colnumber" : i}))
            }
            mysqlview.headerReady=true
        }
        tableFillCompleted()
    }

    Component
    {
        id: columnComponent
        C.TableViewColumn{
            property int midlength: 0
            property int colnumber: 0
            Binding on width{
                target: parent
                value: midlength*fontsize/1.5
            }
            Component.onCompleted: {
                sqlview.headersWidth[colnumber]=width;
                headerWidth+=midlength
            }
            onWidthChanged: someColumnWidthChanged(colnumber, width)

        }
    }
    onWidthChanged: someColumnWidthChanged(0, sqlview.headersWidth[0])

    onSomeColumnWidthChanged: {
        let hwidth=0;
        sqlview.headersWidth[index]=colwidth
        for (var i=0; i<sqlview.headersWidth.length; i++)
        {
            //console.log(sqlview.headersWidth[i])
            hwidth+=sqlview.headersWidth[i]

        }
        if (hwidth>parent.width)
            hflick.contentWidth = hwidth+parent.width/2;
        else
            hflick.contentWidth=parent.width
    }

    Flickable {
        id: hflick
        anchors.fill: parent
        //contentWidth: tableview.contentHeader
        //tableview.contentWidth
        contentHeight: parent.height
        flickableDirection: Flickable.HorizontalFlick
        boundsMovement: Flickable.StopAtBounds
        //boundsBehavior: Flickable.DragAndOvershootBounds
        clip: true

        //ScrollBar.horizontal: ScrollBar {height: parent.height/30 }
        //onContentWidthChanged: console.log(contentWidth)
        C.TableView {
            id: tableview
            //property int currentrow: -1
            anchors.fill: parent
            //columnWidthProvider:0
            model: tablemodel


            itemDelegate: Rectangle {
                id: itemd
                height: 20
                color: styleData.row===tableview.currentRow ? "lightcyan" : styleData.row%2==0 ? "#efefef" : "white"
                //width: styleData.value.length*height
                Text {
                    id: dtext
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: styleData.value
                    font.pixelSize: sqlview.fontsize
                    elide: Text.ElideRight
                }
                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        console.log("Row doubleclicked");
                        tableview.currentRow=styleData.row
                        rowDoubleClicked(tablemodel.get(styleData.row)["memberid"], tablemodel.get(styleData.row)["name"])
                    }
                    //console.log("Item ("+styleData.value+") clicked "+ styleData.row + " "+ styleData.column+" "+styleData.header+ "   "+JSON.stringify(styleData))
                    onClicked: tableview.currentRow!==styleData.row ? tableview.currentRow=styleData.row : tableview.currentRow=-1

                }
            }

            headerDelegate: Rectangle {
                id: headerd
                //width: styleData.value.length*height
                clip: true
                height: sqlview.fontsize*2
                color: sqlview.headercolor
                Rectangle {
                    anchors.left: parent.left
                    width: height/12
                    height: parent.height
                    visible: styleData.column!==0
                    anchors.verticalCenter: parent.verticalCenter
                    LinearGradient {
                        anchors.fill: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(width, 0)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: sqlview.separatorcolor}
                            GradientStop { position: 1.0; color: sqlview.headercolor  }
                        }
                    }
                }
                Rectangle {
                    anchors.right: parent.right
                    width: height/12
                    height: parent.height
                    //visible: styleData.column!==tableview.columnCount-1
                    anchors.verticalCenter: parent.verticalCenter
                    LinearGradient {
                        anchors.fill: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(width, 0)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: sqlview.headercolor }
                            GradientStop { position: 1.0; color: sqlview.separatorcolor }
                        }
                    }
                }

                Text {
                    text: styleData.value
                    color: "#FFF"
                    width: parent.width
                    height: parent.height
                    font.pixelSize: sqlview.fontsize
                    //fontSizeMode: Text.Fit
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    //                    onDoubleClicked: console.log("Item ("+styleData.value+") clicked "+ styleData.column)
                    //                    acceptedButtons: Qt.LeftButton
                    onDoubleClicked: console.log("Header doubleclicked");
                }
                //                onWidthChanged:{

                //                    sqlview.headerWidth+=width
                //                    console.log("Header width= "+sqlview.headerWidth)
                //                }
            }

            rowDelegate: Rectangle {
                id: rowd
                height: sqlview.fontsize*2
                width: parent.width
                color: styleData.row===tableview.currentRow ? "lightcyan" : styleData.row%2==0 ? "#efefef" : "white"
                clip: true
                MouseArea {
                    id: maRow
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: {
                        console.log("right click on row "+styleData.row)
                        sortModelTextFields("name","FdG", 0, 1, 0, 1)

                    }
                }
            }
            //TableViewColumn { role: "Value" ; title: "Value" }
        }
    }

    ListModel {
        id: tablemodel
    }
    Component.onCompleted: {
        for (var i=0; i<tableview.columnCount; i++)
            console.log(tableview.getColumn(i).width)
        //tableview.sortIndicatorVisible=true
    }

    property  var headerList:[];
    function sortModelTextFields(field, sample, match, casesensitive, ascending, decrease)
    {
        if (field!=="") //фильтруем
        {
            if (sample!=="")
            {
                for (var i=0; i<tablemodel.count; i++)
                {
                    if (match)
                        if (casesensitive)
                        {
                            if (sqlview.model.get(i)[field]!==sample)
                                sqlview.model.remove(i--)
                        }
                        else
                        {
                            if (sqlview.model.get(i)[field].toLowerCase()!==sample.toLowerCase())
                                sqlview.model.remove(i--)
                        }
                    else
                        if (casesensitive)
                        {
                            if (tablemodel.get(i)[field].indexOf(sample)===-1 )
                                sqlview.model.remove(i--)
                        }
                        else
                        {
                            if (tablemodel.get(i)[field].toLowerCase().indexOf(sample.toLowerCase())===-1 )
                                sqlview.model.remove(i--)
                        }
                }
            }
        }
        if (ascending) //сортируем
        {
            for (i=0; i<sqlview.model.count;i++)
            {
                var min=i
                for (var j=i; j<sqlview.model.count; j++)
                    if (sqlview.model.get(j)[field].toLowerCase() < sqlview.model.get(min)[field].toLowerCase())
                        min=j;
                if (min!==i)
                    sqlview.model.move(min, i, 1)
            }
        }
        if (decrease)
        {
            for (i=0; i<sqlview.model.count;i++)
            {
                var max=i
                for (j=i; j<sqlview.model.count; j++)
                    if (sqlview.model.get(j)[field].toLowerCase() > sqlview.model.get(max)[field].toLowerCase())
                        max=j;
                if (max!==i)
                    sqlview.model.move(max, i, 1)
            }
        }
    }

    function sortModelDateFields(field, after, before, ascending, decrease)
    {
        if (after!=="" || before!=="")
        {
            var afterdate = Date.fromLocaleString(Qt.locale(), after, "dd.MM.yyyy")
            var beforedate = Date.fromLocaleString(Qt.locale(), before, "dd.MM.yyyy")
            for (var i=0; i<sqlview.model.count;i++)
            {
                if (sqlview.model.get(i)[field]!==" ")
                {
                    var indexdate = Date.fromLocaleString(Qt.locale(), sqlview.model.get(i)[field], "dd.MM.yyyy")
                    console.log(afterdate+" "+indexdate+" "+beforedate)
                    if (after!=="" && indexdate<afterdate )
                        sqlview.model.remove(i--)
                    else if (before!=="" && indexdate>beforedate )
                        sqlview.model.remove(i--)
                }
                else
                    sqlview.model.remove(i--)
            }
        }
        if (ascending) //сортируем
        {
            for (i=0; i<sqlview.model.count;i++)
            {
                if (sqlview.model.get(i)[field]!==" ")
                {
                    var min=i
                    indexdate = Date.fromLocaleString(Qt.locale(), sqlview.model.get(i)[field], "dd.MM.yyyy")
                    for (var j=i; j<sqlview.model.count; j++)
                    {
                        if (sqlview.model.get(j)[field]!==" ")
                        {
                            var curdate = Date.fromLocaleString(Qt.locale(), sqlview.model.get(j)[field], "dd.MM.yyyy")
                            console.log(curdate)
                            if (curdate < indexdate)
                            {
                                min=j;
                                indexdate = curdate
                            }
                        }
                    }
                    if (min!==i)
                        sqlview.model.move(min, i, 1)
                }
                else
                    sqlview.model.remove(i--)
            }
        }
        if (decrease)
        {
            for (i=0; i<sqlview.model.count;i++)
            {
                if (sqlview.model.get(i)[field]!==" ")
                {
                    var max=i
                    indexdate = Date.fromLocaleString(Qt.locale(), sqlview.model.get(i)[field], "dd.MM.yyyy")
                    for (j=i; j<sqlview.model.count; j++)
                    {
                        if (sqlview.model.get(j)[field]!==" ")
                        {
                            curdate = Date.fromLocaleString(Qt.locale(), sqlview.model.get(j)[field], "dd.MM.yyyy")
                            if (curdate > indexdate)
                            {
                                max=j;
                                indexdate = curdate
                            }
                        }
                    }
                    if (max!==i)
                        sqlview.model.move(max, i, 1)
                }
                else
                    sqlview.model.remove(i--)
            }
        }
    }

    function sortModelTimeFields(field, after, before, ascending, decrease)
    {
        if (after!=="" || before!=="")
        {
            var aftertime = Date.fromLocaleString(Qt.locale(), after, "hh.mm")
            var beforetime = Date.fromLocaleString(Qt.locale(), before, "hh.mm")
            for (var i=0; i<sqlview.model.count;i++)
            {
                var itimestr = sqlview.model.get(i)[field].split(":")[0]+":"+sqlview.model.get(i)[field].split(":")[1]
                var indextime = Date.fromLocaleString(Qt.locale(), itimestr, "hh:mm")
                console.log(aftertime+" "+indextime+" "+beforetime)
                if (after!=="" && indextime<aftertime )
                    sqlview.model.remove(i--)
                else if (before!=="" && indextime>beforetime )
                    sqlview.model.remove(i--)
            }
        }
        if (ascending) //сортируем
        {
            for (i=0; i<sqlview.model.count;i++)
            {
                var min=i
                for (var j=i; j<sqlview.model.count; j++)
                    if (sqlview.model.get(j)[field].toLowerCase() < sqlview.model.get(min)[field].toLowerCase())
                        min=j;
                if (min!==i)
                    sqlview.model.move(min, i, 1)
            }
        }
        if (decrease)
        {
            for (i=0; i<sqlview.model.count;i++)
            {
                var max=i
                for (j=i; j<sqlview.model.count; j++)
                    if (sqlview.model.get(j)[field].toLowerCase() > sqlview.model.get(max)[field].toLowerCase())
                        max=j;
                if (max!==i)
                    sqlview.model.move(max, i, 1)
            }
        }
    }
}













