
FWRISC_TESTS_DHRYSTONE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

	SRC_DIRS += $(FWRISC_TESTS_DHRYSTONE_DIR)

else # Rules

endif
