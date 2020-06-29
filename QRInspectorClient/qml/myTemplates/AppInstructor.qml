import QtQuick 2.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.0
import QtQuick.Layouts 1.12
import MyLang 1.0


Item {
    id: item
    property alias fontsize: item.fontsize
    property int fontsize: 10
    property string curpage: ""

    Settings {
        id: guidesettings
        property int startpage: 0

        property int viewpage: 0
        property int clientsettingspage: 0

        property int adminsettingspage: 0
        property int dbsettingspage: 0

        property int dbaddmemberpage: 0
        property int dbaddgrouppage: 0
        property int dbaddeventpage: 0

        property int dbtablememberpage: 0
        property int dbtablegrouppage: 0
        property int dbtableeventpage: 0
        property int dbtablevisitspage: 0

        property int dbsudosettingspage: 0
    }
    function reset() {
        guidesettings.startpage=0
        guidesettings.viewpage=0
        guidesettings.clientsettingspage=0
        guidesettings.adminsettingspage=0

        guidesettings.dbsettingspage=0
        guidesettings.dbaddmemberpage=0
        guidesettings.dbaddgrouppage=0
        guidesettings.dbaddeventpage=0

        guidesettings.dbtablememberpage=0
        guidesettings.dbtablegrouppage=0
        guidesettings.dbtableeventpage=0
        guidesettings.dbtablevisitspage=0

        guidesettings.dbsudosettingspage=0
        row.visible=true
    }
    function registerGuide(page) {
        if (page==="Start Page") guidesettings.startpage=1
        else if (page==="Viewer Page") guidesettings.viewpage=1
        else if (page==="Client settings") guidesettings.clientsettingspage=1
        else if (page==="Admin menu") guidesettings.adminsettingspage=1

        else if (page==="Database Settings") guidesettings.dbsettingspage=1
        else if (page==="Add/Edit Member Page") guidesettings.dbaddmemberpage=1
        else if (page==="Add/Edit Group Page") guidesettings.dbaddgrouppage=1
        else if (page==="Add/Edit Event Page") guidesettings.dbaddeventpage=1

        else if (page==="Members Table") guidesettings.dbtablememberpage=1
        else if (page==="Groups Table") guidesettings.dbtablegrouppage=1
        else if (page==="Events Table") guidesettings.dbtableeventpage=1
        else if (page==="Visits Table") guidesettings.dbtablevisitspage=1

        else if (page==="Superuser menu") guidesettings.dbsudosettingspage=1
    }

    function pageGuide(page){
        console.log(page)
        item.curpage=page
        if (page==="Start Page" && guidesettings.startpage===0) {
            label.text=qsTr("It is strongly recommended that you <b>read this</b> comprehensive guide, which describes all the features of the presented product and the steps to configure it.<br/><br/>
The application was developed and released by students of the BMSTU FN11 faculty: Pascal A.P., Shibanov A.O., Kadiev A. Lecturer - Gumirgaliev T.R.<br/><br/>
This client-server application is a working solution for recording visits to \"events\" by company members using QR codes for identification. By \"events\" we mean meetings, classes, and any other kind of meeting, timed to a specific place and time. A recognition device must correspond to each such place, for the description of which we have chosen the word \"inspector\" and we will adhere to this definition in further instructions.<br/><br/>
This application allows you to choose one of two roles: Inspector and Administrator.<br/><br/>
-A device with the Inspector role, after setting up and connecting to the QRInspector server application, as described above, will read QR codes that members will display in front of its camera. Only after successful recognition of the QR code and verification on the server, the member will be credited with a visit.<br/><br/>
-A device with the role of \"Administrator\" after connecting to the QRInspector server application, will provide the user with the ability to create and modify profiles of members, groups and events.<br/><br/>
Any authorization and accounting of visits occur through the server application. Therefore, it is important to complete the first step:<br/>
1) Download the QRInspector server application for Linux x64 or Windows x64 / x86, configure and run it. Follow the instructions in the \"readme.txt\" file in the folder of the downloaded application. You can download any version of the server just clicked on <a href='http://www.a.org'>https://drive.google.com/drive/folders/1WliTTdy9TGyL9vs62rT4UmO5bYHCzjID?usp=sharing</a>. This link will open after using the OK button.<br/><br/>
After the server starts successfully, you can proceed to the next step. Click OK and select the role that you would like to know about the features. The order of studying the functionality of the application does not play a big role.")+mytrans.emptyString
            pagedialog.open()
        }
        else if (page==="Viewer Page" && guidesettings.viewpage===0) {
            label.text=qsTr("<b>Inspector's homepage</b><br/>
Only on this page is reading and recognition of qr codes.<br/>
-Now this page will automatically open when the application starts.<br/>
-The frame rate is reduced to reduce energy consumption, this will not significantly affect the recognition speed.<br/><br/>
After closing this window and clicking on the screen, four buttons will appear.<br/>
The first (a button with a bug) is responsible for begging. You can familiarize yourself with its capabilities at the end of this manual.<br/><br/>
The second (gear button) - go to the inspector settings page and connect to the server.<br/><br/>
The third (button with a lock) - blocking the application.<br/>
To block, you must first set a password on the inspector settings page.<br/>
During blocking, you cannot go to another page or change application settings. If you suddenly forget the password, you will have to reinstall the application. To reduce the likelihood that this will happen, the admin menu has a qr code generation button for the complete configuration of the inspector. Just let the inspector recognize the generated qr code, he will do the rest for you.<br/>
The decision whether to use the same password for all inspectors is yours.<br/><br/>
The fourth (camera button) switches the camera position to the opposite. This is the only setting that cannot be set through the inspector configurator in the admin menu.<br/><br/>
It is worthwhile to elaborate on the stages of verification and registration of the member’s visit. After the member has brought the qr code to the inspector’s camera, the latter checks to see if this qr code has already been recognized in the near future. The setting of this option is present on the inspector settings page and defaults to 10 seconds.<br/>
If the qr code of the member passed the initial verification, the inspector sends it to the server along with his ID (the inspector ID means the name of the office, class or any other room in which the event will take place and at the entrance to which the device with the role of “inspector” will be installed) .<br/>
After sending information to the server, the check is performed according to the existing schedule, and if successful, the inspector’s profile photo or a standard avatar for all members is displayed on the inspector’s screen. The input sound is also played if it was set in the inspector's settings.<br/>
The following images may occur instead of a profile photo:<br/>
<img src=\"qrc:/images/wrongpass.png\" width=\"100\" height=\"100\"/><br/>
- the wrong server password is entered in the inspector settings;<br/>
<img src=\"qrc:/images/connecterror.png\" width=\"100\" height=\"100\"/><br/>
- unable to connect to the server (network error);<br/>
<img src=\"qrc:/images/accessdenied.png\" width=\"100\" height=\"100\"/><br/>
- the initial verification failed or the entrance to the event is prohibited (the visit will not be counted).<br/><br/>
That’s all you need to know about the inspector’s main page, you can go to the settings page by clicking the gear button in the upper right corner. Initially, it is transparent.<br/><br/>
Additional information about debugging mode:<br/>
If you click on the button with the bug, then in the center of the screen a field will be displayed with information about the number of read codes that have passed the initial test, as well as the tag of the last of them.<br/>
A console appears at the bottom of the screen that supports several commands that were used during development, but you most likely will not need it.<br/>
1) [reset] - entering this command only resets the language, guide and start page settings. It simulates the first opening of the application without overwriting the settings of the inspector and admin.<br/>
2) [close] - closes the console, you can open it again only through the button with the bug.<br/>
3) [ping] - checks the connection to the server.<br/>
4) [QR_code|Inspector_ID, new visit] - simulates sending qr code to the server on behalf of the specified inspector.<br/>
5) [test] - sends a test request to the server. Gets a picture as an answer. Simulates the display of a photograph of a member and the reproduction of sound upon entry.<br/>")+mytrans.emptyString
            pagedialog.open()
        }
        else if (page==="Client settings" && guidesettings.clientsettingspage===0) {
            label.text=qsTr("<b>Inspector settings page</b><br/>
To successfully connect the inspector to the server, you need to enter the IP, port and password of the server, which you already know if you started the server and followed the instructions in the readme.txt file.<br/>
Recall that to configure the inspector, it is enough to bring the qr code generated by the administrator.<br/><br/>
We list in order what the input fields of the current page are responsible for:<br/>
1) Inspector ID - optionally a unique name for the point where the inspector is located. If two inspectors have the same ID, they will complement each other, as if there were two entrances to the room.<br/>
2) Re-auth delay - The delay between resending a request to add a visit to a member. It is highly undesirable to leave this value very small in order to avoid too often polling the server by inspectors and high load on it.<br/>
3) Client password - password to unlock the inspector. Without it, anyone can change the settings at their discretion.<br/>
4) Server IP - server IP in a local or global network. The easiest way is to configure the server to work on a local network (for example, devices are connected to the same WiFi point).<br/>
You can learn more about setting up a server to access it from the global network on the Internet.<br/>
5) Server port - the port on which the QRInspector server application is running.<br/>
6) Server password - the server password that you specified in the server configuration file before starting.<br/>
7) Entry sound - the sound that will be played after the member has successfully recorded the visit.<br/>
8) Change role - returns to the main screen for subsequent role selection.<br/><br/>
The button next to the server password field allows you to check the connection to the server. Click on it and if it turns green, then the connection has been successfully established and the server is currently available. In the opposite case, an inscription with an error will appear below it.<br/><br/>
Fill in the IP, port and server password fields. Check if the inspector can connect to the server. After that, you can familiarize yourself with the “Administrator” role by clicking on “Change role”.")+mytrans.emptyString
            pagedialog.open()
        }
        else if (page==="Admin menu" && guidesettings.adminsettingspage===0) {
            label.text=qsTr("<b>Admin menu</b><br/>
This page is the admin home page.<br/>
The role of the administrator is to configure inspectors and create profiles of members, groups, and events. But to gain access to these functions, you must first connect to the server. Use the data that you received at the stage of setting up and starting the server.<br/><br/>
-The menu button “Create inspector configuration code” opens a dialog by entering in which the identifier of the inspector to be configured, the application password, the delay for recounting and selecting the input sound, after clicking OK, a QR code will appear on the screen, recognizing which by the inspector, the latter will change its settings.<br/>
- The database settings button opens a menu for working with profiles of members, groups and events.<br/>
-Button to change the role allows you to go to the start page to re-select the role. The entered settings do not disappear.<br/><br/>
Connect to the server and familiarize yourself with the interface for creating configuration codes, and then go to the database setup menu.")+mytrans.emptyString
            pagedialog.open()
        }

        else if (page==="Database Settings" && guidesettings.dbsettingspage===0) {
            label.text=qsTr("This page has four sections:<br/>
1) Adding profiles of members, groups and events.<br/>
2) View tables of existing profiles and edit them.<br/>
3) Statistics. Contains a table with all visits<br/>
4) Superuser. Opens a menu for cleaning and switching between databases.<br/><br/>
To work with the database, the corresponding database access password is required, which you specified in the server configuration file. Enter it and continue to explore the interface in order, starting with adding members.")+mytrans.emptyString
            pagedialog.open()
        }
        else if (page==="Add/Edit Member Page" && guidesettings.dbaddmemberpage===0) {
            label.text=qsTr("<b>Add Member</b><br/>
When adding and editing a member’s profile, the required fields are the first and last name. You can create members with the same name. Each of them will be assigned a unique ID and QR code.<br/>
After creating groups or events, fields will appear in this interface with which you can select groups and events to which you would like to add a member already at the stage of creating his profile.<br/><br/>
Try creating a member profile. After that, go to the group creation page.")+mytrans.emptyString
            pagedialog.open()
        }
        else if (page==="Add/Edit Group Page" && guidesettings.dbaddgrouppage===0) {
            label.text=qsTr("<b>Add Group</b><br/>
When adding and editing a group, the name is required. The name of the group must be unique, otherwise the group will not be created.<br/>
After creating profiles of members or events in this interface, fields will appear with which you can select the members in this group and the events to which groups will be invited<br/><br/>
Try creating a new group. After that, proceed to create the event.")+mytrans.emptyString
            pagedialog.open()
        }
        else if (page==="Add/Edit Event Page" && guidesettings.dbaddeventpage===0) {
            label.text=qsTr("<b>Add Event</b><br/>
When adding and editing an event, the required fields are the name, inspector ID, start time, end time and date or days of the week on which the event will occur. The name of the event must be unique, otherwise the event will not be created.<br/><br/>
When entering date and time values, strictly adhere to the format indicated on the background of the input field.<br/>
You cannot create events whose start time is longer than the end time. It is also impossible to create a one-time event whose date is less than the current one.<br/>
The inspector ID must fully match the one you specified in the settings of the inspector for whom the event is generated, otherwise the visits will not be counted.<br/><br/>
After creating profiles of members or groups in this interface, fields will appear, with which you can select members and groups invited to this event.<br/>
If you invite a group and an individual member of this group to the event, then after deleting the group, the member will have an invitation.<br/><br/>
Try creating a new event. After that, proceed to the section for viewing the created profiles and editing them.")+mytrans.emptyString
            pagedialog.open()
        }

        else if (page==="Members Table" && guidesettings.dbtablememberpage===0) {
            label.text=qsTr("<b>Members Table</b><br/>
This table displays all existing members. To search in the table and filter the search result, click on the button with the funnel in the upper right corner.<br/>
Double-click on the member you are interested in to open his profile. In the window that appears, you can open the profiles of the group in which he is a member and the events to which he is invited. To edit the profile, click on the button with a pencil in the upper right corner.")+mytrans.emptyString
            pagedialog.open()
        }
        else if (page==="Groups Table" && guidesettings.dbtablegrouppage===0) {
            label.text=qsTr("<b>Group table</b><br/>
This table displays all existing groups. To search in the table and filter the search result, click on the button with the funnel in the upper right corner.<br/>
Double-click on a group of interest to open its profile. In the window that appears, you can open the profiles of members in the group and events to which the group is invited. To edit the profile, click on the button with a pencil in the upper right corner.")+mytrans.emptyString
            pagedialog.open()
        }
        else if (page==="Events Table" && guidesettings.dbtableeventpage===0) {
            label.text=qsTr("<b>Event table</b><br/>
This table displays all existing events. To search in the table and filter the search result, click on the button with the funnel in the upper right corner. When entering date and time values, strictly adhere to the format indicated on the background of the input field.<br/>
Double-click on the event you are interested in to open its profile. In the window that appears, you can open profiles of members and groups invited to the event. To edit the profile, click on the button with a pencil in the upper right corner.")+mytrans.emptyString
            pagedialog.open()
        }
        else if (page==="Visits Table" && guidesettings.dbtablevisitspage===0) {
            label.text=qsTr("<b>Visits table</b><br/>
This table displays all registered visits. To search in the table and filter the search result, click on the button with the funnel in the upper right corner. When entering date and time values, strictly adhere to the format indicated on the background of the input field.")+mytrans.emptyString
            pagedialog.open()
        }

        else if (page==="Superuser menu" && guidesettings.dbsudosettingspage===0) {
            label.text=qsTr("<b>Superuser Menu</b><br/>
This menu provides additional opportunities for working with the database.<br/><br/>
- full cleanup of the current database<br/>
- switching between databases<br/>
- disabling the processing of new visits<br/>
- performing any sql database queries<br/><br/>
Enter the superuser password that you specified in the server configuration file to gain access to them.")+mytrans.emptyString
            pagedialog.open()
        }
    }

    Dialog {
        onOpened: flickable.flick(0,100000)
        id: pagedialog
        title: qsTr("Guide")+mytrans.emptyString
        anchors.centerIn: parent
        height: item.height*0.7
        width: item.width*0.8
        font.pixelSize: fontsize
        clip: true
        closePolicy: Popup.NoAutoClose
        modal: Qt.ApplicationModal
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            width: parent.width
            Row {
                id: row
                width: flickable.width
                visible: item.curpage==="Start Page"
                Text {
                    id: langlabel
                    text: "Choose lanuage"
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: fontsize
                    onLinkActivated: Qt.openUrlExternally("https://drive.google.com/drive/folders/1WliTTdy9TGyL9vs62rT4UmO5bYHCzjID?usp=sharing")

                }
                Rectangle {
                    width: 10
                    height: 10
                }

                ComboBox {
                    id: langbox
                    width: pagedialog.width-langlabel.width-accrect.width-40
                    height: langlabel.height*1.5
                    indicator.height: height*0.8
                    indicator.width: height

                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: fontsize
                    clip: true
                    model: ["English", "Russian"]
                    onCurrentValueChanged: {
                        globalSettings.lang=langbox.currentText
                        label.text= qsTr("It is strongly recommended that you <b>read this</b> comprehensive guide, which describes all the features of the presented product and the steps to configure it.<br/><br/>
The application was developed and released by students of the BMSTU FN11 faculty: Pascal A.P., Shibanov A.O., Kadiev A. Lecturer - Gumirgaliev T.R.<br/><br/>
This client-server application is a working solution for recording visits to \"events\" by company members using QR codes for identification. By \"events\" we mean meetings, classes, and any other kind of meeting, timed to a specific place and time. A recognition device must correspond to each such place, for the description of which we have chosen the word \"inspector\" and we will adhere to this definition in further instructions.<br/><br/>
This application allows you to choose one of two roles: Inspector and Administrator.<br/><br/>
-A device with the Inspector role, after setting up and connecting to the QRInspector server application, as described above, will read QR codes that members will display in front of its camera. Only after successful recognition of the QR code and verification on the server, the member will be credited with a visit.<br/><br/>
-A device with the role of \"Administrator\" after connecting to the QRInspector server application, will provide the user with the ability to create and modify profiles of members, groups and events.<br/><br/>
Any authorization and accounting of visits occur through the server application. Therefore, it is important to complete the first step:<br/>
1) Download the QRInspector server application for Linux x64 or Windows x64 / x86, configure and run it. Follow the instructions in the \"readme.txt\" file in the folder of the downloaded application. You can download any version of the server just clicked on <a href='http://www.a.org'>https://drive.google.com/drive/folders/1WliTTdy9TGyL9vs62rT4UmO5bYHCzjID?usp=sharing</a>. This link will open after using the OK button.<br/><br/>
After the server starts successfully, you can proceed to the next step. Click OK and select the role that you would like to know about the features. The order of studying the functionality of the application does not play a big role.")+mytrans.emptyString
                    }
                }
                Rectangle {
                    id: accrect
                    height: langbox.height
                    width:  height
                    color: "#eeeeee"
                    Image {
                        id: acceptimg
                        anchors.centerIn: parent
                        height: parent.height*0.5
                        width: height
                        source: "../../images/accept_black.png"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            globalSettings.lang=langbox.currentText
                            label.text= qsTr("It is strongly recommended that you <b>read this</b> comprehensive guide, which describes all the features of the presented product and the steps to configure it.<br/><br/>
The application was developed and released by students of the BMSTU FN11 faculty: Pascal A.P., Shibanov A.O., Kadiev A. Lecturer - Gumirgaliev T.R.<br/><br/>
This client-server application is a working solution for recording visits to \"events\" by company members using QR codes for identification. By \"events\" we mean meetings, classes, and any other kind of meeting, timed to a specific place and time. A recognition device must correspond to each such place, for the description of which we have chosen the word \"inspector\" and we will adhere to this definition in further instructions.<br/><br/>
This application allows you to choose one of two roles: Inspector and Administrator.<br/><br/>
-A device with the Inspector role, after setting up and connecting to the QRInspector server application, as described above, will read QR codes that members will display in front of its camera. Only after successful recognition of the QR code and verification on the server, the member will be credited with a visit.<br/><br/>
-A device with the role of \"Administrator\" after connecting to the QRInspector server application, will provide the user with the ability to create and modify profiles of members, groups and events.<br/><br/>
Any authorization and accounting of visits occur through the server application. Therefore, it is important to complete the first step:<br/>
1) Download the QRInspector server application for Linux x64 or Windows x64 / x86, configure and run it. Follow the instructions in the \"readme.txt\" file in the folder of the downloaded application. You can download any version of the server just clicked on <a href='http://www.a.org'>https://drive.google.com/drive/folders/1WliTTdy9TGyL9vs62rT4UmO5bYHCzjID?usp=sharing</a>. This link will open after using the OK button.<br/><br/>
After the server starts successfully, you can proceed to the next step. Click OK and select the role that you would like to know about the features. The order of studying the functionality of the application does not play a big role.")+mytrans.emptyString
                        row.visible=false
                        }
                    }
                }
            }

            Flickable {
                id: flickable
                width: parent.width
                height: parent.parent.height-skiprow.height-(langbox.visible ? langbox.height : 0)
                contentHeight: label.height
                contentWidth: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { }
                Text {
                    id: label
                    //                    selectByMouse: false
                    //                    cursorVisible: false
                    //                    cursorDelegate: Rectangle{color: "transparent"}
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    font.pixelSize: fontsize-1
                    wrapMode: Text.Wrap
                }
            }
            Row {
                id: skiprow
                height: skipbox.height
                CheckBox {
                    id: skipbox
                    indicator.width: skiplabel.height
                    indicator.height: skiplabel.height
                }
                Label {
                    id: skiplabel
                    text: qsTr("Skip guide")+mytrans.emptyString
                    font.pixelSize: fontsize
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    id: spacelabel
                    width:pagedialog.width-skipbox.width-skiplabel.width-okbtmn.width-30
                    anchors.verticalCenter: parent.verticalCenter
                }
                Button {
                    id: okbtmn
                    text: "OK"
                    width: 5*fontsize
                    height: skiplabel.height*1.5
                    font.pixelSize: fontsize
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        registerGuide(curpage)
                        if (skipbox.checked)
                            globalSettings.guide = false
                        if (curpage=="Start Page" && !skipbox.checked)
                            Qt.openUrlExternally("https://drive.google.com/drive/folders/1WliTTdy9TGyL9vs62rT4UmO5bYHCzjID?usp=sharing")
                        pagedialog.close()
                    }
                }
            }
        }
        onClosed: {
            if (skipbox.checked)
                globalSettings.guide = false
        }
    }
}
