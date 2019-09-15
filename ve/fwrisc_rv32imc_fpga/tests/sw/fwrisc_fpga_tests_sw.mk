
FWRISC_FPGA_TESTS_SW_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

SRC_DIRS += $(FWRISC_FPGA_TESTS_SW_DIR)

else # Rules

endif
