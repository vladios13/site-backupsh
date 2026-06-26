#!/bin/bash

#        _           _ _           _ _____
# __   _| | __ _  __| (_) ___  ___/ |___ /
# \ \ / / |/ _` |/ _` | |/ _ \/ __| | |_ \
#  \ V /| | (_| | (_| | | (_) \__ \ |___) |
#   \_/ |_|\__,_|\__,_|_|\___/|___/_|____/

set -euo pipefail

# ── Настройки (заполните под свой проект) ──────────────────────────────
PROJNAME=                   # Название проекта (для логов и уведомления).
DBNAME=                     # Имя базы данных.
USER=                       # Пользователь MySQL.
PASSWD=                     # Пароль MySQL.
HOST=localhost              # Хост MySQL.
CHARSET=utf8                # Кодировка базы данных.
SRCFILES=                   # Каталог с файлами для архивации (например /var/www/site).
DATADIR=/backup             # Куда складывать резервные копии.
DBFILENAME=db               # Базовое имя файла дампа БД.
ARFILENAME=files            # Базовое имя файла архива.
RETENTION_DAYS=14           # Сколько дней хранить копии (0 — не удалять).

PREFIX=$(date +%F)          # Подкаталог по дате: ГГГГ-ММ-ДД.
STAMP=$(date +%F--%H-%M)    # Метка времени в именах файлов и логах.

# ── Старт ──────────────────────────────────────────────────────────────

echo "[--------------------------------[$STAMP]--------------------------------]"
echo "[----------][$STAMP] Запуск бэкап проекта ..."
mkdir -p "$DATADIR/$PREFIX"
echo "[++--------][$STAMP] Делаем дамп базы данных..."

# ── Дамп базы данных ───────────────────────────────────────────────────
DUMPFILE="$DATADIR/$PREFIX/$DBFILENAME-$STAMP.sql.gz"
if ! mysqldump --user="$USER" --host="$HOST" --password="$PASSWD" -l \
        --default-character-set="$CHARSET" "$DBNAME" | gzip > "$DUMPFILE"; then
    echo "[++--------][$STAMP] Упс, ошибка создания дампа базы данных."
    exit 1
fi
if [[ ! -s "$DUMPFILE" ]]; then
    echo "[++--------][$STAMP] Упс, дамп базы данных пуст."
    exit 1
fi
echo "[++++------][$STAMP] Дамп базы данных [$DBNAME] - успешно выполнен."
echo "[++++++----][$STAMP] Делаю дамп [$PROJNAME]..."

# ── Архив файлов ───────────────────────────────────────────────────────
ARFILE="$DATADIR/$PREFIX/$ARFILENAME-$STAMP.tar.gz"
TAR_RC=0
# -C: пакуем относительными путями (без ведущего "/").
tar -czpf "$ARFILE" -C "$(dirname "$SRCFILES")" "$(basename "$SRCFILES")" || TAR_RC=$?
# Код tar: 0 — успех, 1 — файлы менялись при чтении (архив создан), ≥2 — ошибка.
if [[ "$TAR_RC" -ge 2 ]]; then
    echo "[++++++----][$STAMP] Упс, ошибка при создания дампа файлов."
    exit 1
elif [[ "$TAR_RC" -eq 1 ]]; then
    echo "[++++++----][$STAMP] Внимание: часть файлов менялась во время чтения, архив создан."
fi
if [[ ! -s "$ARFILE" ]]; then
    echo "[++++++----][$STAMP] Упс, архив файлов пуст."
    exit 1
fi
echo "[++++++++--][$STAMP] Создание резервной копии [$PROJNAME] успешно."

# ── Удаление старых копий ──────────────────────────────────────────────
if [[ "${RETENTION_DAYS:-0}" -gt 0 ]]; then
    echo "[++++++++--][$STAMP] Удаляю бэкапы старше $RETENTION_DAYS дн..."
    find "$DATADIR" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" \
        -exec rm -rf {} +
fi

DISKFREE=$(df -h "$DATADIR" | tail -n1 | awk '{print $4}')
DIRSIZE=$(du -h "$DATADIR" | tail -n1)
echo "[+++++++++-][$STAMP] Общий вес каталога: $DIRSIZE"
echo "[+++++++++-][$STAMP] Свободное место на диске: $DISKFREE"
echo "[+++++++++-][$STAMP] Отправляю сообщение в Telegram."

# ── Уведомление в Telegram ─────────────────────────────────────────────
TOKEN=                      # Токен бота (получить у @BotFather).
CHAT_ID=                    # ID чата для уведомлений.
MESSAGE="[$STAMP]%0AСоздание резервной копии [$PROJNAME] успешно.%0AСвободное место на диске: $DISKFREE%0AОбщий вес каталога: $DIRSIZE"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"

curl -s --max-time 15 --retry 2 -X POST "$URL" \
    -d chat_id="$CHAT_ID" -d text="$MESSAGE"
echo "[++++++++++][$STAMP] Уведомление в Telegram отправлено."
echo "[++++++++++][$STAMP] Все операции успешно выполнены."
exit 0
