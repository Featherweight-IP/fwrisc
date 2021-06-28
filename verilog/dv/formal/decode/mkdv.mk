MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= sby

MKDV_TEST ?= i32_btype
SBY_MODE ?= cover
SBY_DEPTH ?= 64

SBY_OPTIONS += mode=$(SBY_MODE) depth=$(SBY_DEPTH)

MKDV_TESTS += i32_btype i32_itype i32_lui i32_rtype

ifeq (,$(findstring $(MKDV_TEST),$(MKDV_TESTS)))
MKDV_TEST = "unknown_test:$(MKDV_TEST)"
endif

TOP_MODULE = fwrisc_decode_formal_tb

MKDV_VL_INCDIRS += $(TEST_DIR)/tests
MKDV_VL_SRCS += $(TEST_DIR)/tests/fwrisc_decode_formal_$(MKDV_TEST)_test.sv
MKDV_VL_SRCS += $(TEST_DIR)/tb/fwrisc_decode_formal_$(MKDV_TEST)_checker.sv
MKDV_VL_SRCS += $(TEST_DIR)/tb/fwrisc_decode_formal_tb.sv


include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1


include $(TEST_DIR)/../../common/defs_rules.mk

