FROM php:5.4-apache

RUN apt-get update && apt-get install -y wget git node-cli npm libcurl3-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

## Устанавливаем xdebug.
RUN pecl channel-update pecl.php.net && pecl install --force xdebug-2.4.1 && docker-php-ext-enable xdebug

# Устанавливаем Composer.
RUN wget https://getcomposer.org/installer -O - -q | php -- --force --install-dir=/usr/local/bin --filename=composer

# Файлы, создаваемые веб-сервером, должны быть доступны для изменения вне контейнера.
ARG FILE_OWNER_UID=1000
RUN if id www-data; then \
		usermod --uid ${FILE_OWNER_UID} --shell /bin/sh www-data; \
	else \
		useradd --system --uid ${FILE_OWNER_UID} --user-group --no-create-home www-data; \
	fi

RUN chown www-data /var/www

ENV APACHE_RUN_USER www-data

WORKDIR /var/www/site
