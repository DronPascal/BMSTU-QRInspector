RUS: 
Для настройки сервера вам потребуется изменить всего 3-4 поля в конфигурационном файле, который находится по адресу /etc/QRInspectorServer.ini относительно текущей директории.
Обратите внимание на данные строки в файле:
*/
serverpassword=password
dbpasword=password
sudopassword=password

port=8080
*/

Важно изменить значения параметров serverpassword, dbpasword и sudopassword. Задав разные пароли вы можете распределить роли в своей компании.
-serverpassword используется для авторизаии при подключении к серверу. Без него вы не добьётесь ничего кроме ошибки 404 при попытке подключиться.
-dbpasword предоставляет роли "администратор" доступ к созданию и редактированию базы данных. База данных содержит профили участников, групп и событий.
-sudopassword дает возможность полностью очищать базу данных, а также выбирать базу данных, с которой будет работать сервер.
port - опциональная настройка. Если сервер не запустится на текущем, узнайте какой порт не используются вашим устройством и используйте его.
Остальные настройки дополнительные и маловероятно, что они вам понадобятся. Но в крайнем случае, вы легко сможете разобраться какая отвечает за что, просто загуглив: http server [название настройки].
Если вы собираетесь использовать много инспекторов, измените минимальное и максимальное количество потоков, которые должен/может использовать сервер (настройки minThreads, maxThreads)
Сохраните и закройте .ini файл. 

##################################################################################################
Запуск сервера на Windows: Запустите startserver.cmd 

Запуск на Linux:
1) установите внешнюю библиотеку: sudo apt install libpcre2-16-0 
sudo apt install libicui18n.so.60
2) перейдите в директорию с исполняемым файлом и запустите его с правами администратора: sudo ./QRInspectorServer -e

Запишите LocalNet IP. Если вы подключаете устройство с ролью “инспектор” к серверу в локальной сети, используйте этот IP. Для настройки доступа к серверу из глобальной сети обратитесь к системному администратору или узнайте про проброску портов и статические IP адреса в интернете.
##################################################################################################




ENG:
To configure the server, you will need to change only 3-4 fields in the configuration file, which is located at /etc/QRInspectorServer.ini relative to the current directory.
Pay attention to the data lines in the file:
* /
serverpassword = password
dbpasword = password
sudopassword = password

port = 8080
* /
It is important to change the serverpassword, dbpasword, and sudopassword parameter values. By setting different passwords you can distribute roles in your company.
-serverpassword is used for authorization when connecting to the server. Without it, you will not achieve anything other than a 404 error when trying to connect.
-dbpasword gives the administrator role access to create and edit the database. The database contains profiles of participants, groups and events.
-sudopassword makes it possible to completely clear the database, as well as select the database with which the server will work.
port - optional setting. If the server does not start on the current one, find out which port is not used by your device and use it.
The rest of the settings are additional and it is unlikely that you will need them. But in a pinch, you can easily figure out which one is responsible for what, just by google: http server [name of the setting].

Save and close the .ini file. Run startserver.cmd on Windows or ./QRInspectorServer -e on Linux.

Record LocalNet IP. If you connect a device with the “inspector” role to a server on the local network, use this IP.


