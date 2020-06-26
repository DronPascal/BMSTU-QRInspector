#include "sqliteclient.h"

SQLiteClient::SQLiteClient(QObject *parent) : QObject(parent)
{
    mngr = new QNetworkAccessManager(this);
}

SQLiteClient::~SQLiteClient() {
}

void SQLiteClient::sendGetQuery(const QString& query) {
    QNetworkRequest request(QUrl("http://"+m_ip+":"+m_port+"/"+m_dbpassword));
    qDebug() << "Sending request: "<< ("http://"+m_ip+":"+m_port+"/"+query);

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    QHttpPart passwordPart;
    passwordPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"password\""));
    passwordPart.setBody(m_password.toStdString().c_str());
    qDebug() << m_password<<" "<<m_ip<<" "<<m_port;
    QHttpPart commandPart;
    commandPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"command\""));
    commandPart.setBody("execute sqlquery");
    QHttpPart querryPart;
    querryPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"sqlrequest\""));
    querryPart.setBody(query.toStdString().c_str());

    multiPart->append(passwordPart);
    multiPart->append(commandPart);
    multiPart->append(querryPart);

    connect(mngr, SIGNAL(finished(QNetworkReply*)), SLOT(getResponse(QNetworkReply*)));
    mngr->post(request, multiPart);
}

void SQLiteClient::getResponse(QNetworkReply *reply)
{
    //    if (multiPart)
    //        delete multiPart;
    if(reply->error() != QNetworkReply::NoError)
    {
        qDebug() << "Server connection error: " << reply->errorString().toStdString().c_str();
        emit errorFounded(reply->errorString().toStdString().c_str());
    }
    else
    {
        QByteArray response = reply->readAll();

        disconnect(mngr, SIGNAL(finished(QNetworkReply*)), this, SLOT(getResponse(QNetworkReply*)));

        QList<QByteArray> headerList = reply->rawHeaderList();
        foreach(QByteArray head, headerList) {
            qDebug() << head << ":" << reply->rawHeader(head);
        }
        QString str = response;
        qDebug() << "Returning text: "+str;

        //    QStringList sqlresponse = str.split("||");
        //    tableRoleNames=sqlresponse[0].split("|");
        //    for (int i=0; i<tableRoleNames.size(); i++)
        //        qDebug() <<tableRoleNames[i];
        //    tableData=sqlresponse[1].split("|");
        //setQuery("");

        emit modelChanged(str);
    }
}
