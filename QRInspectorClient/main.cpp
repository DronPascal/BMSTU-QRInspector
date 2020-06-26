#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QApplication>
#include <QQmlContext>

#include "QZXing.h"
#include "MyClient.h"
#include "sqliteclient.h"
#include "ServerImageProvider.h"
#include "mylang.h"
#include "mytranslator.h"
//int ServerImageProvider::edin = 1;
QImage* ServerImageProvider::image(nullptr);
int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("PascalShibanovKadiev");
    QCoreApplication::setOrganizationDomain("QRInspector");
    QCoreApplication::setApplicationName("QRInspectorClient");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QImage img= QImage(":/images/defaultface.png");
    ServerImageProvider::image = &img;

    qmlRegisterType<MyClient>("MyExtentions", 1, 0, "MyClient");
    qmlRegisterType<SQLiteClient>("MyExtentions", 1, 0, "MySQLiteHandler");
    qmlRegisterType<MyLang>("MyLang", 1, 0, "MyLang");

    QQmlApplicationEngine engine;

    QZXing::registerQMLTypes();
    QZXing::registerQMLImageProvider(engine);
    engine.addImageProvider(QLatin1String("serverImgProvider"), new ServerImageProvider());

    MyTranslator mTrans(&app);
    engine.rootContext()->setContextProperty("mytrans", (QObject*)&mTrans);

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    return app.exec();

    //    QQmlApplicationEngine engine;
    //    const QUrl url(QStringLiteral("qrc:/main.qml"));
    //    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
    //                     &app, [url](QObject *obj, const QUrl &objUrl) {
    //        if (!obj && url == objUrl)
    //            QCoreApplication::exit(-1);
    //    }, Qt::QueuedConnection);
    //    QZXing::registerQMLImageProvider(engine);

    //    engine.load(url);
}
