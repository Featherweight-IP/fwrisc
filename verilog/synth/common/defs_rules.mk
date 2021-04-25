
FWRISC_VL_COMMONDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
FWRISC_DIR := $(abspath $(FWRISC_VL_COMMONDIR)/../../..)
PACKAGES_DIR := $(FWRISC_DIR)/packages
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python -m mkdv mkfile)


ifneq (1,$(RULES))

QUARTUS_FAMILY ?= "Cyclone V"
QUARTUS_DEVICE ?= 5CGXFC7C7F23C8

#QUARTUS_FAMILY ?= "Cyclone 10 LP"
#QUARTUS_DEVICE ?= 10CL025YE144A7G

include $(FWRISC_DIR)/verilog/rtl/defs_rules.mk
include $(DV_MK)
else # Rules

include $(FWRISC_DIR)/verilog/rtl/defs_rules.mk
include $(DV_MK)
endif
