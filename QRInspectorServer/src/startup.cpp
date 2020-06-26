/**
  @file
  @author Stefan Frings
*/

#include <QDir>
#include <QFile>
#include <QNetworkInterface>
#include <QHostInfo>
#include <QtSql>

#include "static.h"
#include "startup.h"
#include "filelogger.h"
#include "requesthandler.h"
#include "staticfilecontroller.h"

#include <iostream>
//#include <io.h>
//#include <fcntl.h>
//#include <stdio.h>
#include <windows.h>   // WinApi header

/** Name of this application */
#define APPNAME "QRInspectorServer"

/** Publisher of this application */
#define ORGANISATION "PascalShibanovKadiev"

/** Short description of the Windows service */
#define DESCRIPTION "Server for QRInspectorClient"

/** Logger class */
Logger* logger;
StaticFileController* staticController;
Settings* ServerSettings;

/** Search the configuration file */
QString searchConfigFile()
{
    QString binDir=QCoreApplication::applicationDirPath();
    QString appName=QCoreApplication::applicationName();
    QString fileName(appName+".ini");

    QStringList searchList;
    searchList.append(binDir);
    searchList.append(binDir+"/etc");
    searchList.append(binDir+"/../etc");
    searchList.append(binDir+"/../../etc"); // for development without shadow build
    searchList.append(binDir+"/../"+appName+"/etc"); // for development with shadow build
    searchList.append(binDir+"/../../"+appName+"/etc"); // for development with shadow build
    searchList.append(binDir+"/../../../"+appName+"/etc"); // for development with shadow build
    searchList.append(binDir+"/../../../../"+appName+"/etc"); // for development with shadow build
    searchList.append(binDir+"/../../../../../"+appName+"/etc"); // for development with shadow build
    searchList.append(QDir::rootPath()+"etc/opt");
    searchList.append(QDir::rootPath()+"etc");

    foreach (QString dir, searchList)
    {
        QFile file(dir+"/"+fileName);
        if (file.exists())
        {
            // found
            fileName=QDir(file.fileName()).canonicalPath();
            qDebug("Using config file %s",qPrintable(fileName));
            return fileName;
        }
    }

    // not found
    foreach (QString dir, searchList)
    {
        qWarning("%s/%s not found",qPrintable(dir),qPrintable(fileName));
    }
    qFatal("Cannot find config file %s",qPrintable(fileName));
    return 0;
}

void Startup::start()
{
    //    ::_setmode(::_fileno(stdout), _O_U16TEXT);
    //        auto const & sz_message
    //        {
    //            L"█████████████████████████████ ████████████████████████████████" L"\n"
    //            L"█────██─██─██───██────██─██─█ █───██───██────██─█─██───██────█" L"\n"
    //            L"█─██─██─██─██─████─██─██─█─██ █─████─████─██─██─█─██─████─██─█" L"\n"
    //            L"█─█████────██───██─█████──███ █───██───██────██─█─██───██────█" L"\n"
    //            L"█─██─██─██─██─████─██─██─█─██ ███─██─████─█─███───██─████─█─██" L"\n"
    //            L"█────██─██─██───██────██─██─█ █───██───██─█─████─███───██─█─██" L"\n"
    //            L"█████████████████████████████ ████████████████████████████████" L"\n"
    //        };
    //        ::std::wcout << sz_message << ::std::flush;


    // Initialize the core application
    QCoreApplication* app = application();
    app->setApplicationName(APPNAME);
    app->setOrganizationName(ORGANISATION);

    // Find the configuration file
    QString configFileName=searchConfigFile();

    // Configure logging into a file
    //    QSettings* logSettings=new QSettings(configFileName,QSettings::IniFormat,app);
    //    logSettings->beginGroup("logging");
    //    logger=new FileLogger(logSettings,10000,app);
    //    logger->installMsgHandler();
    logger = new Logger(app);
    logger->installMsgHandler();
    // Configure and start the TCP listener
    qDebug("ServiceHelper: Starting service");
    QSettings* listenerSettings=new QSettings(configFileName,QSettings::IniFormat,app);
    listenerSettings->beginGroup("listener");
    listener=new HttpListener(listenerSettings,new RequestHandler(app),app);

    QSettings* staticSettings=new QSettings(configFileName,QSettings::IniFormat,app);
    staticSettings->beginGroup("docroot");
    staticController = new StaticFileController(staticSettings, app);

    ServerSettings = new Settings;
    QSettings serverSettings(configFileName,QSettings::IniFormat,app);
    serverSettings.beginGroup("passwords");
    ServerSettings->serverPassword = serverSettings.value("serverpassword").toString();
    ServerSettings->dbPassword = serverSettings.value("dbpasword").toString();
    ServerSettings->sudoPassword = serverSettings.value("sudopassword").toString();

    QSettings *databaseSettings = new QSettings(configFileName,QSettings::IniFormat,app);
    databaseSettings->beginGroup("database");
    ServerSettings->databaseSettings = databaseSettings;
    ServerSettings->sqlite = databaseSettings->value("sqlite").toString();
    ServerSettings->postgresHost = databaseSettings->value("host").toString();
    ServerSettings->postgresPort = databaseSettings->value("port").toString();
    ServerSettings->postgresLogin = databaseSettings->value("login").toString();
    ServerSettings->postgresPassword = databaseSettings->value("password").toString();
    ServerSettings->postgresDbName = databaseSettings->value("dbname").toString();

    ServerSettings->docroot = staticSettings->value("path",".").toString();
    QFileInfo configFile(staticSettings->fileName());
    ServerSettings->docroot =QFileInfo(configFile.absolutePath(),ServerSettings->docroot).absoluteFilePath();
    //qDebug() <<"DOCROOT = "<< ServerSettings->docroot;

    qDebug();
    hostInfo();
    qDebug();
    qDebug() << "Server password = "<<ServerSettings->serverPassword;
    qDebug() << "Database password = "<<ServerSettings->dbPassword;
    qDebug() << "Sudo password = "<<ServerSettings->sudoPassword;
    qDebug();
    if (ServerSettings->sqlite!="")
    {
        qDebug() << "SQLite path = " << ServerSettings->docroot.left(ServerSettings->docroot.lastIndexOf("/"))+"/sqlite/"+ServerSettings->sqlite;
        ServerSettings->database= QSqlDatabase::addDatabase("QSQLITE");
        if (ServerSettings->sqlite.contains("/") || ServerSettings->sqlite.contains("\\"))
            ServerSettings->database.setDatabaseName(ServerSettings->sqlite);
        else
            ServerSettings->database.setDatabaseName(ServerSettings->docroot+"/../sqlite/"+ServerSettings->sqlite);
    }
    else
    {
        qDebug() << "Postgres host = " << ServerSettings->postgresHost;
        qDebug() << "Postgres port = " << ServerSettings->postgresPort;
        qDebug() << "Postgres login = " << ServerSettings->postgresLogin;
        qDebug() << "Postgres password = " << ServerSettings->postgresPassword;
        qDebug() << "Postgres DB name = " << ServerSettings->postgresDbName;
        ServerSettings->database= QSqlDatabase::addDatabase("QPSQL");
        ServerSettings->database.setHostName(ServerSettings->postgresHost);
        ServerSettings->database.setPort(ServerSettings->postgresPort.toInt());
        ServerSettings->database.setUserName(ServerSettings->postgresLogin);
        ServerSettings->database.setPassword(ServerSettings->postgresPassword);
        ServerSettings->database.setDatabaseName(ServerSettings->postgresDbName);
    }

    HANDLE  hConsole;
    hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    if (!ServerSettings->database.open())
    {
        qDebug();
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED);
        qWarning("!!!CANT OPEN DATABASE!!!");
        qWarning("!!!CHECK YOUR DATABASE OR CONNECTION SETTINGS!!!");
        qWarning("Startup: Service has started with errors");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED | FOREGROUND_BLUE | FOREGROUND_GREEN);
        //stop();
    }
    else
    {
        if (ServerSettings->sqlite!="")
        {
            QSqlQuery myQ(ServerSettings->database);
            myQ.exec("PRAGMA foreign_keys = ON");
            QString bigquery = "CREATE TABLE members (memberid integer PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL, surname VARCHAR(20) NOT NULL, patronymic VARCHAR(20), qrcode CHAR(16) UNIQUE); CREATE TABLE groupnames (groupid integer PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL UNIQUE); CREATE TABLE groups (groupid integer NOT NULL REFERENCES groupnames(groupid) ON DELETE CASCADE, memberid integer NOT NULL REFERENCES  members(memberid) ON DELETE CASCADE, CONSTRAINT unq UNIQUE (groupid, memberid)); CREATE TABLE events (eventid integer PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL UNIQUE, checkpoint VARCHAR(20) NOT NULL, beginning CHAR(10), ending CHAR(10), date CHAR(20), mon BOOLEAN, tue BOOLEAN, wed BOOLEAN, thu BOOLEAN, fri BOOLEAN, sat BOOLEAN, sun BOOLEAN, CHECK ((((mon+tue+wed+thu+fri+sat+sun) NOT NULL) AND (date IS NULL)) OR (((mon+tue+wed+thu+fri+sat+sun) IS NULL) AND (date NOT NULL)))); CREATE TABLE invites (eventid integer NOT NULL REFERENCES events(eventid) ON DELETE CASCADE, groupid integer REFERENCES groupnames(groupid) ON DELETE CASCADE, memberid integer REFERENCES members(memberid) ON DELETE CASCADE, CHECK ((memberid IS NULL AND groupid NOT NULL) OR (memberid NOT NULL AND groupid IS NULL)), CONSTRAINT unq UNIQUE (eventid, groupid), CONSTRAINT unq2 UNIQUE (eventid, memberid)); CREATE TABLE visits (visitid integer NOT NULL PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL, surname VARCHAR(20) NOT NULL, patronymic VARCHAR(20), event VARCHAR(20) NOT NULL, checkpoint VARCHAR(20) NOT NULL, date CHAR(20) NOT NULL, beginning CHAR(10) NOT NULL, time CHAR(10) NOT NULL, ending CHAR(10) NOT NULL, memberid integer NOT NULL REFERENCES members(memberid) ON DELETE CASCADE,  eventid integer NOT NULL REFERENCES events(eventid) ON DELETE CASCADE, qrcode CHAR(16) NOT NULL)";
            QStringList querylist = bigquery.split(";");
            for (int i=0; i<querylist.count(); i++)
                myQ.exec(querylist[i]);
        }
        qDebug();
        qDebug() << "Database successfully opened!";
        SetConsoleTextAttribute(hConsole, FOREGROUND_GREEN);
        qWarning("Startup: Service has successfully started");
        SetConsoleTextAttribute(hConsole, FOREGROUND_RED | FOREGROUND_BLUE | FOREGROUND_GREEN);
    }
}

void Startup::stop()
{
    // Note that this method is only called when the application exits itself.
    // It is not called when you close the window, press Ctrl-C or send a kill signal.

    delete listener;
    delete ServerSettings;
    qWarning("Startup: Service has been stopped");
}


Startup::Startup(int argc, char *argv[])
    : QtService<QCoreApplication>(argc, argv, APPNAME)
{
    setServiceDescription(DESCRIPTION);
    setStartupType(QtServiceController::AutoStartup);
}

void Startup::hostInfo()
{
    QString localhostname =  QHostInfo::localHostName();
    QString localhostIP;
    QList<QHostAddress> hostList = QNetworkInterface::allAddresses();
    foreach (const QHostAddress& address, hostList) {
        if (address.protocol() == QAbstractSocket::IPv4Protocol && address.isLoopback() == false) {
            localhostIP = address.toString();
        }
    }
    QString localMacAddress;
    QString localNetmask;
    foreach (const QNetworkInterface& networkInterface, QNetworkInterface::allInterfaces()) {
        foreach (const QNetworkAddressEntry& entry, networkInterface.addressEntries()) {
            if (entry.ip().toString() == localhostIP) {
                localMacAddress = networkInterface.hardwareAddress();
                localNetmask = entry.netmask().toString();
                break;
            }
        }
    }
    qDebug() << "Localhost name: " << localhostname;
    qDebug() << "LocalNet IP = " << localhostIP;
    qDebug() << "MAC = " << localMacAddress;
    qDebug() << "Netmask = " << localNetmask;
}

