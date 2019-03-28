##
## Функции общего назначения.
##

ifndef __COMMON_MK
__COMMON_MK := 1

ROOT_DIR ?= $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

SHELL = /bin/sh

#####
### Обновляет сведения о последнем выпуске указанной версии PHP.
###
### @param $(1) Версия PHP.
###
#update-release = $(ROOT_DIR)/php-release.sh $(1) >$(ROOT_DIR)/$(1)/release

.PHONY: help
help: ## Выводит подсказку по доступным целям Make.
	@awk 'BEGIN {FS = ":.*?## "; targets[0] = ""} /^[a-zA-Z_\.-]+:.*?## / \
		{\
			if (!($$1 in targets)) {\
				printf "\033[36m%-20s\033[0m %s\n", $$1, $$2;\
				targets[$$1] = 1;\
			}\
		}' $(MAKEFILE_LIST)



####
## Заменяет значение переменной в файл.
##
## @param $(1) Имя переменной.
## @param $(2) Значение.
## @param $(3) Файл.
##
replace-in-file = sed -ri -e 's!(%%$(1)%%)!'$(2)'!' "$(3)"



FORCE:

# ifndef __COMMON_MK
endif
