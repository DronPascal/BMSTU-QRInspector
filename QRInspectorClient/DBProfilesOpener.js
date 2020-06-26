.import QtQml 2.12 as Qml
.pragma library
.import MyExtentions 1.0 as My

function memberProfile(parent, properties) {
       var component = Qt.createComponent("qrc:/qml/myTemplates/DBMemberProfile.qml");
       function finishCreation() {
           console.log("finishCreation");
           if (component.status === Qml.Component.Ready) {
               var obj = component.createObject(parent, properties);
               if (obj === null) {
                   console.log("Error creating object");
                   return;
               }
               console.log("success in creating obj");
           } else if (component.status === Qml.Component.Error) {
               console.log("Error loading component:", component.errorString());
               return;
           }
       }
       if (component.status === Qml.Component.Ready) {
           finishCreation();
       } else {
           component.statusChanged.connect(function() { finishCreation(); });
       }
}

function groupProfile(parent, properties) {
       var component = Qt.createComponent("qrc:/qml/myTemplates/DBGroupProfile.qml");
       function finishCreation() {
           console.log("finishCreation");
           if (component.status === Qml.Component.Ready) {
               var obj = component.createObject(parent, properties);
               if (obj === null) {
                   console.log("Error creating object");
                   return;
               }
               console.log("success in creating obj");
           } else if (component.status === Qml.Component.Error) {
               console.log("Error loading component:", component.errorString());
               return;
           }
       }
       if (component.status === Qml.Component.Ready) {
           finishCreation();
       } else {
           component.statusChanged.connect(function() { finishCreation(); });
       }
}

function eventProfile(parent, properties) {
       var component = Qt.createComponent("qrc:/qml/myTemplates/DBEventProfile.qml");
       function finishCreation() {
           console.log("finishCreation");
           if (component.status === Qml.Component.Ready) {
               var obj = component.createObject(parent, properties);
               if (obj === null) {
                   console.log("Error creating object");
                   return;
               }
               console.log("success in creating obj");
           } else if (component.status === Qml.Component.Error) {
               console.log("Error loading component:", component.errorString());
               return;
           }
       }
       if (component.status === Qml.Component.Ready) {
           finishCreation();
       } else {
           component.statusChanged.connect(function() { finishCreation(); });
       }
}
