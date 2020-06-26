# This project demonstrates how to use QtWebAppLib by including the
# sources into this project.

TARGET = QRInspectorServer
TEMPLATE = app
QT = core network sql widgets
CONFIG += console

HEADERS += \
           src/imagecontroller.h \
           src/startup.h \
           src/requesthandler.h

SOURCES += src/main.cpp \
           src/imagecontroller.cpp \
           src/startup.cpp \
           src/requesthandler.cpp

OTHER_FILES += etc/* logs/* ../readme.txt

#---------------------------------------------------------------------------------------
# The following lines include the sources of the QtWebAppLib library
#---------------------------------------------------------------------------------------

include(QtWebApp/qtservice/qtservice.pri)
include(QtWebApp/httpserver/httpserver.pri)
include(QtWebApp/logging/logging.pri)
# Not used: include(QtWebApp/templateengine/templateengine.pri)
