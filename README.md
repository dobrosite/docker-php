# Образы PHP для разработки и тестирования сайтов

Целью этой библиотеки образов является предоставление разработчикам (в первую очередь разработчикам
[Добро.сайта](http://добро.сайт/)) окружения для разработки и тестирования сайтов на PHP с
использованием Docker, позволяющего решать следующие задачи.

1. Выбор версии PHP (включая уже официально неподдерживаемые).
2. Гибкая настройка PHP (выбор подключённых расширений).
3. Готовые к работе инструменты разработки и отладки.

## Принципы

1. **Единообразие**. Все образы делаются насколько это возможно похожими друг на друга по составу ПО, используемым
   версиям, настройкам и т. п.
2. **Настрой сам**. Образы содержат широкий набор расширений PHP, приложений и инструментов, но по
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
        image: dobrosite/php:5.3-apache
        environment:
            FILE_OWNER_UID: 1000
            APACHE_MODULES: env rewrite
            PHP_EXTENSIONS: iconv mstring pdo_mysql
            PHP_INI_SETTINGS: memory_limit=-1 date.timezone=Europe/Moscow
            NULLMAILER_REMOTES: mail.example.com smtp 
        ports:
            - '80:80'
```

### Переменные окружения

Некоторые настройки можно произвести через переменные окружения.

- `APACHE_MODULES` — разделённый пробелами список [модулей](http://httpd.apache.org/docs/2.4/mod/),
  которые следует подключить. Имена должны указываться без приставки `mod_`.
- `FILE_OWNER_UID` — UID для пользователя `www-data`, от которого работает веб-сервер.
- `PHP_EXTENSIONS` — разделённый пробелами список расширений PHP, которые следует подключить.
- `PHP_INI_SETTINGS` — разделённый пробелами список параметров php.ini, которые следует использовать.
- `NULLMAILER_REMOTES` — содержимое файла [/etc/nullmailer/remotes](http://www.untroubled.org/nullmailer/HOWTO).

### Файлы настройки

В дополнение к переменным окружения вы можете разместить по указанным путям файлы с различными
настройками:

- `/etc/apache2/conf-enabled/*.conf` — дополнительные файлы настройки для веб-сервера Apache HTTP;
- `/etc/apache2/sites-enabled/*.conf` — файлы виртуальных хостов для веб-сервера Apache HTTP;
- `/usr/local/etc/php/` — папка для файлов `php.ini`;
- `/usr/local/etc/php/conf.d/` — папка для подключения и настройки расширений PHP.

## Содержимое образов

### Общее для всех образов

- PHP [cli SAPI](http://php.net/manual/features.commandline.php)
- Стандартные расширения (скомпилированы статически):
  - [ftp](http://php.net/ftp)
  - [hash](http://php.net/hash)
  - [json](http://php.net/json)
  - [mbstring](http://php.net/mbstring)
  - [mysqlnd](http://php.net/mysqlnd)
  - [openssl](http://php.net/openssl)
  - [pcre](http://php.net/pcre)
  - [pdo](http://php.net/pdo)
  - [phar](http://php.net/phar)
  - [session](http://php.net/manual/book.session.php)
  - [zlib](http://php.net/zlib)
- Стандартные расширения (подключаются динамически):
  - [bzip2](http://php.net/bzip2)
  - [ctype](http://php.net/ctype)
  - [curl](http://php.net/curl)
  - [date](http://php.net/manual/ref.datetime.php)
  - [DOM](http://php.net/dom)
  - [eregi](http://php.net/eregi) (в версиях до 7.0)
  - [exif](http://php.net/exif)
  - [fileinfo](http://php.net/fileinfo)
  - [filter](http://php.net/filter)
  - [gd](http://php.net/gd)
  - [gettext](http://php.net/gettext)
  - [iconv](http://php.net/iconv)
  - [intl](http://php.net/intl)
  - [libxml](http://php.net/libxml)
  - [mcrypt](http://php.net/mcrypt)
  - [mysql](http://php.net/manual/book.mysql.php)
  - [mysqli](http://php.net/mysqli)
  - [pcntl](http://php.net/pcntl)
  - [pdo_mysql](http://php.net/pdo_mysql)
  - [pdo_pgsql](http://php.net/pdo_pgsql)
  - [pdo_sqlite3](http://php.net/pdo_sqlite)
  - [pgsql](http://php.net/pgsql)
  - [posix](http://php.net/posix)
  - [readline](http://php.net/readline)
  - [reflection](http://php.net/reflection)
  - [simplexml](http://php.net/simplexml)
  - [soap](http://php.net/soap)
  - [sockets](http://php.net/sockets)
  - [sodium](http://php.net/sodium) (PHP 7.2+)
  - [SPL](http://php.net/spl)
  - [sqlite](http://php.net/sqlite)
  - [tidy](http://php.net/tidy)
  - [tokenizer](http://php.net/tokenizer)
  - [xml](http://php.net/xml)
  - [xmlreader](http://php.net/xmlreader)
  - [xmlwriter](http://php.net/xmlwriter)
  - [xsl](http://php.net/xsl)
  - [zip](http://php.net/zip)
- Расширения PECL:
  - [memcached](http://pecl.php.net/package/memcached)
  - [xdebug](https://xdebug.org/)
- [PEAR](http://pear.php.net/)
- [Composer](https://getcomposer.org/)
- [cURL](https://curl.haxx.se/docs/tooldocs.html)
- [Git](https://git-scm.com)
- [GNU Make](https://www.gnu.org/software/make/manual/make.html)
- [GNU Wget](https://www.gnu.org/software/wget/)
- [nmap](https://nmap.org/)
- [npm](https://docs.npmjs.com/)
- [nullmailer](http://www.untroubled.org/nullmailer/)
- [OpenSSH](http://www.openssh.com/) (клиент)
- [sshpass](https://sourceforge.net/projects/sshpass/)
- [telnet](http://manpages.org/telnet)


### Образы *-apache

- PHP [apache SAPI](http://php.net/manual/install.unix.apache2.php)
- [Apache HTTP](http://httpd.apache.org/) 2.4
