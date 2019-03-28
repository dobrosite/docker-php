VARIANT_DIR := $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
VERSION_DIR := $(realpath $(dir $(VARIANT_DIR)))
ROOT_DIR := $(realpath $(dir $(VERSION_DIR)))
ifneq ($(realpath $(VARIANT_DIR)/custom.mk),)
include $(VARIANT_DIR)/custom.mk
endif
include $(ROOT_DIR)/variant.mk
