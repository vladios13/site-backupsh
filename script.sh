#!/bin/bash

#        _           _ _           _ _____ 
# __   _| | __ _  __| (_) ___  ___/ |___ / 
# \ \ / / |/ _` |/ _` | |/ _ \/ __| | |_ \ 
#  \ V /| | (_| | (_| | | (_) \__ \ |___) |
#   \_/ |_|\__,_|\__,_|_|\___/|___/_|____/ 


PROJNAME= # Название бэкап проекта.
CHARSET= # Кодировка базы данных (utf8).
DBNAME= # Имя базы данных для резервного копирования.
DBFILENAME= # Имя дампа базы данных.
ARFILENAME= # Имя архива с файлами.
HOST= # Хост MySQL.
USER= # Имя пользователя базы данных.
PASSWD= # Пароль от базы данных.
DATADIR=/home/backup/ #Путь к каталогу где будут храниться резервные копии.
SRCFILES= # Путь к каталогу файлов для архивирования.
PREFIX=`date +%F` # Префикс по дате для структурирования резервных копий.

# Запуск проекта:

echo "[--------------------------------[`date +%F-%H-%M`]--------------------------------]"
echo "[----------][`date +%F--%H-%M`] Запуск бэкап проекта ..."
mkdir $DATADIR/$PREFIX 2> /dev/null
echo "[++--------][`date +%F--%H-%M`] Делаем дамп базы данных..."

# Дамп MySQL

mysqldump --user=$USER --host=$HOST --password=$PASSWD --default-character-set=$CHARSET $DBNAME | gzip> $DATADIR/$PREFIX/$DBFILENAME-`date +%F--%H-%M`.sql.gz
if [[ $? -gt 0 ]];then
echo "[++--------][`date +%F--%H-%M`] Упс, ошибка создания дампа базы данных."
exit 1
fi
echo "[++++------][`date +%F--%H-%M`] Дамп базы данных [$DBNAME] - успешно выполнен."
echo "[++++++----][`date +%F--%H-%M`] Делаю дамп [$PROJNAME]..."

# Дамп файлов

tar -czpf $DATADIR/$PREFIX/$ARFILENAME-`date +%F--%H-%M`.tar.gz $SRCFILES 2> /dev/null
if [[ $? -gt 0 ]];then
echo "[++++++----][`date +%F--%H-%M`] Упс, ошибка при создания дампа файлов."
exit 1
fi
echo "[++++++++--][`date +%F--%H-%M`] Создание резервной копии [$PROJNAME] успешно."
echo "[+++++++++-][`date +%F--%H-%M`] Общий вес каталога: `du -h $DATADIR | tail -n1`"
echo "[+++++++++-][`date +%F--%H-%M`] Свободное место на диске: `df -h /home|tail -n1|awk '{print $4}'`"
echo "[+++++++++-][`date +%F--%H-%M`] Отправляю сообщение в Telegram."

# Отправляем уведомление в Telegram

TOKEN= # Token telegram бота (получаем у @Botfather)
CHAT_ID= # ID чата куда отправлять сообщение
MESSAGE="[`date +%F-%H-%M`]%0AСоздание резервной копии [$PROJNAME] успешно.%0AСвободное место на диске: `df -h /home|tail -n1|awk '{print $4}'`%0AОбщий вес каталога: `du -h $DATADIR | tail -n1`"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"

curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
echo "[++++++++++][`date +%F--%H-%M`] Уведомление в Telegram отправлено."
echo "[++++++++++][`date +%F--%H-%M`] Все операции успешно выполнены."
exit 0
