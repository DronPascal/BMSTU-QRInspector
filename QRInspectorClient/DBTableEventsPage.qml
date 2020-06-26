import QtQuick 2.12
import QtQuick.Controls 2.12
import MyExtentions 1.0

import "./qml/myTemplates" as My
import "DBProfilesOpener.js" as Open

Page {
    title: "Events Table"
    id: page
    visible: true
    function sv(){console.log(stackView);return stackView;}
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            stackView.pop();
            event.accepted = true;
        }
    }
    function update(){ mysqlview.update() }

    My.SettingsHeader {
        id: msh
        headertext: qsTr("Events table")+mytrans.emptyString
        fontsize: fontSize
        backSource: "../images/back_bold.png"
        onBackClicked: stackView.pop();
        acceptSource: "../images/filter.png"
        onAcceptClicked: {
            if (mysqlview.model.count!==0)
            {
                filterpopup.model=mysqlview.fieldNames
                filterpopup.open()
            }
        }
    }
    My.SQLTableView {
        id:mysqlview
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height-msh.height

        fontsize: fontSize

        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        dbpassword: globalSettings.dbPassword
        request: "select * from events"
        //onTableFillCompleted: mysqlview.resizeColumnsToContents()
        onRowDoubleClicked: Open.eventProfile(page, { "profileid": name,
                                                  "ip": globalSettings.serverIP,
                                                  "port": globalSettings.serverPort,
                                                  "password": globalSettings.serverPassword,
                                                  "dbpassword": globalSettings.dbPassword})
    }
    My.DBTableFilterPopup {
        id: filterpopup
        parent: mysqlview
        fontsize: fontSize

    }
}
