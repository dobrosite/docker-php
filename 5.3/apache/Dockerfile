FROM buildpack-deps:jessie

ENV PHP_VERSION 5.3.29

COPY docker-php-ext-enable /usr/local/bin/

RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends \
        apache2-bin \
        apache2-dev \
        apache2.2-common \
        autoconf2.13 \
        curl \
        git \
        libicu-dev \
        libmcrypt-dev \
        libtidy-dev \
        wget \
    && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
    && apt-get install nodejs \
    && rm -r /var/lib/apt/lists/* \
    && rm -rf /var/www/html \
    && mkdir -p \
        /var/lock/apache2 \
        /var/log/apache2 \
        /var/run/apache2 \
        /var/www/html \
    && chown -R www-data:www-data \
        /var/lock/apache2 \
        /var/log/apache2 \
        /var/run/apache2 \
        /var/www/html \
    && a2dismod mpm_event \
    && a2enmod mpm_prefork \
    && mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.dist \
    && gpg --keyserver pgp.mit.edu --recv-keys \
        0B96609E270F565C13292B24C13C70B87267B52D \
        0A95E9A026542D53835E3F3A7DEC4E69FC9C83D7 \
    && curl -SLO http://launchpadlibrarian.net/140087283/libbison-dev_2.7.1.dfsg-1_amd64.deb \
    && curl -SLO http://launchpadlibrarian.net/140087282/bison_2.7.1.dfsg-1_amd64.deb \
    && dpkg -i libbison-dev_2.7.1.dfsg-1_amd64.deb \
    && dpkg -i bison_2.7.1.dfsg-1_amd64.deb \
    && rm *.deb \
    && curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror" -o php.tar.bz2 \
    && curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2.asc/from/this/mirror" -o php.tar.bz2.asc \
    && gpg --verify php.tar.bz2.asc \
    && mkdir -p /usr/src/php \
    && tar -xf php.tar.bz2 -C /usr/src/php --strip-components=1 \
    && rm php.tar.bz2* \
    && cd /usr/src/php \
    && ./buildconf --force \
    && ./configure \
        --disable-all \
        $(command -v apxs2 > /dev/null 2>&1 && echo '--with-apxs2' || true) \
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
        --with-config-file-path=/usr/local/etc/php \
        --with-config-file-scan-dir=/usr/local/etc/php/conf.d \
        --with-libdir=/lib/x86_64-linux-gnu \
    && make -j"$(nproc)" \
    && make install \
    && mkdir -p /usr/local/etc/php/conf.d \
    && cp php.ini-development /usr/local/etc/php/php.ini \
    && dpkg -r bison libbison-dev \
    && apt-get purge -y --auto-remove autoconf2.13 \
    && rm -r /usr/src/php \
    && wget https://getcomposer.org/installer -O - -q | \
        php \
            -d extension=json.so -d extension=phar.so -d extension=hash.so \
            -d extension=mbstring.so -- \
        --force --install-dir=/usr/local/bin --filename=composer \
    && usermod --shell /bin/sh www-data \
    && chown www-data /var/www \
    && pecl channel-update pecl.php.net \
    && pecl install xdebug-2.2.7

COPY apache2.conf /etc/apache2/apache2.conf

ARG FILE_OWNER_UID=1000
RUN usermod --uid ${FILE_OWNER_UID} www-data && chown www-data /var/www

WORKDIR /var/www/site
VOLUME /var/www/site

EXPOSE 80
CMD ["apachectl", "start", "-DFOREGROUND"]
