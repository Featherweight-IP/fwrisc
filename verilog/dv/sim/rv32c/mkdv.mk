
MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= vlsim
MKDV_PLUGINS += cocotb pybfms
RISCV_CC=riscv32-unknown-elf-gcc

MKDV_TEST ?= instr.arith.add

MKDV_TIMEOUT ?= 10ms

TOP_MODULE = fwrisc_rv32c_tb

PYBFMS_MODULES += generic_sram_bfms riscv_debug_bfms

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
    ifneq (,$(findstring riscv_compliance,$(subst ., ,$(MKDV_TEST))))
	MKDV_COCOTB_MODULE = fwrisc_tests.rv32i_compliance
	REF_FILE=$(subst .,_,$(subst riscv_compliance.,,$(MKDV_TEST))).reference_output
    endif
endif

ifneq (,$(REF_FILE))
MKDV_RUN_ARGS += +ref.file=$(PACKAGES_DIR)/riscv-compliance/riscv-test-suite/rv32i_m/C/references/$(REF_FILE)
endif

MKDV_RUN_DEPS += $(SW_IMAGE)
MKDV_RUN_ARGS += +sw.image=$(SW_IMAGE)

MKDV_VL_SRCS += $(TEST_DIR)/fwrisc_rv32c_tb.sv

VLSIM_OPTIONS += -Wno-fatal

include $(TEST_DIR)/../../../dbg/defs_rules.mk
include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1

include $(TEST_DIR)/../../../dbg/defs_rules.mk
include $(TEST_DIR)/../../common/defs_rules.mk

%.elf : %.S
	$(Q)$(RISCV_CC) -o $@ $^ -march=rv32ic \
		-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
		-T$(TEST_DIR)/unit/unit.ld

%.elf : $(PACKAGES_DIR)/riscv-compliance/riscv-test-suite/rv32i_m/C/src/%.S
	$(Q)$(RISCV_CC) -o $@ $^ -march=rv32ic \
		-I$(TEST_DIR)/../../common/include \
		-I$(PACKAGES_DIR)/riscv-compliance/riscv-test-env \
		-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
		-T$(TEST_DIR)/../../common/include/linkmono.ld

#		-T$(PACKAGES_DIR)/riscv-compliance/riscv-test-env/p/link.ld

vpath %.S $(TEST_DIR)/unit

