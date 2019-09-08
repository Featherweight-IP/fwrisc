

fwrisc_rv32imc_TB_VL_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

ifeq (vl,$(SIM))
SRC_DIRS += $(fwrisc_rv32imc_TB_VL_DIR)
endif

fwrisc_rv32imc_TB_VL_SRC_FILES=$(wildcard $(fwrisc_rv32imc_TB_VL_DIR)/*.cpp)
fwrisc_rv32imc_TB_VL_SRC=$(notdir $(fwrisc_rv32imc_TB_VL_SRC_FILES))

else # Rules

# Compilation of the testbench wrapper requires the
# translated header files produced by vl_translate.d
libfwrisc_rv32imc_tb_vl.o : fwrisc_rv32imc_tb_hdl.cpp vl_translate.d
	$(Q)$(CXX) -c -o $@ $(CXXFLAGS) $(filter %.cpp,$(^))

endif
