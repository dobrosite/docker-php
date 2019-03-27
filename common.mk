##
## Функции общего назначения.
##

ifndef __COMMON_MK
__COMMON_MK := 1

ROOT_DIR ?= $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

SHELL = /bin/sh

####
## Обновляет сведения о последнем выпуске указанной версии PHP.
##
## @param $(1) Версия PHP.
##
update-release = $(ROOT_DIR)/php-release.sh $(1) >$(ROOT_DIR)/$(1)/release

.PHONY: help
help: ## Выводит подсказку по доступным целям Make.
	@awk 'BEGIN {FS = ":.*?## "; targets[0] = ""} /^[a-zA-Z_\.-]+:.*?## / \
		{\
			if (!($$1 in targets)) {\
				printf "\033[36m%-20s\033[0m %s\n", $$1, $$2;\
				targets[$$1] = 1;\
			}\
		}' $(MAKEFILE_LIST)

# ifndef __COMMON_MK
endif

############################################
## Цели для версий.
############################################

ifdef VERSION_DIR

## Версия PHP.
PHP_VERSION := $(notdir $(VERSION_DIR))

## Ключи GPG.
DISTRIB_KEYS := $(file < $(VERSION_DIR)/keys)

## Имя образа Docker.
DOCKER_IMAGE := php-$(PHP_VERSION)


####
## Читает указанный файл.
##
## @param $(1) Имя файла.
##
locate = $(or $(realpath $(1)),$(realpath ../$(1)))


ifneq ($(realpath $(VERSION_DIR)/version.mk),)
include $(VERSION_DIR)/version.mk
endif


.PHONY: update-release
update-release: ## Обновляет сведения о последнем выпуске этой версии PHP.
	@echo Обновляю сведения о последнем выпуске PHP $(PHP_VERSION)...
	$(call update-release,$(PHP_VERSION))

############################################
## Цели для вариантов.
############################################

ifdef VARIANT_DIR

## Версия PHP.
VARIANT:=$(notdir $(VARIANT_DIR))

## Папка контекста.
CONTEXT_DIR:=$(VARIANT_DIR)/context


####
## Читает указанный файл.
##
## @param $(1) Имя файла.
##
locate = $(or $(realpath $(1)),$(realpath ../$(1)),$(realpath ../../$(1)))

####
## Заменяет значение переменной в файл.
##
## @param $(1) Имя переменной.
## @param $(2) Значение.
## @param $(3) Файл.
##
replace-in-file = sed -ri -e 's!(%%$(1)%%)!'$(2)'!' "$(3)"

ifeq ($(VARIANT),apache)
include $(ROOT_DIR)/apache.mk
endif


.PHONY: build
build: $(CONTEXT_DIR)/Dockerfile ## Собирает образ.
	docker build -t $(DOCKER_IMAGE) $(CONTEXT_DIR)

.PHONY: clean
clean: ## Удаляет автоматически создаваемые файлы сборки.
	@echo "Удаляю старые файлы..."
	-rm -r $(CONTEXT_DIR)

.PHONY: run
run: ## Запускает оболочку в контейнере.
	docker run -it --rm $(DOCKER_IMAGE) bash

.PHONY: update
update: clean $(CONTEXT_DIR) $(CONTEXT_DIR)/Dockerfile ## Обновляет файлы для сборки образа Docker.
	cp -r $(ROOT_DIR)/context/common/* $(CONTEXT_DIR)/
ifeq ($(VARIANT),apache)
	cp -rf $(ROOT_DIR)/context/apache/* $(CONTEXT_DIR)/
endif

$(CONTEXT_DIR):
	mkdir $@

$(CONTEXT_DIR)/Dockerfile: $(VERSION_DIR)/release
	$(eval $(file < $(VERSION_DIR)/release))
	cat $(ROOT_DIR)/Dockerfile.base >$@
	sed -ri \
		-e 's!%%DOCKER_IMAGE%%!'"$(file < $(call locate,docker_image))"'!' \
		-e 's!%%PHP_VERSION%%!'"$(DISTRIB_RELEASE)"'!' \
		-e 's!%%GPG_KEYS%%!'"$(DISTRIB_KEYS)"'!' \
		-e 's!%%PHP_URL%%!'"$(DISTRIB_URL)"'!' \
		-e 's!%%PHP_FILENAME%%!php.tar.'"$(shell expr match $(DISTRIB_FILENAME) '.*\.\(.*\)')"'!' \
		-e 's!%%PHP_ASC_URL%%!'"$(DISTRIB_URL_ASC)"'!' \
		-e 's!%%PHP_SHA256%%!'"$(DISTRIB_SHA256)"'!' \
		-e 's!%%PHP_MD5%%!'"$(DISTRIB_MD5)"'!' \
		"$@"
ifeq ($(VARIANT),apache)
	sed -i -e '/##\[EXTRAS-START\]##/r $(call locate,Dockerfile.apache)' "$@"
endif
	$(call replace-in-file,PHP_EXTRA_BUILD_DEPS,"$(PHP_EXTRA_BUILD_DEPS)",$@)
	$(call replace-in-file,PHP_EXTRA_CONFIGURE_ARGS,"$(PHP_EXTRA_CONFIGURE_ARGS)",$@)
	$(call replace-in-file,XDEBUG_VERSION,$(XDEBUG_VERSION),$@)

endif # Вариант.

endif # Версия.
