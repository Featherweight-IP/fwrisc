
include $(PACKAGES_DIR)/packages.mk
include $(PACKAGES_DIR)/simscripts/mkfiles/plusargs.mk

PLUSARGS += +tool.cocotb

# Ensure cocotb resolves X appropriately when running with signals
COCOTB_RESOLVE_X=ZEROS
export COCOTB_RESOLVE_X

PYTHONPATH:=$(FWRISC)/ve/fwrisc_rv32i/tests/cocotb:$(PYTHONPATH)
PYTHONPATH:=$(FWRISC)/ve/fwrisc_tracer_bfm/src:$(PYTHONPATH)

COCOTB_BFM_MODULES += fwrisc_tracer_bfm

MK_INCLUDES += $(FWRISC)/ve/fwrisc_rv32i/tests/fwrisc_tests.mk

RUN_PRE_TARGETS += ram.hex regs.hex

SRC_DIRS += $(FWRISC)/ve/fwrisc_rv32i/tb
PY_SRC_DIRS += $(FWRISC)/ve/fwrisc_rv32i/tests/pyfv-hpi
PY_SRC_DIRS += $(FWRISC)/ve/fwrisc_tracer_bfm/pyfv-hpi

TB_MODULES_HDL=fwrisc_rv32i_tb_hdl
TB_MODULES_HVL=fwrisc_tb_hvl
PYHPI_CLOCKSPEC=-clk clock=10ns
PYHPI_MODULES += fwrisc_tests
VLSIM_CLOCKSPEC += clock=10ns

SW_IMAGES := $(foreach img,$(call get_plusarg,SW_IMAGE,$(PLUSARGS)),$(subst $(BUILD_DIR)/esw/,,$(img)))
SW_IMAGE := $(firstword $(SW_IMAGES))

ifeq (zephyr.elf,$(notdir $(SW_IMAGE))) 
  SW_IMAGE := $(subst $(BUILD_DIR)/esw/,,$(SW_IMAGE))
endif

ifneq (,$(SW_IMAGES))
  BUILD_PRECOMPILE_TARGETS += embedded_sw
endif


ifeq (vl,$(SIM))
  CXXFLAGS += -I$(BUILDDIR)/obj_dir
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
	$(Q)echo "@00000000" > $@
	$(Q)echo "00007013" >> $@
	$(Q)echo "00007013" >> $@
	$(Q)echo "00007013" >> $@
	$(Q)echo "00007013" >> $@
	$(Q)echo "00007013" >> $@
	$(Q)echo "00007013" >> $@
	$(Q)echo "00007013" >> $@
	$(Q)echo "00007013" >> $@
	$(Q)echo "00007013" >> $@
	$(Q)echo "00007013" >> $@
endif

embedded_sw :
	$(Q)echo SW_IMAGES=$(SW_IMAGES) SW_IMAGE=$(SW_IMAGE)
	$(Q)if test ! -d esw; then mkdir -p esw; fi
	$(Q)$(MAKE) -C esw VERBOSE=$(VERBOSE) \
		-f $(SIM_DIR)/scripts/embedded.mk $(SW_IMAGES)

include $(PACKAGES_DIR)/packages.mk

