import QtQuick 2.12
import QtQuick.Controls 2.12

Page {
    title: "Start Page"
    id: page
    visible: true
    Rectangle {
        id: clientRect
        height: parent.height/2
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
        }
        color: "lightsteelblue"
        Text {
            anchors.centerIn: parent
            text: qsTr("Inspector")+mytrans.emptyString
            opacity: parent.opacity
            font.pixelSize: window.height/10
            font.bold: true
        }
        MouseArea {
            hoverEnabled: true
            anchors.fill: parent
            onEntered: {
                serverAnimation.from=1;
                serverAnimation.to=0.2;
                serverAnimation.start();
            }
            onExited: {
                serverAnimation.stop();
                serverAnimation.from=serverRect.opacity;
                serverAnimation.to=1;
                serverAnimation.start();
            }
            onPressed: {
                selectedAnimation.stop();
                selectedAnimation.from = clientRect.height;
                selectedAnimation.to = window.height;

                selectedAnimation.target=clientRect;
                selectedAnimation.target.z=serverRect.z+1;
                selectedAnimation.start();
                holdTimer.start();
            }
            onReleased: {
                holdTimer.stop();
                selectedAnimation.stop();
                selectedAnimation.to = window.height/2;
                selectedAnimation.start();
            }
        }
    }

    Rectangle {
        id: serverRect
        height: parent.height/2
        anchors{
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        color: "lightpink"
        Text {
            anchors.centerIn: parent
            text: qsTr("Admin")+mytrans.emptyString
            opacity: parent.opacity
            font.pixelSize: window.height/10
            font.bold: true
        }
        MouseArea {
            hoverEnabled: true
            anchors.fill: parent
            onEntered: {
                clientAnimation.from=1;
                clientAnimation.to=0.2;
                clientAnimation.start();
            }
            onExited: {
                clientAnimation.stop();
                clientAnimation.from=clientRect.opacity;
                clientAnimation.to=1;
                clientAnimation.start();
            }
            onPressed: {
                selectedAnimation.stop();
                selectedAnimation.from = serverRect.height;
                selectedAnimation.to = window.height;

                selectedAnimation.target=serverRect;
                selectedAnimation.target.z=clientRect.z+1;
                selectedAnimation.start();
                holdTimer.start();
            }
            onReleased: {
                holdTimer.stop();
                selectedAnimation.stop();
                selectedAnimation.to = window.height/2;
                selectedAnimation.start();
            }
        }

        PropertyAnimation {
            id: clientAnimation
            target: clientRect
            properties: "opacity"
            from:1
            to: 0.2
            duration: 200
            running: false
        }
        PropertyAnimation {
            id: serverAnimation
            target: serverRect
            properties: "opacity"
            from:1
            to: 0.2
            duration: 200
            running: false
        }
        PropertyAnimation {
            id: selectedAnimation

            target: clientRect
            easing.type: Easing.OutBack
            properties: "height"
            from: target.height
            to: window.height
            duration: 700
            running: false
        }
        Timer {
            id: holdTimer
            interval: selectedAnimation.duration; running: false; repeat: false
            onTriggered: {
                let pg = (selectedAnimation.target==serverRect) ? "AdminSettingsPage.qml" : "ViewerPage.qml";
                console.log(pg);
                stackView.replace("StartPage.qml",pg);
                initSettings.initItem = pg;
                console.log(initSettings.initialItem);
            }
        }
    }
}
