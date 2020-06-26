import QtQuick 2.12

Rectangle {
    property int itemAngle: 60
    property int itemSize: width/4


    ListModel {
        id: dataModel

        ListElement {
            color: "orange"
            text: "first"
        }
        ListElement {
            color: "lightgreen"
            text: "second"
        }
        ListElement {
            color: "orchid"
            text: "third"
        }
        ListElement {
            color: "tomato"
            text: "fourth"
        }
        ListElement {
            color: "skyblue"
            text: "fifth"
        }
        ListElement {
            color: "hotpink"
            text: "sixth"
        }
        ListElement {
            color: "darkseagreen"
            text: "seventh"
        }
    }

    PathView {
        id: view

        anchors.fill: parent
        model: dataModel
        pathItemCount:8

        path: Path {
            startX: 0
            startY: height / 2

            PathPercent { value: 0.0 }
            PathAttribute { name: "z"; value: 0 }
            PathAttribute { name: "angle"; value: itemAngle }
            PathAttribute { name: "origin"; value: 0 }
            PathLine {
                x: (view.width - itemSize) / 2
                y: view.height / 2
            }
            PathAttribute { name: "angle"; value: itemAngle }
            PathAttribute { name: "origin"; value: 0 }
            PathPercent { value: 0.49 }
            PathAttribute { name: "z"; value: 10 }


            PathLine { relativeX: 0; relativeY: 0 }

            PathAttribute { name: "angle"; value: 0 }
            PathLine {
                x: (view.width - itemSize) / 2 + itemSize
                y: view.height / 2
            }
            PathAttribute { name: "angle"; value: 0 }
            PathPercent { value: 0.51 }

            PathLine { relativeX: 0; relativeY: 0 }

            PathAttribute { name: "z"; value: 10 }
            PathAttribute { name: "angle"; value: -itemAngle }
            PathAttribute { name: "origin"; value: itemSize }
            PathLine {
                x: view.width
                y: view.height / 2
            }
            PathPercent { value: 1 }
            PathAttribute { name: "z"; value: 0 }
            PathAttribute { name: "angle"; value: -itemAngle }
            PathAttribute { name: "origin"; value: itemSize }
        }
        delegate: Rectangle {
            property real rotationAngle: PathView.angle
            property real rotationOrigin: PathView.origin

            width: itemSize
            height: width
            z: PathView.z
            color: model.color
            border {
                color: "black"
                width: 1
            }
            transform: Rotation {
                axis { x: 0; y: 1; z: 0 }
                angle: rotationAngle
                origin.x: rotationOrigin
            }

            Text {
                anchors.centerIn: parent
                font.pointSize: 32
                text: model.text
            }
        }
    }
}
