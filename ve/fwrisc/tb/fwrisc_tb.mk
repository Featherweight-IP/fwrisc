
FWRISC_TB_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

FWRISC_TB_SRC_FILES := $(wildcard $(FWRISC_TB_DIR)/*.cpp)
FWRISC_TB_SRC := $(notdir $(FWRISC_TB_SRC_FILES))
SRC_DIRS += $(FWRISC_TB_DIR)

else # Rules

$(FWRISC_TB_SRC:.cpp=.o) : vl_translate.d

libfwrisc_tb.o : $(FWRISC_TB_SRC:.cpp=.o)
	$(Q)echo "FWRISC_TB_SRC_FILES=$(FWRISC_TB_SRC_FILES)"
	$(Q)$(LD) -r -o $@ $(FWRISC_TB_SRC:.cpp=.o)
	
endif
