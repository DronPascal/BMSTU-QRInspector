import QtQuick 2.12
import QtQuick.Controls 2.12

Popup {
    id: item
    width: parent.width*0.8//parent.height < parent.width ? height*0.7 : parent.width*0.8
    height: parent.height*0.7//Math.min(parent.height,parent.width)*0.7
    anchors.centerIn: parent
    padding: 1
    //visible: item.parent.parent.currentItem!=="DBAddMemberPage.qml"
    SettingsHeader {
        id: msh
        anchors.top: parent.top
        fontsize: item.fontsize
        headertext: qsTr("Profile #")+mytrans.emptyString+item.infoRow[0]
        backSource: "../../images/close_black.png"
        onBackClicked: close();
        acceptSource: "../../images/edit.png"
        onAcceptClicked: {
            close();
            item.parent.parent.push("../../DBAddMemberPage.qml",{"editMember":infoRow[4]})
        }
    }
    Flickable {
        anchors {
            top: msh.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentWidth: parent.width
        contentHeight: 4*lbl1.height+groupsrect.height+eventsrect.height+img.height+column.spacing*3
        clip: true
        //boundsBehavior: Flickable.StopAtBounds

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: msh.bottom
            spacing: item.height/50
            topPadding: 10
        }
    }
}
