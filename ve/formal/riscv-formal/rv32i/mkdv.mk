MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= sby

MKDV_TEST ?= jal
SBY_MODE ?= cover
SBY_DEPTH ?= 64

SBY_OPTIONS = mode=bmc expect=pass,fail append=0 depth=81 skip=80
SBY_PREP_OPTIONS += -flatten -nordff

MKDV_TESTS += i32_btype i32_itype i32_lui i32_rtype

RISCV_INSN = $(MKDV_TEST)

MKDV_VL_DEFINES += RISCV_FORMAL RISCV_FORMAL_NRET=1 
MKDV_VL_DEFINES += RISCV_FORMAL_XLEN=32 RISCV_FORMAL_ILEN=32
MKDV_VL_DEFINES += RISCV_FORMAL_RESET_CYCLES=1 
MKDV_VL_DEFINES += RISCV_FORMAL_CHECK_CYCLE=80
MKDV_VL_DEFINES += RISCV_FORMAL_CHANNEL_IDX=0 

MKDV_VL_DEFINES += RISCV_FORMAL_ALIGNED_MEM
ifneq (,$(RISCV_INSN))
MKDV_VL_DEFINES += RISCV_FORMAL_CHECKER=rvfi_insn_check
MKDV_VL_DEFINES += RISCV_FORMAL_INSN_MODEL=rvfi_insn_$(RISCV_INSN)
MKDV_VL_DEFINES += RISCV_FORMAL_INSN_V=\"insn_$(RISCV_INSN).v\"
endif
MKDV_VL_INCDIRS += $(PACKAGES_DIR)/riscv-formal/checks
MKDV_VL_INCDIRS += $(PACKAGES_DIR)/riscv-formal/insns


#ifeq (,$(findstring $(MKDV_TEST),$(MKDV_TESTS)))
#MKDV_TEST = "unknown_test:$(MKDV_TEST)"
#endif

TOP_MODULE = rvfi_testbench

MKDV_VL_SRCS += $(TEST_DIR)/fwrisc_riscv_formal.sv


include $(TEST_DIR)/../../../common/defs_rules.mk

RULES := 1


include $(TEST_DIR)/../../../common/defs_rules.mk

