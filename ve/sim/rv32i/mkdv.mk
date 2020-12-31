
MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= vlsim
MKDV_PLUGINS += cocotb 
RISCV_CC=riscv32-unknown-elf-gcc

MKDV_TEST ?= instr.arith.add

TOP_MODULE = fwrisc_rv32i_tb_hdl

VLSIM_CLKSPEC = clock=10ns

ifeq (,$(SW_IMAGE))
    ifneq (,$(findstring instr,$(subst ., ,$(MKDV_TEST))))
	SW_IMAGE = $(subst .,_,$(subst instr.,,$(MKDV_TEST))).elf
    endif
    ifneq (,$(findstring riscv_compliance,$(subst ., ,$(MKDV_TEST))))
	SW_IMAGE = $(subst .,_,$(subst riscv_compliance.,,$(MKDV_TEST))).elf
    endif
endif

ifeq (,$(MKDV_COCOTB_MODULE))
    ifneq (,$(findstring instr,$(subst ., ,$(MKDV_TEST))))
	MKDV_COCOTB_MODULE = fwrisc_tests.rv32i_instr
    endif
endif

MKDV_RUN_DEPS += $(SW_IMAGE)
MKDV_RUN_ARGS += +sw.image=$(SW_IMAGE)

MKDV_VL_SRCS += $(TEST_DIR)/tb/fwrisc_rv32i_tb_hdl.sv

VLSIM_OPTIONS += -Wno-fatal

include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1

include $(TEST_DIR)/../../common/defs_rules.mk

%.elf : %.S
	$(Q)$(RISCV_CC) -o $@ $^ \
		-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
		-T$(TEST_DIR)/tests/unit/unit.ld

vpath %.S $(TEST_DIR)/tests/unit

