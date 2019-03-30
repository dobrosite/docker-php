VARIANT_DIR := $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
VERSION_DIR := $(realpath $(dir $(VARIANT_DIR)))
ROOT_DIR := $(realpath $(dir $(VERSION_DIR)))
include $(ROOT_DIR)/variant.mk
