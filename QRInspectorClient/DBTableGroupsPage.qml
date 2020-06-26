import QtQuick 2.12
import QtQuick.Controls 2.12
import MyExtentions 1.0

import "./qml/myTemplates" as My
import "DBProfilesOpener.js" as Open

Page {
    title: "Groups Table"
    id: page
    visible: true
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            stackView.pop();
            event.accepted = true;
        }
    }
    function update(){ mysqlview.update() }

    My.SettingsHeader {
        id: msh
        headertext: qsTr("Groups table")+mytrans.emptyString
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
        //headercolor: "gray"


        ip: globalSettings.serverIP
        port: globalSettings.serverPort
        password: globalSettings.serverPassword
        dbpassword: globalSettings.dbPassword
        request: "select * from groupnames"
        //onTableFillCompleted: mysqlview.resizeColumnsToContents()
        onRowDoubleClicked: Open.groupProfile(page, { "profileid": name,
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
