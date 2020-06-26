#pragma once
#include "QQuickImageProvider"
#include "QDebug"
class ServerImageProvider : public QQuickImageProvider
{
public:
    friend class MyClient;

    ServerImageProvider()
               : QQuickImageProvider(QQuickImageProvider::Image)
    {
    }
    static QImage* image;
    static int edin;
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override
    {
        qDebug()<<id<< size<<requestedSize;
        qDebug() << "img goes in rect";
       return *image;
    }
    static void setImage(QImage* pixm) {
        ServerImageProvider::image = pixm;
    }
};

