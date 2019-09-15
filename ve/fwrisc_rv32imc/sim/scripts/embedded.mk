
GCC_ARCH:=riscv32-unknown-elf

MK_INCLUDES += $(PACKAGES_DIR)/simscripts/mkfiles/common_tool_gcc.mk
MK_INCLUDES += $(FWRISC)/ve/fwrisc_rv32imc/tests/fwrisc_tests.mk

include $(MK_INCLUDES)


CFLAGS += -march=rv32i -mabi=ilp32
ASFLAGS += -march=rv32i -mabi=ilp32

RULES := 1

%.elf : %.o
	$(Q)$(CC) -o $@ $^ \
		-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
		-T$(FWRISC_TESTS_DIR)/riscv-compliance/riscv-test-env/p/link.ld
		
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

ripe_1/zephyr/zephyr.elf : $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe/CMakeLists.txt $(wildcard $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe/src/*.c)
	$(Q)rm -rf ripe_1 ripe_src_1
	$(Q)mkdir -p ripe_1
	$(Q)cp -r $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe ripe_src_1 
	$(Q)sed -i -e 's/#define ATTACK_NR.*\$$/#define ATTACK_NR 1/g' ripe_src_1/src/ripe_attack_generator.c
	$(Q)sed -i -e 's/3.13.1/3.12.4/g' ripe_src_1/CMakeLists.txt
	$(Q)cd ripe_1 ; cmake -DBOARD=fwrisc_sim ../ripe_src_1
	$(Q)cd ripe_1 ; $(MAKE)

ripe_2/zephyr/zephyr.elf : $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe/CMakeLists.txt $(wildcard $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe/src/*.c)
	$(Q)rm -rf ripe_2 ripe_src_2
	$(Q)mkdir -p ripe_2
	$(Q)cp -r $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe ripe_src_2 
	$(Q)sed -i -e 's/#define ATTACK_NR.*\$$/#define ATTACK_NR 1/g' ripe_src_2/src/ripe_attack_generator.c
	$(Q)sed -i -e 's/3.13.1/3.12.4/g' ripe_src_2/CMakeLists.txt
	$(Q)cd ripe_2 ; cmake -DBOARD=fwrisc_sim ../ripe_src_2
	$(Q)cd ripe_2 ; $(MAKE)

ripe_3/zephyr/zephyr.elf : $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe/CMakeLists.txt $(wildcard $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe/src/*.c)
	$(Q)rm -rf ripe_3 ripe_src_3
	$(Q)mkdir -p ripe_3
	$(Q)cp -r $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe ripe_src_3 
	$(Q)sed -i -e 's/#define ATTACK_NR.*\$$/#define ATTACK_NR 1/g' ripe_src_3/src/ripe_attack_generator.c
	$(Q)sed -i -e 's/3.13.1/3.12.4/g' ripe_src_3/CMakeLists.txt
	$(Q)cd ripe_3 ; cmake -DBOARD=fwrisc_sim ../ripe_src_3
	$(Q)cd ripe_3 ; $(MAKE)

ripe_4/zephyr/zephyr.elf : $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe/CMakeLists.txt $(wildcard $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe/src/*.c)
	$(Q)rm -rf ripe_4 ripe_src_4
	$(Q)mkdir -p ripe_4
	$(Q)cp -r $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe ripe_src_4 
	$(Q)sed -i -e 's/#define ATTACK_NR.*\$$/#define ATTACK_NR 1/g' ripe_src_4/src/ripe_attack_generator.c
	$(Q)sed -i -e 's/3.13.1/3.12.4/g' ripe_src_4/CMakeLists.txt
	$(Q)cd ripe_4 ; cmake -DBOARD=fwrisc_sim ../ripe_src_4
	$(Q)cd ripe_4 ; $(MAKE)

ripe_5/zephyr/zephyr.elf : $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe/CMakeLists.txt $(wildcard $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe/src/*.c)
	$(Q)rm -rf ripe_5 ripe_src_5
	$(Q)mkdir -p ripe_5
	$(Q)cp -r $(PACKAGES_DIR)/RISC-V-IoT-Contest/ripe ripe_src_5 
	$(Q)sed -i -e 's/#define ATTACK_NR.*\$$/#define ATTACK_NR 1/g' ripe_src_5/src/ripe_attack_generator.c
	$(Q)sed -i -e 's/3.13.1/3.12.4/g' ripe_src_5/CMakeLists.txt
	$(Q)cd ripe_5 ; cmake -DBOARD=fwrisc_sim ../ripe_src_5
	$(Q)cd ripe_5 ; $(MAKE)
	
unit/%.elf : %.o
	$(Q)if test ! -d `dirname $@`; then mkdir -p `dirname $@`; fi
	$(Q)$(CC) -o $@ $^ \
		-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
		-T$(FWRISC_TESTS_DIR)/unit/unit.ld

include $(MK_INCLUDES)
