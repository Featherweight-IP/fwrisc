
LATTICE_ICESTORM_SYNTH_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

SW_APP ?= led_flash
SW_BUILDDIR = build_$(SW_APP)_sw
ZEPHYR_SDK_OBJCOPY=$(ZEPHYR_SDK_INSTALL_DIR)/sysroots/x86_64-pokysdk-linux/usr/bin/riscv32-zephyr-elf/riscv32-zephyr-elf-objcopy

include $(PACKAGES_DIR)/packages.mk

ifneq (true,$(VERBOSE))
Q=@
endif

ifeq (,$(FWRISC))
all :
	$(Q)echo "Error: must source etc/fwrisc_env.sh"
	$(Q)exit 1
else
all : synth.d
endif

synth.d :
	$(Q)rm -rf output
	$(Q)mkdir -p output
	$(Q)cp $(FWRISC)/rtl/* output
	$(Q)cd output ; yosys -p 'synth_ice40 -top fwrisc -blif fwrisc.blif' \
		fwrisc_alu.sv \
		fwrisc_dbus_if.sv \
		fwrisc_comparator.sv \
		fwrisc_tracer.sv \
		fwrisc_regfile.sv \
		fwrisc.sv
	$(Q)touch $@

sw_$(SW_APP).d : $(wildcard $(MICROSEMI_SYNTH_DIR)/sw/$(SW_APP)/src/*)
	$(Q)rm -rf $(SW_BUILDDIR)
	$(Q)mkdir $(SW_BUILDDIR)
	$(Q)cd $(SW_BUILDDIR) ; cmake -DBOARD=fwrisc_sim \
          $(MICROSEMI_SYNTH_DIR)/sw/$(SW_APP)
	$(Q)cd $(SW_BUILDDIR) ; $(MAKE)
	$(Q)cd $(SW_BUILDDIR) ; $(ZEPHYR_SDK_OBJCOPY) \
            zephyr/zephyr.elf -O verilog rom.vlog
	$(Q)cd $(SW_BUILDDIR) ; $(MEMORY_PRIMITIVES)/bin/objcopyvl2vl.pl \
               -width 32 -offset 0x80000000 -le rom.vlog rom.hex

clean :
	rm -rf output *.d

