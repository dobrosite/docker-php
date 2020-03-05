##
## Особые настройки для PHP 7.3
##

PHP_EXTRA_DEPS += libargon2-1
PHP_EXTRA_BUILD_DEPS += libargon2-dev libssl-dev libsodium-dev
PHP_EXTRA_CONFIGURE_ARGS += --with-password-argon2 --with-sodium=shared
