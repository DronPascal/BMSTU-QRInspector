#include "imagecontroller.h"
#include "staticfilecontroller.h"

extern StaticFileController* staticController;

ImageController::ImageController(QObject* parent)
    : HttpRequestHandler(parent) {
    // empty
}

void ImageController::service(HttpRequest &request, HttpResponse &response) {
    staticController->service(request,response);
}
