#****************************************************************************
#* Makefile for fwrisc_rv32imc
#****************************************************************************
SCRIPTS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
include $(PACKAGES_DIR)/packages.mk
include $(PACKAGES_DIR)/simscripts/mkfiles/plusargs.mk


MK_INCLUDES += $(SCRIPTS_DIR)/../../tests/fwrisc_rv32imc_tests.mk
MK_INCLUDES += $(SCRIPTS_DIR)/../../tb/vl/fwrisc_rv32imc_tb_vl.mk

MK_INCLUDES += $(GOOGLETEST_HDL)/src/sv/googletest_hdl_sv.mk
MK_INCLUDES += $(GOOGLETEST_HDL)/src/vl/googletest_hdl_vl.mk

RUN_PRE_TARGETS += ram.hex regs.hex

SRC_DIRS += $(SCRIPTS_DIR)/../tb

TB_MODULES_HDL=fwrisc_rv32imc_tb_hdl
TB_MODULES_HVL=fwrisc_rv32imc_tb_hvl

ifeq (vl,$(SIM))
  CXXFLAGS += -I$(BUILDDIR)/obj_dir
  DPI_OBJS_LIBS += libgoogletest-hdl-vl.o libfwrisc_rv32imc_tb_vl.o
endif

DPI_OBJS_LIBS += $(GVM_OBJS_LIBS)
DPI_OBJS_LIBS += libfwrisc_rv32imc_tests.o libgoogletest-hdl.o libgoogletest.o

ifeq (ms,$(SIM))
DPI_OBJS_LIBS += libgoogletest-hdl-sv.o
endif


include $(PACKAGES_DIR)/simscripts/mkfiles/common_sim.mk

regs.hex : $(FWRISC)/rtl/regs.hex
	$(Q)cp $(FWRISC)/rtl/regs.hex .

ifneq (,$(SW_IMAGE))
ram.hex : $(BUILD_DIR)/esw/$(SW_IMAGE)
	$(Q)riscv32-unknown-elf-objcopy $^ -O verilog ram.vlog
	$(Q)perl $(MEMORY_PRIMITIVES)/bin/objcopyvl2vl.pl \
		-width 32 -offset 0x80000000 -le ram.vlog ram.hex
else # No software image
ram.hex :
	# 00007013 -- ANDI
	# 0000_0000_0001_0000_1000_0000_1001_0011 - ADDI 1
	# 1100011
	# 00108093
	$(Q)echo "@00000000" > $@
	$(Q)echo "00108093" >> $@
	$(Q)echo "00108093" >> $@
	$(Q)echo "00108093" >> $@
	$(Q)echo "00108093" >> $@
	$(Q)echo "00108093" >> $@
	$(Q)echo "00108093" >> $@
	$(Q)echo "00108093" >> $@
	$(Q)echo "00108093" >> $@
	$(Q)echo "00108093" >> $@
	$(Q)echo "00108093" >> $@
	$(Q)echo "fc000ce3" >> $@
endif

embedded_sw :
	$(Q)echo SW_IMAGES=$(SW_IMAGES) SW_IMAGE=$(SW_IMAGE)
	$(Q)if test ! -d esw; then mkdir -p esw; fi
	$(Q)$(MAKE) -C esw VERBOSE=$(VERBOSE) \
		-f $(SIM_DIR)/scripts/embedded.mk $(SW_IMAGES)

include $(PACKAGES_DIR)/packages.mk