#****************************************************************************
#* fwrisc_exec_formal Makefile
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

CORE_SRC_FILES += $(VE_DIR)/../../rtl/fwrisc_exec.sv
CORE_SRC_FILES += $(VE_DIR)/../../rtl/fwrisc_mul_div_shift.sv
CORE_SRC_FILES += $(VE_DIR)/../../rtl/fwrisc_alu.sv
CORE_SRC_FILES += $(VE_DIR)/tb/fwrisc_exec_formal_tb.sv
CORE_SRC_FILES += $(VE_DIR)/tb/$(CHECKER).sv
CORE_SRC_FILES += $(VE_DIR)/tests/$(TESTNAME)_test.sv

IVL_FLAGS += -I $(VE_DIR)/../../rtl -I $(VE_DIR)/tb

VE_DIR := $(abspath $(SIM_DIR)/..)

# List of variables to substitute in the .sby file
SBY_VARS += CHECKER TESTNAME DEPTH VE_DIR MODE CORE_SRC_FILES

run-sby :
	$(Q)sed $(SIM_DIR)/scripts/fwrisc_exec_formal.sby \
		$(foreach v,$(SBY_VARS),-e 's%{$(v)}%$($(v))%g') > fwrisc_exec_formal.sby
	$(Q)sby -f fwrisc_exec_formal.sby $(REDIRECT)

run-sim :
	$(Q)iverilog $(IVL_FLAGS) $(CORE_SRC_FILES)
	$(Q)vvp -l simx.log a.out

include $(PACKAGES_DIR)/packages.mk
