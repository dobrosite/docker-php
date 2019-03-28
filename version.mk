##
## Функции для всех вариантов одной версии PHP.
##

ifndef __VERSION_MK
__VERSION_MK := 1

include $(ROOT_DIR)/common.mk



## Версия PHP.
PHP_VERSION := $(notdir $(VERSION_DIR))

## Файлы сборки вариантов.
VARIANT_MAKEFILES=$(wildcard */Makefile)



release: FORCE
	$(ROOT_DIR)/php-release.sh $(PHP_VERSION) >$@

.PHONY: update
update: release $(VARIANT_MAKEFILES) ## Обновляет файлы для сборки образов Docker.
	cd $^ && $(MAKE) update

%/Makefile: $(ROOT_DIR)/src/mk/Makefile.variant
	cp $^ $@

# ifndef __VERSION_MK
endif

