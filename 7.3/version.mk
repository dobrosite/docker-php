##
## Особые настройки PHP 7.3
##

PHP_EXTRA_BUILD_DEPS += libsodium-dev
PHP_EXTRA_CONFIGURE_ARGS += --with-sodium=shared
XDEBUG_VERSION=2.7.0beta1
