
include $(PACKAGES_DIR)/packages.mk
include $(PACKAGES_DIR)/simscripts/mkfiles/plusargs.mk

RUN_TARGETS += run-sby
INSTRUCTION_CHECKER=$(call get_plusarg,INSTRUCTION_CHECKER,$(PLUSARGS))
DEPTH=$(call get_plusarg,DEPTH,$(PLUSARGS))

ifeq (,$(DEPTH))
DEPTH=8
endif

include $(PACKAGES_DIR)/simscripts/mkfiles/common_sim.mk


ifeq (true,$(QUIET))
REDIRECT= >simx.log 2>&1
else
REDIRECT= | tee simx.log 2>&1
endif

# List of variables to substitute in the .sby file
SBY_VARS += FWRISC INSTRUCTION_CHECKER TESTNAME DEPTH

run-sby :
	$(Q)sed $(SIM_DIR)/scripts/fwrisc_formal.sby \
		$(foreach v,$(SBY_VARS),-e 's%{$(v)}%$($(v))%g') > fwrisc_formal.sby
	$(Q)sby -f fwrisc_formal.sby $(REDIRECT)

include $(PACKAGES_DIR)/packages.mk