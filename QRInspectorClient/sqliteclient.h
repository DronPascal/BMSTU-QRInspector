#pragma once
#include <QNetworkReply>
#include <QHttpPart>

class SQLiteClient : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString ip READ getIp WRITE setIp)
    Q_PROPERTY(QString port READ getPort WRITE setPort)
    Q_PROPERTY(QString password READ getPassword WRITE setPassword)
    Q_PROPERTY(QString dbpassword READ getDBPassword WRITE setDBPassword)
public:
    explicit SQLiteClient(QObject *parent = nullptr);
    ~SQLiteClient();

    Q_INVOKABLE void sendGetQuery(const QString& query);

    static void declareQML();

    void setIp(QString val) {m_ip = val; }
    QString getIp() {return m_ip; }
    void setPort(QString val) {m_port = val; }
    QString getPort() {return m_port; }
    void setPassword(QString val) {m_password = val; }
    QString getPassword() {return m_password; }
    void setDBPassword(QString val) {m_dbpassword = val; }
    QString getDBPassword() {return m_dbpassword; }
private:
    ///sql
    QStringList tableRoleNames;
    QStringList tableData;
    ///http
    QNetworkAccessManager *mngr;
    QHttpMultiPart *multiPart;

    QString m_ip;
    QString m_port;
    QString m_password="password";
    QString m_dbpassword="password";
private slots:
    void getResponse(QNetworkReply *reply);

Q_SIGNALS:
    void errorFounded(const QString& error);
    void sqlErrorFounded(const QString& error);
    void modelChanged(const QString& data);
};
