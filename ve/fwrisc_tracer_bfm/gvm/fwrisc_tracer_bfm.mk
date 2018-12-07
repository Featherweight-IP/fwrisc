
FWRISC_TRACER_BFM_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifneq (1,$(RULES))

SRC_DIRS += $(FWRISC_TRACER_BFM_DIR)
GVM_OBJS_LIBS += libfwrisc_tracer_bfm.o

FWRISC_TRACER_BFM_SRC = $(notdir $(wildcard $(FWRISC_TRACER_BFM_DIR)/*.cpp))

else # Rules

libfwrisc_tracer_bfm.o : $(FWRISC_TRACER_BFM_SRC:.cpp=.o)
	$(Q)$(LD) -r -o $@ $(FWRISC_TRACER_BFM_SRC:.cpp=.o)

endif
