
FWRISC_VERILOG_DBGDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifneq (1,$(RULES))

ifeq (,$(findstring $(FWRISC_VERILOG_DBGDIR),$(MKDV_INCLUDED_DEFS)))
PYBFM_MODULES += riscv_dbg_bfm
MKDV_INCLUDED_DEFS += $(FWRISC_VERILOG_DBGDIR)
MKDV_VL_SRCS += $(wildcard $(FWRISC_VERILOG_DBGDIR)/*.v)
MKDV_VL_INCDIRS += $(FWRISC_VERILOG_DBGDIR)
MKDV_VL_DEFINES += FWRISC_DBG_BFM_MODULE=fwrisc_dbg_bfm
endif

else # Rules

endif

