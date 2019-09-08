

fwrisc_rv32imc_TESTS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

SRC_DIRS += $(fwrisc_rv32imc_TESTS_DIR)
# TODO: Add source directories for each relevant sub-directory

fwrisc_rv32imc_TESTS_SRC := $(notdir $(wildcard $(fwrisc_rv32imc_TESTS_DIR)/*.cpp))

else # Rules


libfwrisc_rv32imc_tests.o : $(fwrisc_rv32imc_TESTS_SRC:.cpp=.o)
	$(Q)$(LD) -r -o $@ $(fwrisc_rv32imc_TESTS_SRC:.cpp=.o)
        

endif