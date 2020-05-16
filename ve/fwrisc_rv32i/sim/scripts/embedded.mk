
GCC_ARCH:=riscv32-unknown-elf

MK_INCLUDES += $(PACKAGES_DIR)/simscripts/mkfiles/common_tool_gcc.mk
MK_INCLUDES += $(FWRISC)/ve/fwrisc_rv32i/tests/fwrisc_tests.mk

include $(MK_INCLUDES)


CFLAGS += -march=rv32i -mabi=ilp32
ASFLAGS += -march=rv32i -mabi=ilp32

RULES := 1

%.elf : %.o
	$(Q)$(CC) -o $@ $^ \
		-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
		-T$(PACKAGES_DIR)/riscv-compliance/riscv-test-env/p/link.ld
		
zephyr/%/zephyr/zephyr.elf : $(ZEPHYR_BASE)/samples/%/CMakeLists.txt $(wildcard $(ZEPHYR_BASE)/samples/%/src/%.c)
	$(Q)rm -rf zephyr/$*
	$(Q)mkdir -p zephyr/$*
	$(Q)cd zephyr/$* ; cmake -DBOARD=fwrisc_sim -DCMAKE_C_FLAGS="-DSIMULATION_MODE" $(ZEPHYR_BASE)/samples/$*
	$(Q)cd zephyr/$* ; $(MAKE)
	
zephyr_tests/%/zephyr/zephyr.elf : $(FWRISC_TESTS_DIR)/%/CMakeLists.txt $(wildcard $(FWRISC_TESTS_DIR)/%/src/%.c)
	$(Q)rm -rf zephyr_tests/$*
	$(Q)mkdir -p zephyr_tests/$*
	$(Q)cd zephyr_tests/$* ; cmake -DBOARD=fwrisc_sim $(FWRISC_TESTS_DIR)/$*
	$(Q)cd zephyr_tests/$* ; $(MAKE)

	
unit/%.elf : %.o
	$(Q)if test ! -d `dirname $@`; then mkdir -p `dirname $@`; fi
	$(Q)$(CC) -o $@ $^ \
		-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
		-T$(FWRISC_TESTS_DIR)/unit/unit.ld

include $(MK_INCLUDES)
