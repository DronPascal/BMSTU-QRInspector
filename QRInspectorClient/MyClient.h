#pragma once
#include <QTcpSocket>
#include <QDataStream>
#include <QTime>
#include "QUrlQuery"

#include <QNetworkReply>
#include <QHttpPart>

#include "ServerImageProvider.h"
#include "QBuffer"
#include "QFile"

class MyClient : public QObject
{
    Q_OBJECT

    //Q_PROPERTY(bool connected READ isConnected NOTIFY connectedSuccessfully)
    Q_PROPERTY(QString ip READ getIp WRITE setIp)
    Q_PROPERTY(QString port READ getPort WRITE setPort)
    Q_PROPERTY(QString password READ getPassword WRITE setPassword)
   //Q_PROPERTY(QString error READ isErrored NOTIFY errorFounded)

private:
    QTcpSocket* m_pTcpSocket;
    quint16     m_nNextBlockSize;

    QNetworkAccessManager *mngr;
    QHttpMultiPart *multiPart;
    //ServerImageProvider *imgProvider;
    QString lastRequest;

    bool m_connected = false;

    QString m_ip;
    QString m_port;
    QString m_password="password";

public:
    explicit MyClient(QObject *parent = nullptr);
    QImage image;
    // long imgID=0;
    // static ServerImageProvider* imageProvider;
    // static QPixmap getPixmap(){return MyClient::pixmap;}
    //static void setPixmap(QPixmap pixm){MyClient::pixmap=pixm;};


    bool isConnected() const {return m_connected;}
    void setIp(QString val) {m_ip = val; }
    QString getIp() {return m_ip; }
    void setPort(QString val) {m_port = val; }
    QString getPort() {return m_port; }
    void setPassword(QString val) {m_password = val; }
    QString getPassword() {return m_password; }
    //    QString isErrored() const {return m_pTcpSocket->errorString();}
    //    Q_INVOKABLE bool sendToServer(const QString& strMsg);
    //    Q_INVOKABLE void connectToServer(const QString& strHost, QString nPort);
    Q_INVOKABLE void sendGet(const QString& strMsg, const QString& command="");
    Q_INVOKABLE void sendImage(const QString& name, const QString& path, int rotation);
    Q_INVOKABLE void deleteImg(const QString&path);
    //     Q_INVOKABLE void send(){
    //        QNetworkAccessManager *manager = new QNetworkAccessManager(this);

    //        QUrl url("http://127.0.0.1:80/image/sended");
    //        QNetworkRequest request(url);
    //        QImage img_enrll(":/images/hotpng2.png");
    //        QByteArray arr;
    //        QBuffer buffer(&arr);
    //        buffer.open(QIODevice::WriteOnly);
    //        img_enrll.save(&buffer, "jpg");
    //         manager->post(request,arr);
    //    }
    //    Q_INVOKABLE void send(QString name="govno",/* int type, int dest, int format,*/ QString imgBase64Data="")
    //    {
    //            QNetworkRequest request;
    //            request.setUrl(QUrl("http://127.0.0.1:80/images/"));
    //            request.setHeader(QNetworkRequest::ContentTypeHeader, "imageUpload");


    //            QFile* file = new QFile(":/images/hotpng2.png");
    //            file->open(QIODevice::ReadOnly);
    //            QByteArray bimage = file->readAll();

    ////            imgBase64Data = QString(bimage.toBase64());
    ////           //QUrlQuery postData;
    ////            qDebug() <<imgBase64Data;
    //            qDebug()<<bimage;
    //            sendGet(bimage);


    ////            QPixmap pixmap;
    ////            pixmap.loadFromData(QByteArray::to);
    ////            QFile file("yourFile.png");
    ////            file.open(QIODevice::WriteOnly);
    ////            pixmap.save(&file, "PNG");

    //        //    QFile file("lastImg.png");
    //        //    pixmap.save(&file, "PNG");
    //        //    file.close();
    //            ServerImageProvider::setImage(&image);
    //    }
private slots:
    //    void slotReadyRead   (                            );
    //    void slotError       (QAbstractSocket::SocketError);
    //    void slotConnected   (                            );
    void getResponse(QNetworkReply *reply);
    //void sgProcImage(QByteArray reply);
Q_SIGNALS:
    //   void connectedSuccessfully();
    void errorFounded(const QString& error);
    void getServerResponse(const QString& response);
    void getImgFromServer();
};
