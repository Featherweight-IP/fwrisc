SYNTH_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
MKDV_MK := $(SYNTH_DIR)/mkdv.mk

MKDV_TOOL ?= openlane
YOSYS_SYNTH_CMD ?= synth_ice40 
YOSYS_SYNTH_OPTIONS += -blif $(TOP_MODULE).blif -abc2 -json $(TOP_MODULE).json

TOP_MODULE = fwrisc_regfile_e
#SDC_FILE=$(SYNTH_DIR)/fwrisc_rv32i.sdc

MKDV_VL_SRCS += $(SYNTH_DIR)/fwrisc_regfile_e.sv
include $(SYNTH_DIR)/../common/defs_rules.mk

RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

