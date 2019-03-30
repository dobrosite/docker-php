##
## Особые настройки для PHP 7.2
##

EXTRA_DEV_DEPS += libargon2-0
PHP_EXTRA_BUILD_DEPS += libargon2-0-dev libssl-dev libsodium-dev
PHP_EXTRA_CONFIGURE_ARGS += --with-password-argon2 --with-sodium=shared
