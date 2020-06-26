/**
  @file
  @author Stefan Frings
*/

#ifndef STARTUP_H
#define STARTUP_H

#include <QtCore/QCoreApplication>
#include "qtservice.h"
#include "httplistener.h"

#include <QSqlDatabase>
struct Settings
{
    QString serverPassword;
    QString dbPassword;
    QString sudoPassword;

    QSettings* databaseSettings;
    QString sqlite;
    QString postgresHost;
    QString postgresPort;
    QString postgresLogin;
    QString postgresPassword;
    QString postgresDbName;
    QSqlDatabase database;
    QString docroot;

    bool databaseBusy=false;
};

using namespace stefanfrings;

/**
  Helper class to install and run the application as a windows
  service.
*/
class Startup : public QtService<QCoreApplication>
{
public:

    /** Constructor */
    Startup(int argc, char *argv[]);

protected:

    /** Start the service */
    void start();

    /**
      Stop the service gracefully.
      @warning This method is not called when the program terminates
      abnormally, e.g. after a fatal error, or when killed from outside.
    */
    void stop();
    void hostInfo();

private:

    /**
     * Listens for HTTP connections.
     */
    HttpListener* listener;

};

#endif // STARTUP_H
