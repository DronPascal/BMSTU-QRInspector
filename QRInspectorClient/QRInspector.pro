QT += quick quickcontrols2 network widgets core
CONFIG += c++11

CONFIG += qzxing_multimedia \
          enable_decoder_1d_barcodes \
          enable_decoder_qr_code \
          qzxing_qml \
          enable_encoder_qr_code

include(QZXing/QZXing-components.pri)

DEFINES += QT_DEPRECATED_WARNINGS

HEADERS += \
    MyClient.h \
    ServerImageProvider.h \
    mylang.h \
    mytranslator.h \
    sqliteclient.h

SOURCES += \
    MyClient.cpp \
    main.cpp \
    sqliteclient.cpp

RESOURCES += qml.qrc

TRANSLATIONS += \
    translation/QRInspector_ru_RU.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android








