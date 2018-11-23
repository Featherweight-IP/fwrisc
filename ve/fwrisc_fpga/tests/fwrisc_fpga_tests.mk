
FWRISC_FPGA_TESTS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

SRC_DIRS += $(FWRISC_FPGA_TESTS_DIR)

FWRISC_FPGA_TESTS_SRC := $(notdir $(wildcard $(FWRISC_FPGA_TESTS_DIR)/*.cpp))

else # Rules

$(FWRISC_FPGA_TESTS_SRC:.cpp=.o) : vl_translate.d

libfwrisc_fpga_tests.o : $(FWRISC_FPGA_TESTS_SRC:.cpp=.o)
	$(Q)$(LD) -r -o $@ $(FWRISC_FPGA_TESTS_SRC:.cpp=.o)
	

endif
