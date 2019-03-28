VERSION_DIR := $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
ROOT_DIR := $(realpath $(dir $(VERSION_DIR)))
ifneq ($(realpath $(VERSION_DIR)/custom.mk),)
include $(VERSION_DIR)/custom.mk
endif
include $(ROOT_DIR)/version.mk
