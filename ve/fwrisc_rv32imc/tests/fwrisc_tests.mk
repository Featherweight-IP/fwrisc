
FWRISC_TESTS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

SRC_DIRS += $(FWRISC_TESTS_DIR)/unit
SRC_DIRS += $(FWRISC_TESTS_DIR)/cpp
SRC_DIRS += $(PACKAGES_DIR)/riscv-compliance/riscv-target/spike
SRC_DIRS += $(PACKAGES_DIR)/riscv-compliance/riscv-test-env/p
SRC_DIRS += $(PACKAGES_DIR)/riscv-compliance/riscv-test-env
SRC_DIRS += $(PACKAGES_DIR)/riscv-compliance/riscv-test-suite/rv32i/src
SRC_DIRS += $(PACKAGES_DIR)/riscv-compliance/riscv-test-suite/rv32imc/src

FWRISC_TESTS_SRC := $(notdir $(wildcard $(FWRISC_TESTS_DIR)/cpp/*.cpp))

else # Rules

# $(FWRISC_TESTS_SRC:.cpp=.o) : vl_translate.d

libfwrisc_tests.o : $(FWRISC_TESTS_SRC:.cpp=.o)
	$(Q)$(LD) -r -o $@ $(FWRISC_TESTS_SRC:.cpp=.o)
	

endif
