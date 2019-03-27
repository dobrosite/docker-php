ROOT_DIR ?= $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

include $(ROOT_DIR)/common.mk

VERSIONS=$(wildcard ?.?)

FORCE:

.PHONY: update
update: ## Обновляет сведения о последних выпусках.
	$(MAKE) $(foreach version,$(VERSIONS),$(version)/release)

%/release: FORCE
	$(ROOT_DIR)/php-release.sh $* >$@
