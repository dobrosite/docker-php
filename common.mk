##
## Функции общего назначения.
##

ifndef __COMMON_MK
__COMMON_MK := 1

ROOT_DIR ?= $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

SHELL = /bin/sh


MEMCACHED_VERSION :=
PHP_EXTRA_BUILD_DEPS :=
PHP_EXTRA_CONFIGURE_ARGS :=
PHP_EXTRA_DEPS :=
XDEBUG_VERSION :=


####
## Заменяет значение переменной в файл.
##
## @param $(1) Имя переменной.
## @param $(2) Значение.
## @param $(3) Файл.
##
replace-in-file = sed -ri -e 's!(%%$(1)%%)!'$(2)'!' "$(3)"


.PHONY: help
help: ## Выводит подсказку по доступным целям Make.
	@awk 'BEGIN {FS = ":.*?## "; targets[0] = ""} /^[a-zA-Z_\.-]+:.*?## / \
		{\
			if (!($$1 in targets)) {\
				printf "\033[36m%-20s\033[0m %s\n", $$1, $$2;\
				targets[$$1] = 1;\
			}\
		}' $(MAKEFILE_LIST)

FORCE:

# ifndef __COMMON_MK
endif
