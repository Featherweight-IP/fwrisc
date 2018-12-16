
include $(PACKAGES_DIR)/packages.mk
include $(PACKAGES_DIR)/simscripts/mkfiles/plusargs.mk

RUN_TARGETS += run-sby
INSTRUCTION_CHECKER=fwrisc_formal_arith_checker
TESTNAME=fwrisc_formal_add_r

include $(PACKAGES_DIR)/simscripts/mkfiles/common_sim.mk


ifeq (true,$(QUIET))
REDIRECT= >simx.log 2>&1
else
REDIRECT= | tee simx.log 2>&1
endif

run-sby :
	$(Q)sed $(SIM_DIR)/scripts/fwrisc_formal.sby \
		-e 's%{FWRISC}%$(FWRISC)%g' \
		-e 's%{INSTRUCTION_CHECKER}%$(INSTRUCTION_CHECKER)%g' \
		-e 's%{TESTNAME}%$(TESTNAME)%g' > fwrisc_formal.sby
	$(Q)sby -f fwrisc_formal.sby $(REDIRECT)

include $(PACKAGES_DIR)/packages.mk