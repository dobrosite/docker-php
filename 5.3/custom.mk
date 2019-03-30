##
## Особые настройки для PHP 5.3
##

MEMCACHED_VERSION := 2.2.0
PHP_EXTRA_BUILD_DEPS += lemon libmcrypt-dev libmysqld-dev libssl-dev
PHP_EXTRA_CONFIGURE_ARGS += --with-mcrypt=shared --with-mysql=shared --with-pdo_sqlite3=shared,/usr --with-sqlite=shared
XDEBUG_VERSION := 2.2.7
