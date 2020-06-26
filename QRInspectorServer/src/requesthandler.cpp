/**
  @file
  @author Stefan Frings
*/

#include "requesthandler.h"
#include "filelogger.h"
#include "startup.h"

#include "imagecontroller.h"

#include <QNetworkRequest>
#include <QImage>
#include <QtSql>
#include <QTextCodec>

int addVisitToPostgres(QString aud, int id);

/** Logger class */
extern Logger* logger;
extern Settings* ServerSettings;
RequestHandler::RequestHandler(QObject* parent)
    :HttpRequestHandler(parent)
{}

void RequestHandler::service(HttpRequest& request, HttpResponse& response)
{
    QByteArray path=request.getPath();
    qDebug("Conroller: path=%s",path.data());
    //QString str= QString::fromLatin1(path);
    QString str = path.data();
    //    QTextCodec *codec = QTextCodec::codecForName("Windows-1251");
    //    QString str = codec->toUnicode(path);
    QByteArray requestPassword = request.getParameter("password");
    qDebug() <<"SERVER PASSWORD = " <<requestPassword;
    QByteArray requestCommand = request.getParameter("command");
    qDebug() <<"COMMAND = " <<requestCommand;

    if (!ServerSettings->database.isOpen() && !ServerSettings->databaseBusy)
    {
        ServerSettings->database.open();
        QSqlQuery myQ(ServerSettings->database);
        myQ.exec("PRAGMA foreign_keys = ON");
    }

    if (requestPassword==ServerSettings->serverPassword)
    {
        if (str.contains("images/"))
        {
            ImageController().service(request, response);

            qDebug()<< "Image";
        }
        else if (str.contains("uploadimage"))
        {
            QByteArray password=request.getParameter("password");
            QByteArray name=request.getParameter("name");
            QByteArray image=request.getParameter("image");
            //QImage img  =  QImage::fromData(image,"jpg");
            qDebug() << "IMAGE NAME = "<<name;
            QFile file(ServerSettings->docroot+"/images/"+name+".jpg");
            if (!file.open(QIODevice::WriteOnly))
            {
                qDebug() << "Cant open new image file";
                response.write("Image rejected",true);
                return;
            }
            else
            {
                qDebug() << name+".png" << " opened";
                file.write(image);
                file.close();
                response.write("Image accepted",true);
            }
        }
        else if (str.contains("rootpassword/"))
        {
            if (str.remove(0,1).split("/")[1]==ServerSettings->sudoPassword)
            {
                if (requestCommand=="get name")
                {
                    response.write(ServerSettings->sqlite.right(ServerSettings->sqlite.length()-ServerSettings->sqlite.lastIndexOf("/")).toStdString().c_str(),true);
                    qDebug()<<ServerSettings->sqlite.right(ServerSettings->sqlite.length()-ServerSettings->sqlite.lastIndexOf("/")).toStdString().c_str();
                }
                if (requestCommand==("wipe table"))
                {
                    QSqlQuery myQ(ServerSettings->database);
                    //QString bigquery = "drop table members; drop table groupnames; drop table groups; drop table events; drop table invites; drop table visits; CREATE TABLE members (memberid integer PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL, surname VARCHAR(20) NOT NULL, patronymic VARCHAR(20), qrcode CHAR(16) UNIQUE); CREATE TABLE groupnames (groupid integer PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL UNIQUE); CREATE TABLE groups (groupid integer NOT NULL REFERENCES groupnames(groupid) ON DELETE CASCADE, memberid integer NOT NULL REFERENCES  members(memberid) ON DELETE CASCADE, CONSTRAINT unq UNIQUE (groupid, memberid)); CREATE TABLE events (eventid integer PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL UNIQUE, checkpoint VARCHAR(20) NOT NULL, beginning CHAR(10), ending CHAR(10), date CHAR(20), mon BOOLEAN, tue BOOLEAN, wed BOOLEAN, thu BOOLEAN, fri BOOLEAN, sat BOOLEAN, sun BOOLEAN, CHECK ((((mon+tue+wed+thu+fri+sat+sun) NOT NULL) AND (date IS NULL)) OR (((mon+tue+wed+thu+fri+sat+sun) IS NULL) AND (date NOT NULL)))); CREATE TABLE invites (eventid integer NOT NULL REFERENCES events(eventid) ON DELETE CASCADE, groupid integer REFERENCES groupnames(groupid) ON DELETE CASCADE, memberid integer REFERENCES members(memberid) ON DELETE CASCADE, CHECK ((memberid IS NULL AND groupid NOT NULL) OR (memberid NOT NULL AND groupid IS NULL)), CONSTRAINT unq UNIQUE (eventid, groupid), CONSTRAINT unq2 UNIQUE (eventid, memberid)); CREATE TABLE visits (visitid integer NOT NULL PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL, surname VARCHAR(20) NOT NULL, patronymic VARCHAR(20), event VARCHAR(20) NOT NULL, checkpoint VARCHAR(20) NOT NULL, date CHAR(20) NOT NULL, beginning CHAR(10) NOT NULL, time CHAR(10) NOT NULL, ending CHAR(10) NOT NULL, memberid integer NOT NULL REFERENCES members(memberid) ON DELETE CASCADE,  eventid integer NOT NULL REFERENCES events(eventid) ON DELETE CASCADE, qrcode CHAR(16) NOT NULL)";
                    QString bigquery = "delete from members; delete from groupnames; delete from groups; delete from events; delete from invites; delete from visits; delete from sqlite_sequence";
                    QStringList querylist = bigquery.split(";");
                    QString responsemsg="request executed";
                    for (int i=0; i<querylist.count(); i++)
                    {
                        myQ.exec(querylist[i]);
                        if (!myQ.isActive())
                            responsemsg = myQ.lastError().text();
                    }
                    response.write(responsemsg.toStdString().c_str(),true);
                }
                else if (requestCommand.contains("set dbname="))
                {
                    ServerSettings->database.close();
                    QString curdbname = ServerSettings->sqlite;
                    QString dbtoset = requestCommand.split('=')[1];
                    ServerSettings->database.setDatabaseName(ServerSettings->docroot+"/../sqlite/"+dbtoset);
                    if (ServerSettings->database.open())
                    {
                        QSqlQuery myQ(ServerSettings->database);
                        myQ.exec("PRAGMA foreign_keys = ON");
                        QString bigquery = "CREATE TABLE members (memberid integer PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL, surname VARCHAR(20) NOT NULL, patronymic VARCHAR(20), qrcode CHAR(16) UNIQUE); CREATE TABLE groupnames (groupid integer PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL UNIQUE); CREATE TABLE groups (groupid integer NOT NULL REFERENCES groupnames(groupid) ON DELETE CASCADE, memberid integer NOT NULL REFERENCES  members(memberid) ON DELETE CASCADE, CONSTRAINT unq UNIQUE (groupid, memberid)); CREATE TABLE events (eventid integer PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL UNIQUE, checkpoint VARCHAR(20) NOT NULL, beginning CHAR(10), ending CHAR(10), date CHAR(20), mon BOOLEAN, tue BOOLEAN, wed BOOLEAN, thu BOOLEAN, fri BOOLEAN, sat BOOLEAN, sun BOOLEAN, CHECK ((((mon+tue+wed+thu+fri+sat+sun) NOT NULL) AND (date IS NULL)) OR (((mon+tue+wed+thu+fri+sat+sun) IS NULL) AND (date NOT NULL)))); CREATE TABLE invites (eventid integer NOT NULL REFERENCES events(eventid) ON DELETE CASCADE, groupid integer REFERENCES groupnames(groupid) ON DELETE CASCADE, memberid integer REFERENCES members(memberid) ON DELETE CASCADE, CHECK ((memberid IS NULL AND groupid NOT NULL) OR (memberid NOT NULL AND groupid IS NULL)), CONSTRAINT unq UNIQUE (eventid, groupid), CONSTRAINT unq2 UNIQUE (eventid, memberid)); CREATE TABLE visits (visitid integer NOT NULL PRIMARY KEY autoincrement, name VARCHAR(20) NOT NULL, surname VARCHAR(20) NOT NULL, patronymic VARCHAR(20), event VARCHAR(20) NOT NULL, checkpoint VARCHAR(20) NOT NULL, date CHAR(20) NOT NULL, beginning CHAR(10) NOT NULL, time CHAR(10) NOT NULL, ending CHAR(10) NOT NULL, memberid integer NOT NULL REFERENCES members(memberid) ON DELETE CASCADE,  eventid integer NOT NULL REFERENCES events(eventid) ON DELETE CASCADE, qrcode CHAR(16) NOT NULL)";
                        QStringList querylist = bigquery.split(";");
                        for (int i=0; i<querylist.count(); i++)
                            myQ.exec(querylist[i]);
                        ServerSettings->databaseSettings->setValue("sqlite", dbtoset);
                        ServerSettings->sqlite=dbtoset;
                        qDebug() << "sqllite db changed to: " << dbtoset;
                        response.write("request executed",true);
                    }
                    else
                    {
                        ServerSettings->database.setDatabaseName(ServerSettings->docroot+"/../sqlite/"+curdbname);
                        ServerSettings->database.open();
                        response.write("db not opened",true);
                    }
                }
                else if(requestCommand.contains("set dbstatus="))
                {
                    QString status = requestCommand.split('=')[1];
                    ServerSettings->databaseBusy=(status=="1");
                }
                else if(requestCommand.contains("get dbstatus"))
                {
                    response.write((ServerSettings->databaseBusy ? "1": "0") ,true);
                }
                else
                    response.write("unknown command",true);
            }
            else
                response.write("accessdenied", true);
        }
        else if (requestCommand=="execute sqlquery")
        {
            if (str.remove(0,1)==ServerSettings->dbPassword)
            {
                QByteArray requestSQLRequest = request.getParameter("sqlrequest");
                qDebug() <<"sql request = " <<requestSQLRequest;
                QString bigquery = requestSQLRequest;
                if (bigquery.endsWith(";")) bigquery.remove(bigquery.length()-1,1);

                QSqlQuery myQ(ServerSettings->database);

                if (requestSQLRequest.contains(";"))
                {
                    QStringList querylist = bigquery.split(";");
                    QString responsemsg="request executed";
                    for (int i=0; i<querylist.count(); i++)
                    {
                        myQ.exec(querylist[i]);
                        if (!myQ.isActive())
                        {
                            response.write(myQ.lastError().text().toStdString().c_str(),true);
                            return;
                        }
                    }
                    response.write(responsemsg.toStdString().c_str(),true);
                }
                else
                {
                    myQ.exec(requestSQLRequest);
                    qDebug() <<"sqlq executing...";
                    if (myQ.isActive()) {
                        if (myQ.isSelect())
                        {
                            QSqlRecord R = myQ.record();
                            QString sqlResponse="";
                            for (int i = 0; i < R.count(); i++)
                                sqlResponse+=R.fieldName(i)+"|";
                            sqlResponse+="|";
                            while (myQ.next() && sqlResponse.length()<40000)
                            {
                                QSqlRecord R = myQ.record();
                                for (int i = 0; i < R.count(); i++)
                                    if (R.value(i).toString()=="")
                                        sqlResponse += "| ";
                                    else
                                        sqlResponse += "|"+R.value(i).toString();
                                sqlResponse+="|";
                            }
                            sqlResponse.remove(sqlResponse.length()-1,1);
                            qDebug()<< "SQL RESPONSE = "<<sqlResponse;
                            response.write(sqlResponse.toStdString().c_str(),true);
                        }
                        else
                            response.write("request executed",true);
                    }
                    else {
                        response.write(("ERROR: "+myQ.lastError().text()).toStdString().c_str(),true);
                    }
                }
            }
            else
                response.write("ERROR: Wrong DB Password",true);
        }
        else if (requestCommand=="new visit" && !ServerSettings->databaseBusy)
        {
            str.remove(0,1);
            QStringList visitInfoList = str.split("|");
            QString qrcode=visitInfoList[0];
            QString checkpoint = visitInfoList[1];
            qDebug() << "DB REQ PARAM "<< qrcode <<"  "<< checkpoint;

            QSqlQuery myQ(ServerSettings->database);
            if (ServerSettings->sqlite!="")
            {
                myQ.exec("SELECT * FROM events WHERE (checkpoint='"+checkpoint+"' AND (date=(SELECT strftime('%d.%m.%Y')) OR (mon AND (SELECT strftime('%w'))='1') OR (tue AND (SELECT strftime('%w'))='2') OR (wed AND (SELECT strftime('%w'))='3') OR (thu AND (SELECT strftime('%w'))='4') OR (fri AND (SELECT strftime('%w'))='5') OR (sat AND (SELECT strftime('%w'))='6') OR (sun AND (SELECT strftime('%w'))='7')) AND (select time(beginning)<time('now','localtime')) AND (select time('now','localtime')<time(ending)) AND (eventid IN (SELECT eventid FROM events WHERE eventid in (SELECT eventid FROM invites WHERE (groupid in (SELECT groupid FROM groups WHERE memberid=(SELECT memberid FROM members WHERE qrcode='"+qrcode+"'))) OR memberid=(SELECT memberid FROM members WHERE qrcode='"+qrcode+"')))) AND (SELECT (SELECT date('now','localtime')) IN (SELECT date(date) FROM visits WHERE eventid=visits.eventid AND qrcode='"+qrcode+"' AND checkpoint='"+checkpoint+"') IS FALSE))");
                if (myQ.isActive())
                {
                    if (myQ.next())
                    {
                        QSqlRecord R = myQ.record();
                        qDebug() << "MEMBER HAS ACCESS AT LEAST FOR id(" << R.value(0).toString().toStdString().c_str() << ") EVENT";
                        qDebug() << "ADDING VISIT TO DB qr=" <<qrcode <<" checkpoint="<< checkpoint;
                        myQ.exec("INSERT INTO visits(name, surname, patronymic, event, checkpoint, date, beginning, time, ending, memberid, eventid, qrcode) SELECT name, surname, patronymic, event, checkpoint, date, beginning, time, ending, memberid, eventid, qrcode FROM (SELECT eventid, name as event, checkpoint, beginning, ending FROM events WHERE (checkpoint='"+checkpoint+"' AND (date=(SELECT strftime('%d.%m.%Y')) OR (mon AND (SELECT strftime('%w'))='1') OR (tue AND (SELECT strftime('%w'))='2') OR (wed AND (SELECT strftime('%w'))='3') OR (thu AND (SELECT strftime('%w'))='4') OR (fri AND (SELECT strftime('%w'))='5') OR (sat AND (SELECT strftime('%w'))='6') OR (sun AND (SELECT strftime('%w'))='7')) AND (select time(beginning)<time('now','localtime')) AND (select time('now','localtime')<time(ending)) AND (eventid IN (SELECT eventid FROM events WHERE eventid in (SELECT eventid FROM invites WHERE (groupid in (SELECT groupid FROM groups WHERE memberid=(SELECT memberid FROM members WHERE qrcode='"+qrcode+"'))) OR memberid=(SELECT memberid FROM members WHERE qrcode='"+qrcode+"')))) AND (SELECT (SELECT date('now','localtime')) IN (SELECT date(date) FROM visits WHERE eventid=visits.eventid AND qrcode='"+qrcode+"' AND checkpoint='"+checkpoint+"') IS FALSE))) INNER JOIN (SELECT * FROM members WHERE qrcode='"+qrcode+"') INNER JOIN (SELECT date('now','localtime') as date) INNER JOIN (SELECT time('now','localtime') as time)");
                        if (myQ.isActive())
                        {
                            qDebug() << "VISIT SUCCESSFULLY ADDED TO DB!";
                            //send img
                            QFile file(ServerSettings->docroot+"/images/"+qrcode+".jpg");
                            if (file.open(QIODevice::ReadOnly))
                            {
                                response.setHeader("Content-Type", "image/jpeg");
                                response.setHeader("Cache-Control","max-age="+QByteArray::number(60000/1000));
                                QByteArray buffer=file.readAll();
                                response.write(buffer);
                            }
                            else{
                                response.write("defaultface",true);
                                qDebug() << "defaultface";}
                        }
                        else{
                            response.write("databaseerror",true);
                            qDebug() << "databaseerror";}
                    }
                    else{
                        response.write("accessdenied",true);
                        qDebug() << "accessdenied";}
                }
                else{
                    response.write("databaseerror",true);
                    qDebug() << "databaseerror";}
            }
            else
            {
                addVisitToPostgres(checkpoint, qrcode.toInt());
            }
        }
        else if (requestCommand=="ping")
        {
            response.write("ping",true);
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
        }
    }
    else
        response.write("404",true);


    qDebug("Conroller: finished request");

    // Clear the log buffer
    if (logger)
    {
        logger->clear();
    }
}


int addVisitToPostgres(QString aud, int id) {
    QString idStr = QString::number(id);
    QSqlQuery myQ(ServerSettings->database);
    myQ.exec("SELECT EXTRACT(isodow FROM now())");
    myQ.next();
    int dayOfTheWeek = myQ.record().value(0).toInt();
    QString dayOfTheWeekStr;
    if (dayOfTheWeek == 1) { dayOfTheWeekStr = "mon";}
    if (dayOfTheWeek == 2) { dayOfTheWeekStr = "tue";}
    if (dayOfTheWeek == 3) { dayOfTheWeekStr = "wed";}
    if (dayOfTheWeek == 4) { dayOfTheWeekStr = "thu";}
    if (dayOfTheWeek == 5) { dayOfTheWeekStr = "fri";}
    if (dayOfTheWeek == 6) { dayOfTheWeekStr = "sat";}
    if (dayOfTheWeek == 7) { dayOfTheWeekStr = "sun";}
    QString hourS, minuteS;
    myQ.exec("SELECT beginning FROM university.events WHERE checkpoint = '"+aud+"' AND "+dayOfTheWeekStr+" = TRUE ");
    myQ.next();
    QString times = myQ.record().value(0).toString();
    for (int i = 0; i < 2; i++){
        hourS[i] = times[i];
        minuteS[i] = times[i+3];
    }
    QString hourE, minuteE;
    myQ.exec("SELECT ending FROM university.events WHERE checkpoint = '"+aud+"' AND "+dayOfTheWeekStr+" = TRUE ");
    myQ.next();
    QString timee = myQ.record().value(0).toString();
    for (int i = 0; i < 2; i++){
        hourE[i] = timee[i];
        minuteE[i] = timee[i+3];
    }
    myQ.exec("SELECT CURRENT_TIME");
    myQ.next();
    QString current = myQ.record().value(0).toString();
    QString hourCur, minuteCur;
    for (int i = 0; i < 2; i++){
        hourCur[i] = current[i];
        minuteCur[i] = current[i+3];
    }
    QString checking;
    int first = hourS.toInt()*3600 + minuteS.toInt()*60;
    int second = hourE.toInt()*3600 + minuteE.toInt()*60;
    int currentT = hourCur.toInt()*3600 + minuteCur.toInt()*60;
    myQ.exec("SELECT memberid FROM university.invites WHERE eventid = (SELECT eventid FROM university.events WHERE "+dayOfTheWeekStr+" = TRUE AND checkpoint = '"+aud+"') AND memberid = "+idStr+"");
    myQ.next();
    checking = myQ.record().value(0).toString();
    if (currentT - first > 0 && second - currentT > 0 && checking != ""/*hourCur.toInt() - hourS.toInt() > 0 && hourE.toInt() - hourCur.toInt() > 0 && checking != ""*/) {
        myQ.exec("INSERT INTO university.attendance VALUES ("+checking+", '"+aud+"', (SELECT eventid FROM university.events, university.members WHERE "+dayOfTheWeekStr+" = TRUE AND university.events.checkpoint = '"+aud+"' AND university.members.memberid = "+checking+"), (SELECT CURRENT_TIMESTAMP(0)))");
        return 1;
    }
    else {
        return 0;
    }
}
