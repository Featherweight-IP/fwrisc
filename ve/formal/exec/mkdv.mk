MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= sby

MKDV_TEST ?= i32_btype
SBY_MODE ?= cover
SBY_DEPTH ?= 64


TOP_MODULE = fwrisc_exec_formal_tb

MKDV_VL_INCDIRS += $(TEST_DIR)/tests $(TEST_DIR)/tb
MKDV_VL_SRCS += $(TEST_DIR)/tests/fwrisc_exec_formal_$(MKDV_TEST)_test.sv
MKDV_VL_SRCS += $(TEST_DIR)/tb/fwrisc_exec_formal_$(MKDV_TEST)_checker.sv
MKDV_VL_SRCS += $(TEST_DIR)/tb/fwrisc_exec_formal_tb.sv


include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1


include $(TEST_DIR)/../../common/defs_rules.mk

