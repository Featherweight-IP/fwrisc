
FWRISC_FPGA_TB_VL_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

ifeq (vl,$(SIM))
SRC_DIRS += $(FWRISC_FPGA_TB_VL_DIR)
endif

FWRISC_TB_VL_SRC_FILES=$(wildcard $(FWRISC_FPGA_TB_VL_DIR)/*.cpp)
FWRISC_TB_VL_SRC=$(notdir $(FWRISC_TB_VL_SRC_FILES))

else # Rules

# Compilation of the testbench wrapper requires the
# translated header files produced by vl_translate.d
libfwrisc_fpga_tb_vl.o : fwrisc_fpga_tb_hdl.cpp vl_translate.d
	$(CXX) -c -o $@ $(CXXFLAGS) $(filter %.cpp,$(^))

endif
