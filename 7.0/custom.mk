##
## Особые настройки для PHP 7.0
##

PHP_EXTRA_BUILD_DEPS += libmcrypt-dev libssl-dev
PHP_EXTRA_CONFIGURE_ARGS += --with-mcrypt=shared
XDEBUG_VERSION := 2.8.1