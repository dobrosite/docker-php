##
## Особые настройки для PHP 5.5
##

PHP_EXTRA_BUILD_DEPS += libmcrypt-dev libssl1.0-dev
PHP_EXTRA_CONFIGURE_ARGS += --with-mcrypt=shared --with-mysql=shared
XDEBUG_VERSION := 2.5.5
