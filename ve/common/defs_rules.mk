
DV_COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
FWRISC_DIR := $(abspath $(DV_COMMON_DIR)/../..)
PACKAGES_DIR := $(FWRISC_DIR)/packages
MKDV_MKFILE := $(shell $(PACKAGES_DIR)/python/bin/python3 -m mkdv mkfile)

ifneq (1,$(RULES))

MKDV_VL_SRCS += $(wildcard $(FWRISC_DIR)/verilog/rtl/*.sv)
MKDV_VL_INCDIRS += $(FWRISC_DIR)/verilog/rtl
MKDV_VL_INCDIRS += $(PACKAGES_DIR)/fwprotocol-defs/src/sv

MKDV_PYTHONPATH += $(DV_COMMON_DIR)/python

PATH:=$(PACKAGES_DIR)/python/bin:$(PATH)
export PATH

include $(MKDV_MKFILE)

else # Rules

include $(MKDV_MKFILE)

endif
