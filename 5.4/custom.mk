##
## Особые настройки для PHP 5.4
##

MEMCACHED_VERSION := 2.2.0
PHP_EXTRA_BUILD_DEPS += libmcrypt-dev libssl-dev
PHP_EXTRA_CONFIGURE_ARGS += --with-mcrypt=shared --with-mysql=shared
XDEBUG_VERSION := 2.4.1
