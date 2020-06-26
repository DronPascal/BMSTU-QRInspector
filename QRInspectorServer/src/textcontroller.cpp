#include "textcontroller.h"
#include <iostream>
#include <fstream>
#include <string>
#include <QCoreApplication>
#include <QDir>
#include <QDebug>
//#include <QSqlDatabase>
//#include <QSqlQuery>
//#include <QSqlRecord>
#include "startup.h"
extern Settings* ServerSettings;

TextController::TextController(QObject* parent)
    : HttpRequestHandler(parent) {

}

void TextController::service(HttpRequest &request, HttpResponse &response) {
    QString str= QString::fromLatin1(request.getPath());
    QStringList list = str.split("&");
    if (list.size()==3)
    {
        list[0].remove(0,1);
        qDebug()<< list[0]<< list[1]<< list[2];
        if (list[0]==ServerSettings->serverPassword)
        {

//            QSqlDatabase new_db;
//            new_db = QSqlDatabase::addDatabase("QPSQL");
//            new_db.setHostName(postgresHost);
//            new_db.setPort(postgresPort.toInt());
//            new_db.setUserName(postgresLogin);
//            new_db.setPassword(postgresPassword);
//            new_db.setDatabaseName(postgresDbName);
//            if (!new_db.open())
//                qDebug() << "CANT CONNECT TO POSTGRES DB";
//            if (getSmth(list[1],(list[2]).toInt(),new_db)==1)
//            {
//                QString configFileName=searchConfigFile2();
//                QString imageID = configFileName.left(configFileName.lastIndexOf('/')+1)+"images/"+list[2]+".jpg";
//                qDebug()<<"Searching photo at "<<imageID;
//                QFile file(imageID);
//                if (!file.open(QIODevice::ReadOnly))
//                {
//                    //получение изображения из бд
//                }
//                QString answ = list[2]+"|registered";
//                response.write(answ.toStdString().c_str(),true);
//            }
//            else
//                response.write("accessdenied",true);
        }
    }
    else if (str.contains("password="))
    {
        QStringList list = str.split("=");
        qDebug()<< list[0]<< list[1];
        QString password = list[1];
        if (password==ServerSettings->serverPassword)
            response.write("connectconfirmed",true);
        else
            response.write("connectreject",true);
    }
    else
    {

            response.setHeader("Content-Type", "image/jpeg");
            response.setHeader("Cache-Control","max-age="+QByteArray::number(60000/1000));
            QFile file(ServerSettings->docroot+"/images/1.jpg");
            if (file.open(QIODevice::ReadOnly))
            {
                    QByteArray buffer=file.readAll();
                    response.write(buffer);
            }
         //response.write("Hello world",true);
    }
}
