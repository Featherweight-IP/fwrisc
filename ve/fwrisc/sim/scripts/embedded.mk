
GCC_ARCH:=riscv32-unknown-elf

MK_INCLUDES += $(PACKAGES_DIR)/simscripts/mkfiles/common_tool_gcc.mk
MK_INCLUDES += $(FWRISC)/ve/fwrisc/tests/fwrisc_tests.mk

include $(MK_INCLUDES)


CFLAGS += -march=rv32i -mabi=ilp32
ASFLAGS += -march=rv32i -mabi=ilp32

RULES := 1

%.elf : %.o
	$(Q)$(CC) -o $@ $^ \
		-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
		-T$(FWRISC_TESTS_DIR)/riscv-compliance/riscv-test-env/p/link.ld

include $(MK_INCLUDES)
