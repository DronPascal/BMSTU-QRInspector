#include "MyClient.h"
#include "QZXing.h"
#include <QTextCodec>
//#include "qquickpainteditem.h"
class QQmlEngine;
class ServerImageProvider;
MyClient::MyClient(QObject *parent)
    : QObject(parent)
    , m_connected(0)
{
    mngr = new QNetworkAccessManager(this);
}

void MyClient::sendGet(const QString& strMsg, const QString& command) {
    QNetworkRequest request(QUrl("http://"+m_ip+":"+m_port+"/"+strMsg));
    qDebug() << "Sending request: "<< ("http://"+m_ip+":"+m_port+"/"+strMsg);
    lastRequest = strMsg;

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart passwordPart;
    passwordPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"password\""));
    passwordPart.setBody(m_password.toStdString().c_str());
    QHttpPart commandPart;
    commandPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"command\""));
    commandPart.setBody(command.toStdString().c_str());

    multiPart->append(passwordPart);
    multiPart->append(commandPart);

    connect(mngr, SIGNAL(finished(QNetworkReply*)), SLOT(getResponse(QNetworkReply*)));

    mngr->post(request, multiPart);
}

void MyClient::getResponse(QNetworkReply *reply)
{
    //    if (multiPart)
    //        delete multiPart;
    if(reply->error() != QNetworkReply::NoError)
    {
        qDebug() << "Server connection error: " << reply->errorString().toStdString().c_str();
        emit errorFounded(reply->errorString().toStdString().c_str());
    }

    QByteArray response = reply->readAll();

    disconnect(mngr, SIGNAL(finished(QNetworkReply*)), this, SLOT(getResponse(QNetworkReply*)));

    QList<QByteArray> headerList = reply->rawHeaderList();
    foreach(QByteArray head, headerList) {
        qDebug() << head << ":" << reply->rawHeader(head);
    }
    if  (reply->rawHeaderList().size()>2 && reply->rawHeader(reply->rawHeaderList()[1])=="image/jpeg")
    {
        qDebug() << "Returning image.";
        image.loadFromData(response);
        ServerImageProvider::setImage(&image);
        emit getImgFromServer();
    }
    else
    {
        QString str = response;
        qDebug() << "Returning text. ("+str+")";
        emit getServerResponse(str);
    }
}

void MyClient::sendImage(const QString& name, const QString& path) {

    QString imgName = path.mid(path.lastIndexOf('/')+1, path.lastIndexOf('.')-path.lastIndexOf('/')-1);
    qDebug() <<"IMAGE NAME"<<imgName << "BUT WILL BE SAVED AS " << name;
    multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart passwordPart;
    passwordPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"password\""));
    passwordPart.setBody(m_password.toStdString().c_str());

    QHttpPart textPart;
    textPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"name\""));
    textPart.setBody(name.toStdString().c_str());

    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/jpeg"));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"image\""));
    //QFile *file = new QFile(path);
    qDebug() << "FILE = " <<path;
    //file->open(QIODevice::ReadOnly);


    QImage img(path);
    int minxy=(img.width()>=img.height()) ? img.height()/2 : img.width()/2;
    QRect rect(QPoint(img.width()/2-minxy, img.height()/2-minxy), QPoint(img.width()/2+minxy, img.height()/2+minxy));
    QImage newImg = img.copy(rect);
    newImg=newImg.scaled(QSize(200,200), Qt::IgnoreAspectRatio,  Qt::FastTransformation);

    QByteArray arr;
    QBuffer buffer(&arr);
    buffer.open(QIODevice::WriteOnly);
    newImg.save(&buffer, "jpg");

    imagePart.setBody(arr);

    //file->setParent(multiPart); // we cannot delete the file now, so delete it with the multiPart

    multiPart->append(passwordPart);
    multiPart->append(textPart);
    multiPart->append(imagePart);

    qDebug() << "REQUEST = " <<"http://"+m_ip+":"+m_port+"/uploadimage";
    QNetworkRequest request(QUrl("http://"+m_ip+":"+m_port+"/uploadimage"));

    connect(mngr, SIGNAL(finished(QNetworkReply*)), SLOT(getResponse(QNetworkReply*)));
    mngr->post(request, multiPart);
    qDebug() << "IMAGE SENDED";
}

void MyClient::deleteImg(const QString&path){
    QFile filetoremove(path);
    filetoremove.remove();
}
