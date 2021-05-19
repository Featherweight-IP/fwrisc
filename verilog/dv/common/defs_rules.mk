
DV_COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
FWRISC_DIR := $(abspath $(DV_COMMON_DIR)/../../..)
PACKAGES_DIR := $(FWRISC_DIR)/packages
EMBENCH_DIR := $(PACKAGES_DIR)/embench-iot
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python3 -m mkdv mkfile)

ifneq (1,$(RULES))

# MKDV_VL_INCDIRS += $(PACKAGES_DIR)/fwprotocol-defs/src/sv

MKDV_PYTHONPATH += $(DV_COMMON_DIR)/python

PATH:=$(PACKAGES_DIR)/python/bin:$(PATH)
export PATH

include $(PACKAGES_DIR)/fw-local-intc/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-interconnect/verilog/rtl/defs_rules.mk
include $(PACKAGES_DIR)/fw-wishbone-sram-ctrl/verilog/rtl/defs_rules.mk
include $(FWRISC_DIR)/verilog/rtl/defs_rules.mk

include $(DV_MK)

else # Rules

include $(DV_MK)

endif
