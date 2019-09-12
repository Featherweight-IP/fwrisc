#****************************************************************************
#* fwrisc_mem Makefile
#****************************************************************************
include $(PACKAGES_DIR)/packages.mk
include $(PACKAGES_DIR)/simscripts/mkfiles/plusargs.mk

CHECKER=$(call get_plusarg,CHECKER,$(PLUSARGS))
DEPTH=$(call get_plusarg,DEPTH,$(PLUSARGS))
MODE=$(call get_plusarg,MODE,$(PLUSARGS))

ifeq (,$(DEPTH))
DEPTH=32
endif

ifeq (,$(MODE))
MODE=bmc
endif

ifeq (sim,$(MODE))
RUN_TARGETS += run-sim
else
RUN_TARGETS += run-sby
endif

include $(PACKAGES_DIR)/simscripts/mkfiles/common_sim.mk


ifeq (true,$(QUIET))
REDIRECT= >simx.log 2>&1
else
REDIRECT= | tee simx.log 2>&1
endif

VE_DIR := $(abspath $(SIM_DIR)/..)

# TODO: Add source files here
CORE_SRC_FILES += $(VE_DIR)/../../rtl/fwrisc_mem.sv
CORE_SRC_FILES += $(VE_DIR)/tb/fwrisc_mem_tb.sv
CORE_SRC_FILES += $(VE_DIR)/tb/$(CHECKER).sv
CORE_SRC_FILES += $(VE_DIR)/tests/$(TESTNAME)_test.sv

# TODO: Add include paths here
IVL_FLAGS += -I $(VE_DIR)/tb -I $(VE_DIR)/../../rtl


# List of variables to substitute in the .sby file
SBY_VARS += CHECKER TESTNAME DEPTH MODE VE_DIR CORE_SRC_FILES

fwrisc_mem_tb_defines.svh :
	$(Q)echo "\`define TEST_MODULE $(TESTNAME)_test" > $@
	$(Q)echo "\`define CHECKER_MODULE $(CHECKER)" >> $@

run-sby : fwrisc_mem_tb_defines.svh
	$(Q)echo "MODE=\"$(MODE)\""
	$(Q)sed $(SIM_DIR)/scripts/fwrisc_mem.sby \
		$(foreach v,$(SBY_VARS),-e 's%{$(v)}%$($(v))%g') > fwrisc_mem.sby
	$(Q)sby -f fwrisc_mem.sby $(REDIRECT)

run-sim : fwrisc_mem_tb_defines.svh
	 $(Q)iverilog $(IVL_FLAGS) $(CORE_SRC_FILES)
	 $(Q)vvp -l simx.log a.out


include $(PACKAGES_DIR)/packages.mk
