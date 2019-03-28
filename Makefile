ROOT_DIR ?= $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

include $(ROOT_DIR)/common.mk

VERSIONS=$(wildcard ?.?)
VERSION_MAKEFILES=$(foreach version,$(VERSIONS),$(version)/Makefile)
RELEASE_FILES=$(foreach version,$(VERSIONS),$(version)/release)

FORCE:

.PHONY: update
update: $(VERSION_MAKEFILES) $(RELEASE_FILES) ## Обновляет все версии PHP.

%/Makefile: src/mk/Makefile.version
	cp $^ $@

%/release: FORCE
	cd $(ROOT_DIR)/$* && $(MAKE) update
