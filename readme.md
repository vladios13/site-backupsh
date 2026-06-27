Небольшой bash-скрипт, который делает резервные копии файлов и базы данных MySQL и присылает уведомление в Telegram.

![License](https://img.shields.io/badge/License-MIT-green)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=black)

### Возможности

- Создания бэкапа файлов и баз данных.
- Отображение выполнения задачи в консоли.
- Уведомление об успешном бэкапе в Telegram.
- Автоматическое удаление копий старше заданного срока.

Все настройки задаются прямо в начале файла `script.sh`.

------------

Чтобы скрипт делал дамп базы данных, заполните доступ к MySQL:
```bash
HOST=localhost   # Хост MySQL
USER=            # Имя пользователя базы данных
PASSWD=          # Пароль от базы данных
```

Сколько дней хранить копии, задаётся отдельным параметром (`0` — не удалять):
```bash
RETENTION_DAYS=14
```

------------

Пример уведомления в Telegram:

![](https://i.13.yt/2020/08/03/1596463920-8523.jpg "Пример уведомления в Telegram")


------------


## Автор — vladios13

[![Блог](https://img.shields.io/badge/Блог-vladios13-blue)](https://blog.vladios13.com/site-backupsh/)
[![Telegram](https://img.shields.io/badge/Telegram-@vladios13blog-26A5E4)](https://t.me/vladios13blog)
[![ЮMoney](https://img.shields.io/badge/Поддержать-ЮMoney-yellow)](https://yoomoney.ru/to/410011568729023)
