
FWRISC_TESTS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

SRC_DIRS += $(FWRISC_TESTS_DIR)
SRC_DIRS += $(FWRISC_TESTS_DIR)/unit
SRC_DIRS += $(FWRISC_TESTS_DIR)/riscv-compliance/riscv-target/spike
SRC_DIRS += $(FWRISC_TESTS_DIR)/riscv-compliance/riscv-test-env/p
SRC_DIRS += $(FWRISC_TESTS_DIR)/riscv-compliance/riscv-test-env
SRC_DIRS += $(FWRISC_TESTS_DIR)/riscv-compliance/riscv-test-suite/rv32i/src

FWRISC_TESTS_SRC := $(notdir $(wildcard $(FWRISC_TESTS_DIR)/*.cpp))

else # Rules

# $(FWRISC_TESTS_SRC:.cpp=.o) : vl_translate.d

libfwrisc_tests.o : $(FWRISC_TESTS_SRC:.cpp=.o)
	$(Q)$(LD) -r -o $@ $(FWRISC_TESTS_SRC:.cpp=.o)
	

endif
