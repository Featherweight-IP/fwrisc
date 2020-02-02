
FWRISC_TESTS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

SRC_DIRS += $(FWRISC_TESTS_DIR)/unit
SRC_DIRS += $(PACKAGES_DIR)/riscv-compliance/riscv-target/spike
SRC_DIRS += $(PACKAGES_DIR)/riscv-compliance/riscv-test-env/p
SRC_DIRS += $(PACKAGES_DIR)/riscv-compliance/riscv-test-env
SRC_DIRS += $(PACKAGES_DIR)/riscv-compliance/riscv-test-suite/rv32i/src

else # Rules

endif
