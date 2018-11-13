
include $(PACKAGES_DIR)/packages.mk
include $(PACKAGES_DIR)/simscripts/mkfiles/plusargs.mk

MK_INCLUDES += $(FWRISC)/ve/fwrisc/tb/fwrisc_tb.mk
MK_INCLUDES += $(FWRISC)/ve/fwrisc/tests/fwrisc_tests.mk

RUN_PRE_TARGETS += ram.hex

SRC_DIRS += $(FWRISC)/ve/fwrisc/tb

TB_MODULES_HDL=fwrisc_tb_hdl

SW_IMAGES := $(notdir $(call get_plusarg,SW_IMAGE,$(PLUSARGS)))
SW_IMAGE := $(firstword $(SW_IMAGES))

ifneq (,$(SW_IMAGES))
  BUILD_PRECOMPILE_TARGETS += embedded_sw
endif


ifeq (vl,$(SIM))
  VL_TB_OBJS_LIBS += libfwrisc_tb.o libfwrisc_tests.o libgoogletest-vl.o libgoogletest.o
  CXXFLAGS += -I$(BUILDDIR)/obj_dir
endif

include $(PACKAGES_DIR)/simscripts/mkfiles/common_sim.mk


ifneq (,$(SW_IMAGE))
ram.hex : $(BUILD_DIR)/esw/$(SW_IMAGE)
	$(Q)riscv32-unknown-elf-objcopy $^ -O verilog ram.vlog
	$(Q)perl $(MEMORY_PRIMITIVES)/bin/objcopyvl2vl.pl \
		-width 32 -offset 0x80000000 -le ram.vlog ram.hex
else # No software image
ram.hex :
	$(Q)echo "00000000" > $@
	$(Q)echo "00000000" >> $@
	$(Q)echo "00000000" >> $@
	$(Q)echo "00000000" >> $@
	$(Q)echo "00000000" >> $@
	$(Q)echo "00000000" >> $@
	$(Q)echo "00000000" >> $@
	$(Q)echo "00000000" >> $@
endif

embedded_sw :
	$(Q)echo SW_IMAGES=$(SW_IMAGES)
	$(Q)if test ! -d esw; then mkdir -p esw; fi
	$(Q)$(MAKE) -C esw VERBOSE=$(VERBOSE) \
		-f $(SIM_DIR)/scripts/embedded.mk $(SW_IMAGES)

include $(PACKAGES_DIR)/packages.mk
	
