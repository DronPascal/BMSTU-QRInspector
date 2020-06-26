#pragma once
#include "httprequesthandler.h"

using namespace stefanfrings;

class ImageController : public HttpRequestHandler {
    Q_OBJECT
public:
    ImageController(QObject* parent=0);
    void service(HttpRequest& request, HttpResponse& response);
};

