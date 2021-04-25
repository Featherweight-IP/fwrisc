SYNTH_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
MKDV_MK := $(SYNTH_DIR)/mkdv.mk

MKDV_TOOL ?= openlane
YOSYS_SYNTH_CMD ?= synth_ice40 
YOSYS_SYNTH_OPTIONS += -blif $(TOP_MODULE).blif -abc2 -json $(TOP_MODULE).json

QUARTUS_FAMILY ?= "Cyclone V"
QUARTUS_DEVICE ?= 5CGXFC7C7F23C8

#QUARTUS_FAMILY ?= "Cyclone 10 LP"
#QUARTUS_DEVICE ?= 10CL025YE144A7G


TOP_MODULE = fwrisc_mul_fast
SDC_FILE=$(SYNTH_DIR)/$(TOP_MODULE).sdc

include $(MKDV_MKFILE)

include $(SYNTH_DIR)/../common/defs_rules.mk

RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

