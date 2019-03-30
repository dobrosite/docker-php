##
## Функции для всех вариантов одной версии PHP.
##

ifndef __VARIANT_MK
__VARIANT_MK := 1

include $(ROOT_DIR)/common.mk

## Вариант сборки.
VARIANT:=$(notdir $(VARIANT_DIR))

## Папка контекста.
CONTEXT_DIR:=$(VARIANT_DIR)/context

## Версия PHP.
PHP_VERSION := $(notdir $(VERSION_DIR))

### Имя образа Docker.
DOCKER_IMAGE := php-$(PHP_VERSION)-$(VARIANT)

### Ключи GPG.
DISTRIB_KEYS := $(file < $(VERSION_DIR)/keys)

ifneq ($(realpath $(VERSION_DIR)/custom.mk),)
include $(VERSION_DIR)/custom.mk
endif
ifneq ($(realpath $(VARIANT_DIR)/custom.mk),)
include $(VARIANT_DIR)/custom.mk
endif
ifeq ($(VARIANT),apache)
include $(ROOT_DIR)/apache.mk
endif



####
## Ищет файл в текущей и родительской папках.
##
## @param $(1) Имя файла.
##
locate = $(or $(realpath $(1)),$(realpath ../$(1)),$(realpath ../../$(1)))



.PHONY: clean
clean: ## Удаляет автоматически создаваемые файлы сборки.
	-rm -r $(CONTEXT_DIR)

.PHONY: build
build: $(CONTEXT_DIR)/Dockerfile ## Собирает образ.
	docker build -t $(DOCKER_IMAGE) $(CONTEXT_DIR)

.PHONY: tests
tests: ## Проверяет собранный образ.
	docker run --volume="$(ROOT_DIR)/tests:/usr/local/tests:ro" $(DOCKER_IMAGE) /usr/local/tests/tests.sh

.PHONY: update
update: clean $(CONTEXT_DIR) $(CONTEXT_DIR)/Dockerfile ## Обновляет файлы для сборки образа Docker.

$(CONTEXT_DIR):
	mkdir $@
	cp -r $(ROOT_DIR)/context/common/* $(CONTEXT_DIR)/
ifneq ($(realpath $(ROOT_DIR)/context/$(VARIANT)),)
	cp -rf $(ROOT_DIR)/context/$(VARIANT)/* $(CONTEXT_DIR)/
endif

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
	sed -i -e '/##%%VARIANT%%/r $(call locate,Dockerfile.apache)' "$@"
endif
	$(call replace-in-file,EXTRA_DEV_DEPS,"$(EXTRA_DEV_DEPS)",$@)
	$(call replace-in-file,PHP_EXTRA_BUILD_DEPS,"$(PHP_EXTRA_BUILD_DEPS)",$@)
	$(call replace-in-file,PHP_EXTRA_CONFIGURE_ARGS,"$(PHP_EXTRA_CONFIGURE_ARGS)",$@)
	$(call replace-in-file,XDEBUG_VERSION,$(if $(XDEBUG_VERSION),-$(XDEBUG_VERSION),),$@)

$(VERSION_DIR)/release: FORCE
	cd $(VERSION_DIR) && $(MAKE) release

# ifndef __VARIANT_MK
endif

