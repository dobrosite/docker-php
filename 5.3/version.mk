##
## Особые настройки PHP 7.3
##

PHP_EXTRA_BUILD_DEPS += libicu-dev libsodium-dev
PHP_EXTRA_CONFIGURE_ARGS += --with-sodium=shared
