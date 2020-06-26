#pragma once

#include "httprequesthandler.h"

using namespace stefanfrings;

class TextController : public HttpRequestHandler {
    Q_OBJECT
public:
    TextController(QObject* parent=0);
    void service(HttpRequest& request, HttpResponse& response);
    QString serverPassword,
            postgresHost="",
            postgresPort,
            postgresLogin,
            postgresPassword,
            postgresDbName;
};
