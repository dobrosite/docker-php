# Образы PHP для разработки и тестирования сайтов

Целью этой библиотеки образов является предоставление разработчикам (в первую очередь разработчикам
[Добро.сайта](http://добро.сайт/)) окружения для для разработки и тестирования сайтов на PHP с
использованием Docker, позволяющего решать следующие задачи.

1. Выбор версии PHP (включая уже официально неподдерживаемые).
2. Гибкая настройка PHP (выбор подключённых расширений).
3. Готовые к работе инструменты разработки и отладки.

## Принципы

1. **Единообразие**. Все образы предоставляют делаются насколько это возможно похожими друг на друга
   по составу ПО, используемым версиями, настройкам и т. п.
2. **Официальные источники ПО**. Если это возможно, используются официальные образы и способы
   установки ПО.
3. **Настрой сам**. Образы содержат широкий набор расширений PHP, приложений и инструментов, но по
   умолчанию подключены только самые необходимые. Использование всего остального остаётся на
   усмотрение разработчика.

## Подключение и использование

Образы рассчитаны на использование с [docker-compose](https://docs.docker.com/compose/overview/),
поэтому все примеры даются для него.

Пример файла `docker-compose.yml`:

```yaml
version: '3'
services:
    web:
        build:
            image: doborosite/php:5.3-apache
        ports:
            - '80:80'
```

## Состав образа

В каждый образ включены:

- PHP (включая cli):
- Стандартные расширения PHP:
  - [bzip2](http://php.net/bzip2)
  - [ctype](http://php.net/ctype)
  - [curl](http://php.net/curl)
  - [date](http://php.net/manual/ref.datetime.php)
  - [DOM](http://php.net/dom)
  - [eregi](http://php.net/eregi) (в версиях до 7.0)
  - [exif](http://php.net/exif)
  - [fileinfo](http://php.net/fileinfo)
  - [filter](http://php.net/filter)
  - [ftp](http://php.net/ftp)
  - [gd](http://php.net/gd)
  - [gettext](http://php.net/gettext)
  - [hash](http://php.net/hash)
  - [iconv](http://php.net/iconv)
  - [intl](http://php.net/intl)
  - [json](http://php.net/json)
  - [libxml](http://php.net/libxml)
  - [mbstring](http://php.net/mbstring)
  - [mcrypt](http://php.net/mcrypt)
  - [mysql](http://php.net/manual/book.mysql.php)
  - [mysqli](http://php.net/mysqli)
  - [mysqlnd](http://php.net/mysqlnd)
  - [openssl](http://php.net/openssl)
  - [pcntl](http://php.net/pcntl)
  - [pcre](http://php.net/pcre)
  - [pdo](http://php.net/pdo)
  - [pdo_mysql](http://php.net/pdo_mysql)
  - [pdo_pgsql](http://php.net/pdo_pgsql)
  - [pdo_sqlite3](http://php.net/pdo_sqlite)
  - [pgsql](http://php.net/pgsql)
  - [phar](http://php.net/phar)
  - [posix](http://php.net/posix)
  - [readline](http://php.net/readline)
  - [reflection](http://php.net/reflection)
  - [session](http://php.net/manual/book.session.php)
  - [simplexml](http://php.net/simplexml)
  - [soap](http://php.net/soap)
  - [sockets](http://php.net/sockets)
  - [SPL](http://php.net/spl)
  - [sqlite](http://php.net/sqlite)
  - [tidy](http://php.net/tidy)
  - [tokenizer](http://php.net/tokenizer)
  - [xml](http://php.net/xml)
  - [xmlreader](http://php.net/xmlreader)
  - [xmlwriter](http://php.net/xmlwriter)
  - [xsl](http://php.net/xsl)
  - [zip](http://php.net/zip)
  - [zlib](http://php.net/zlib)
- Сторонние расширения PHP:
  - [xdebug](https://xdebug.org/)
- [PEAR](http://pear.php.net/)
- [Apache HTTP](http://httpd.apache.org/)
