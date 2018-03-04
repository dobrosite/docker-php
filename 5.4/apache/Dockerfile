FROM debian:jessie

# Общие зависимости и инструменты.
RUN apt-get update && apt-get install -y  --no-install-recommends \
        bzip2 \
        ca-certificates \
        curl \
        librecode0 \
        libsqlite3-0 \
        libxml2 \
        wget \
    && rm -r /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - \
    && apt-get install -y --no-install-recommends \
        git \
        make \
        nodejs \
    && rm -r /var/lib/apt/lists/*

#
# Установка Apache HTTPD
#

RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2-bin \
        apache2.2-common \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/www/html \
    && mkdir -p \
        /var/lock/apache2 \
        /var/run/apache2 \
        /var/log/apache2 \
        /var/www/html \
    && chown -R www-data:www-data \
        /var/lock/apache2 \
        /var/run/apache2 \
        /var/log/apache2 \
        /var/www/html \
    && a2dismod mpm_event \
    && a2enmod mpm_prefork \
    && mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.dist \
    && rm /etc/apache2/conf-enabled/* /etc/apache2/sites-enabled/* \
    && usermod --shell /bin/sh www-data

COPY apache2.conf /etc/apache2/apache2.conf

# Было бы хорошо отложить копиравание этого на конец Dockerfile, но при компиляции PHP проверяется
# его содержимое.
COPY apache2.conf /etc/apache2/apache2.conf

#
# Установка PHP.
#

ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_EXTRA_BUILD_DEPS apache2-dev
RUN mkdir -p $PHP_INI_DIR/conf.d

RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2-dev \
        autoconf \
        file \
        g++ \
        gcc \
        libbz2-dev \
        libc-dev \
        libcurl4-openssl-dev \
        libicu-dev \
        libmcrypt-dev \
        libpng12-dev \
        libpq-dev \
        libreadline6-dev \
        librecode-dev \
        libsqlite3-dev \
        libssl-dev \
        libtidy-dev \
        libxml2-dev \
        libxslt1-dev \
        pkg-config \
        re2c \
    && rm -rf /var/lib/apt/lists/*

ENV PHP_VERSION 5.4.45

ENV GPG_KEYS F38252826ACD957EF380D39F2F7956BC5DA04B5D
RUN set -xe \
    && for key in $GPG_KEYS; do \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done

RUN set -x \
    && curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror" -o php.tar.bz2 \
    && curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2.asc/from/this/mirror" -o php.tar.bz2.asc \
    && gpg --verify php.tar.bz2.asc \
    && mkdir -p /usr/src/php \
    && tar -xof php.tar.bz2 -C /usr/src/php --strip-components=1 \
    && rm php.tar.bz2* \
    && cd /usr/src/php \
    && ./buildconf --force \
    && ./configure \
        --disable-all \
        --with-apxs2 \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        --with-libdir=/lib/x86_64-linux-gnu \
        --enable-libxml \
        --enable-xml \
        --enable-ctype=shared \
        --enable-dom=shared \
        --enable-exif=shared \
        --enable-fileinfo=shared \
        --enable-filter=shared \
        --enable-ftp=shared \
        --enable-hash=shared \
        --enable-intl=shared \
        --enable-json=shared \
        --enable-libxml=shared \
        --enable-mbstring=shared \
        --enable-mysqlnd=shared \
        --enable-pcntl=shared \
        --enable-pdo=shared \
        --enable-phar=shared \
        --enable-posix=shared \
        --enable-session=shared \
        --enable-simplexml=shared \
        --enable-soap=shared \
        --enable-sockets=shared \
        --enable-tokenizer=shared \
        --enable-xmlreader=shared \
        --enable-xmlwriter=shared \
        --enable-zip=shared \
        --with-bz2=shared \
        --with-curl=shared \
        --with-gd=shared \
        --with-gettext=shared \
        --with-iconv=shared \
        --with-mcrypt=shared \
        --with-mysql=shared \
        --with-mysqli=shared \
        --with-openssl=/usr \
        --with-pdo_mysql=shared \
        --with-pdo_pgsql=shared \
        --with-pdo_sqlite3=shared \
        --with-pgsql=shared \
        --with-readline=shared \
        --with-sqlite=shared \
        --with-tidy=shared \
        --with-xsl=shared \
        --with-zlib \
        --with-pear \
    && make -j"$(nproc)" \
    && make install \
    && make clean

RUN set -x \
    && wget https://getcomposer.org/installer -O - -q | \
        php \
            -d extension=json.so -d extension=phar.so -d extension=hash.so \
            -d extension=mbstring.so -- \
        --force --install-dir=/usr/local/bin --filename=composer

RUN set -x \
    && pecl channel-update pecl.php.net \
    && pecl install xdebug-2.2.7

WORKDIR /var/www/site
VOLUME /var/www/site

COPY docker-php-* /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]

EXPOSE 80
CMD ["apache2", "-DFOREGROUND"]
