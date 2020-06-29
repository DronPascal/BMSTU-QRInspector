import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.15

Page {
    id: page
    title: "Profile Camera Page"
    visible: true
    property bool firsttime: true

    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            stackView.pop();
            event.accepted = true;
        }
    }

    Rectangle {
        id: bgRect
        color: "gray"
        anchors.fill: videoOutput
    }

    Camera
    {
        property string prev: ""
        property string saved: ""
        id: camera
        position: Camera.BackFace
        focus {
            focusMode: CameraFocus.FocusContinuous
            focusPointMode: CameraFocus.FocusPointAuto
        }
        //viewfinder.resolution: Qt.size(400, 400)

        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceAuto

        exposure {
            exposureCompensation: -1.0
            exposureMode: Camera.ExposurePortrait
        }

        flash.mode: Camera.FlashRedEyeReduction
        captureMode: Camera.CaptureStillImage
        imageCapture {
            onImageCaptured: {
                photoPreview.source = preview  // Show the preview in an Imag
                //photopreview =preview
                photoPreview.update()
                camera.prev= preview
            }
            onImageSaved: {
                console.log("saved = "+path)
                camera.saved=path
            }
        }

    }


    VideoOutput
    {
        id: videoOutput
        source: camera
        anchors.fill: parent
        autoOrientation: true
        fillMode: VideoOutput.PreserveAspectCrop
        MouseArea {
            anchors.fill: parent
            onClicked: {
                photoPreview.visible=false
                camera.focus.customFocusPoint = Qt.point(mouse.x / width,  mouse.y / height);
                camera.focus.focusMode = CameraFocus.FocusMacro;
                camera.focus.focusPointMode = CameraFocus.FocusPointCustom;
            }
        }
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)
            height: width
            color: "yellow"
            opacity: 0.2
        }
    }

    Text {
        id: choosetext
        text: qsTr("Click to select")+mytrans.emptyString
        color: "mediumpurple"
        anchors.topMargin: photoPreview.width/40
        z: 11
        anchors.top: photoPreview.top
        anchors.horizontalCenter: photoPreview.horizontalCenter
        visible: photoPreview.visible
        font.pixelSize: photoPreview.width/text.length*1.5
    }
    Image {
        id: photoPreview
        visible: false
        z:10
        cache: false
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)*0.7
        height: width

        fillMode: Image.PreserveAspectCrop
        smooth: true
        onSourceChanged: visible=true
//        Image {
//            id: acceptphoto
//            visible: parent.visible
//            source: "../images/accept_light.png"
//            anchors.bottom: parent.bottom
//            anchors.bottomMargin: 5
//            anchors.horizontalCenter: parent.horizontalCenter
//            width: shotbutton.width
//            height: width
//            sourceSize.width: width
//            sourceSize.height: width

//        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                photopreview =camera.prev
                photosave = camera.saved
                page.firsttime=true
                stackView.pop()
            }
        }
        Rectangle {
            visible: parent.visible
            anchors.fill: parent
            color: "transparent"
            border {
                color: "white"
                width: 3
            }
        }
    }

    Rectangle {
        id: shotbutton
        height: photoPreview.width/3
        width: height
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        radius: width/2
        color: "#feffee"
        opacity: 0.5
        //anchors.bottomMargin: (parent.height-videoOutput.height)/4+height/2
        anchors.horizontalCenter: parent.horizontalCenter
        Image {
            id: shotimg
            source: "../images/make_photo.png"
            anchors.centerIn: parent
            width: parent.width*0.5
            height: width
            sourceSize.width: width
            sourceSize.height: width
        }
        MouseArea {
            anchors.fill: parent
            onClicked:  {
                console.log("capture")
                camera.imageCapture.capture()
//                if (page.firsttime)
//                {
//                    camera.imageCapture.capture()
//                    page.firsttime=false
//                }
            }
        }
    }
}
