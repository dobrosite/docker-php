#!/usr/bin/env bash
set -eo pipefail

if [ "${FILE_OWNER_UID}" != "" ]; then
    usermod --uid ${FILE_OWNER_UID} www-data
    chown www-data /var/www
fi

## Включаем затребованные модули Apache.
if [ "${APACHE_MODULES}" != "" ]; then
    a2enmod ${APACHE_MODULES}
fi

## Включаем затребованные расширения PHP.
if [ "${PHP_EXTENSIONS}" != "" ]; then
    docker-php-ext-enable ${PHP_EXTENSIONS}
fi

exec "$@"
