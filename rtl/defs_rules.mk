
FWRISC_RTLDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))


ifneq (1,$(RULES))

ifeq (,$(findstring $(FWRISC_RTLDIR),$(MKDV_INCLUDED_DEFS)))
MKDV_INCLUDED_DEFS += $(FWRISC_RTLDIR)
MKDV_VL_INCDIR += $(FWRISC_RTLDIR)
MKDV_VL_SRCS += $(wildcard $(FWRISC_RTLDIR)/*.sv)
include $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/defs_rules.mk
endif

else # Rules

endif