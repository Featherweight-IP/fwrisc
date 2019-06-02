/*
 * fwrisc_instr_tests_counters.cpp
 *
 *  Created on: Nov 18, 2018
 *      Author: ballance
 */

#include "fwrisc_instr_tests_counters.h"

fwrisc_instr_tests_counters::fwrisc_instr_tests_counters() : fwrisc_instr_tests(100000) {
	// TODO Auto-generated constructor stub

}

fwrisc_instr_tests_counters::~fwrisc_instr_tests_counters() {
	// TODO Auto-generated destructor stub
}

TEST_F(fwrisc_instr_tests_counters, cycle) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0x04},
			{3, 0x03},
			{4, 0x02},
			{5, 0x01},
	};
	const char *program = R"(
		entry:
			li		x1, 0x4000
		1:
			addi	x1, x1, -1
			bne		x1, x0, 1b

			csrr	x2, mcycle
			
			j		done
		data:
			.word 0x01020304
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

