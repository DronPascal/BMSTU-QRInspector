import QtQuick 2.12
import QtQuick.Controls 2.12
import MyExtentions 1.0

Item {
    id: mysqltableview
    property alias model: model
    property alias request: mysqltableview.request
    property string request: ""

    property alias ip: sqlhandler.ip
    property alias port: sqlhandler.port
    property alias password: sqlhandler.password
    property alias dbpassword: sqlhandler.dbpassword

    signal modelReady()
    function update(){
        sqlhandler.sendGetQuery(request);
    }

    MySQLiteHandler {
        id: sqlhandler
        onModelChanged: {
            uploadToModel(data);
        }
        Component.onCompleted: sendGetQuery(request);
    }

    function uploadToModel(data)
    {
        if (data.indexOf("|||")!==-1)
        {
            var dataList = data.split("|||");
            var rowsList;
            if (dataList[1].indexOf("||")!==-1)
            {
                rowsList = dataList[1].split("||");
                for (var j=0; j<rowsList.length; j++)
                {
                    var row  = rowsList[j];
                    model.append({"text":row});
                }
            }
            else
                model.append({"text":dataList[1]});
        }
        modelReady();
    }
    //onRequestChanged: sqlhandler.sendGetQuery(request);

    ListModel {
        id: model
    }
}
