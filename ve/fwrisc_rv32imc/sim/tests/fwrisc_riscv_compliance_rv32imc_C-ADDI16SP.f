+SW_IMAGE=${BUILD_DIR}/esw/C-ADDI16SP.elf
+REF_FILE=${PACKAGES_DIR}/riscv-compliance/riscv-test-suite/rv32imc/references/C-ADDI16SP.reference_output
+gtest-filter=riscv_compliance_tests.runtest
+UVM_TESTNAME=fwrisc_riscv_compliance_tests
+hpi.entry=fwrisc_tests.riscv_compliance_main

