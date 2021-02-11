
FWRISC_SWDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifneq (1,$(RULES))
ifeq (,$(findstring $(FWRISC_SWDIR),$(MKDV_INCLUDED_DEFS)))
MKDV_INCLUDED_DEFS += $(FWRISC_SWDIR)
ZEPHYR_MODULES += $(FWRISC_SWDIR)/fwrisc
endif

else # Rules

endif
