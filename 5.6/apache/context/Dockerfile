FROM debian:stretch-slim

## Широкоиспользуемые системные и вспомогательные пакеты.
RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		dirmngr \
		gnupg \
		iproute2 \
		openssh-client \
		telnet \
		unzip \
		wget \
		xz-utils \
	&& rm -r /var/lib/apt/lists/*

## NullMailer
RUN apt-get update \
	&& echo nullmailer shared/mailname string me | debconf-set-selections \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install nullmailer \
	&& rm -r /var/lib/apt/lists/*

## Инструменты и библиотеки для разработки.
RUN apt-get update && apt-get install -y --no-install-recommends \
		bison \
		git \
		make \
		nmap \
		sshpass \
	&& rm -r /var/lib/apt/lists/*

# NodeJS.
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - \
	&& apt-get update && apt-get install -y --no-install-recommends \
		nodejs \
	&& rm -r /var/lib/apt/lists/*

# Запрещаем установку пакетов PHP из дистрибутива Debian.
# https://github.com/docker-library/php/pull/542
RUN set -eux; \
	{ \
		echo 'Package: php*'; \
		echo 'Pin: release *'; \
		echo 'Pin-Priority: -1'; \
	} > /etc/apt/preferences.d/no-debian-php

# Зависимости для выполенния phpize.
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev \
		file \
		g++ \
		gcc \
		libc-dev \
		pkg-config \
		re2c

RUN apt-get update && apt-get install -y --no-install-recommends $PHPIZE_DEPS \
	&& rm -r /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d

## Дополнительные библиотеки для PHP.
RUN apt-get update && apt-get install -y --no-install-recommends \
		libmemcached11 \
		libmemcached-dev \
# Для сборки расширения memcached.
		zlib1g-dev \
		 \
	&& rm -r /var/lib/apt/lists/*

# Команда, выполняемая при запуске контейнера.
ENV ENTRYPOINT_COMMAND php

##%%VARIANT%%
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		apache2 \
	&& rm -rf /var/lib/apt/lists/*

RUN usermod --shell $(which bash) www-data

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

RUN set -ex \
	\
# generically convert lines like
#   export APACHE_RUN_USER=www-data
# into
#   : ${APACHE_RUN_USER:=www-data}
#   export APACHE_RUN_USER
# so that they can be overridden at runtime ("-e APACHE_RUN_USER=...")
	&& sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' "$APACHE_ENVVARS" \
	\
# setup directories and permissions
	&& . "$APACHE_ENVVARS" \
	&& for dir in \
		"$APACHE_LOCK_DIR" \
		"$APACHE_RUN_DIR" \
		"$APACHE_LOG_DIR" \
		/var/www/html \
	; do \
		rm -rvf "$dir" \
		&& mkdir -p "$dir" \
		&& chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir"; \
	done

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork

# logs should go to stdout / stderr
RUN set -ex \
	&& . "$APACHE_ENVVARS" \
	&& ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"

# PHP files should be handled by PHP, and should be preferred over any other file type
RUN { \
		echo '<FilesMatch \.php$>'; \
		echo '\tSetHandler application/x-httpd-php'; \
		echo '</FilesMatch>'; \
		echo; \
		echo 'DirectoryIndex disabled'; \
		echo 'DirectoryIndex index.php index.html'; \
		echo; \
		echo '<Directory /var/www/>'; \
		echo '\tOptions -Indexes'; \
		echo '\tAllowOverride All'; \
		echo '</Directory>'; \
	} | tee "$APACHE_CONFDIR/conf-available/docker-php.conf" \
	&& a2enconf docker-php

# Команда, выполняемая при запуске контейнера.
ENV ENTRYPOINT_COMMAND docker-apache-start

# Apply stack smash protection to functions using local buffers and alloca().
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no
# performance impact on x86_64).
# Enable optimization (-O2).
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is
# non-default).
# Adds GNU HASH segments to generated executables (this is used if present, and is much faster than
# sysv hash; in this configuration, sysv hash is also generated).
# https://github.com/docker-library/php/issues/272
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

ENV GPG_KEYS 0BD78B5F97500D450838F95DFE857D9A90D90EC1 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3

ENV PHP_VERSION 5.6.40
ENV PHP_URL="https://secure.php.net/get/php-5.6.40.tar.bz2/from/this/mirror" PHP_ASC_URL="https://secure.php.net/get/php-5.6.40.tar.bz2.asc/from/this/mirror" PHP_FILENAME="php.tar.bz2"
ENV PHP_SHA256="ffd025d34623553ab2f7fd8fb21d0c9e6f9fa30dc565ca03a1d7b763023fba00" PHP_MD5=""

RUN set -xe; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	wget -O ${PHP_FILENAME} "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *${PHP_FILENAME}" | sha256sum -c -; \
	fi; \
	if [ -n "$PHP_MD5" ]; then \
		echo "$PHP_MD5 *${PHP_FILENAME}" | md5sum -c -; \
	fi; \
	\
	if [ -n "$PHP_ASC_URL" ]; then \
		wget -O ${PHP_FILENAME}.asc "$PHP_ASC_URL"; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --no-tty --keyserver ipv4.pool.sks-keyservers.net --recv-keys "$key"; \
		done; \
		gpg --batch --verify ${PHP_FILENAME}.asc ${PHP_FILENAME}; \
		rm -rf "$GNUPGHOME"; \
	fi;

COPY usr/ /usr/
COPY var/ /var/

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
# Для расширения bzip2.
		libbz2-dev \
		libcurl4-openssl-dev \
		libedit-dev \
		libicu-dev \
# Для поддержки JPEG расширением gd.
		libjpeg-dev \
# Для поддержки PNG расширением gd.
		libpng-dev \
# Для поддержки PostgreSQL.
		libpq-dev \
		libsqlite3-dev \
# Для расширения tidy.
		libtidy-dev \
		libxml2-dev \
# Для расширения xsl.
		libxslt1-dev \
# Для расширения zip.
		libzip-dev \
		 libmcrypt-dev libssl1.0-dev apache2-dev \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	export \
		CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
# https://bugs.php.net/bug.php?id=74125
	if [ ! -d /usr/include/curl ]; then \
		ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
	fi; \
	./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
# Неправильные флаги должны прерывать сборку, чтобы их легче было обнаружить.
		--enable-option-checking=fatal \
		\
		--disable-cgi \
		\
# Для правильной работы некоторых функций (например ftp_ssl_connect) расширение ftp должно быть
# собрано статически.
		--enable-ftp \
# Требуется для Composer.
		--enable-hash \
# Требуется для Composer.
		--enable-json \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly
# (see https://github.com/docker-library/php/issues/195).
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions
# are (since it's a plugin for several extensions, not an extension in itself).
		--enable-mysqlnd \
		--enable-pdo \
# Требуется для Composer.
		--enable-phar \
		--with-libedit \
# https://github.com/docker-library/php/issues/439
		--with-mhash \
# Для правильной работы некоторых функций (например ftp_ssl_connect) OpenSSL должен быть собран
# статически.
		--with-openssl=/usr \
		--with-zlib \
		\
		--enable-ctype=shared \
		--enable-dom=shared \
		--enable-exif=shared \
		--enable-fileinfo=shared \
		--enable-filter=shared \
		--enable-intl=shared \
		--enable-pcntl=shared \
		--enable-posix=shared \
		--enable-session \
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
		--with-jpeg-dir=/usr/local \
		--with-mysqli=shared \
		--with-pdo_mysql=shared \
		--with-pdo_pgsql=shared \
		--with-pdo_sqlite=shared,/usr \
		--with-pgsql=shared \
		--with-readline=shared \
		--with-sqlite3=shared \
		--with-tidy=shared \
		--with-xsl=shared \
		 --with-mcrypt=shared --with-mysql=shared --with-apxs2 \
		\
# bundled pcre does not support JIT on s390x
# https://manpages.debian.org/stretch/libpcre3-dev/pcrejit.3.en.html#AVAILABILITY_OF_JIT_SUPPORT
		$(test "$gnuArch" = 's390x-linux-gnu' && echo '--without-pcre-jit') \
		--with-libdir="lib/$debMultiarch" \
	; \
	make -j "$(nproc)"; \
	make install; \
	find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; \
	make clean; \
	cd /; \
	docker-php-source delete; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
	php --version; \
	\
# https://github.com/docker-library/php/issues/443
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc

RUN pecl install --force \
	memcached-2.2.0 \
	xdebug-2.5.5

RUN wget https://getcomposer.org/installer -O - -q \
		| php -- --force --install-dir=/usr/local/bin --filename=composer

## TODO Строчки ниже только для Apache!
ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /var/www/html

EXPOSE 80
CMD ["docker-apache-start"]
