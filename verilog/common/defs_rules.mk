
FWRISC_VL_COMMONDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
FWRISC_DIR := $(abspath $(FWRISC_VL_COMMONDIR)/../..)
PACKAGES_DIR := $(FWRISC_DIR)/packages
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python -m mkdv mkfile)


ifneq (1,$(RULES))

ifeq (,$(findstring $(FWRISC_VL_COMMONDIR),$(MKDV_INCLUDED_DEFS)))
MKDV_INCLUDED_DEFS += $(FWRISC_VL_COMMONDIR)
endif

include $(DV_MK)
else # Rules

include $(DV_MK)
endif
