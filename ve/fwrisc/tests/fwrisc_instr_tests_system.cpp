/*
 * fwrisc_instr_tests_system.cpp
 *
 *  Created on: Oct 31, 2018
 *      Author: ballance
 */

#include "fwrisc_instr_tests_system.h"

fwrisc_instr_tests_system::fwrisc_instr_tests_system() {
	// TODO Auto-generated constructor stub

}

fwrisc_instr_tests_system::~fwrisc_instr_tests_system() {
	// TODO Auto-generated destructor stub
}

TEST_F(fwrisc_instr_tests_system, csrr) {
	reg_val_s exp[] = {
			1, 0
	};

	const char *program = R"(
		entry:
			csrr		x1, mcause

			j			done
	)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_system, csrw) {
	reg_val_s exp[] = {
		{1, 5},
		{2, 5},
		{37, 5}
	};

	const char *program = R"(
		entry:
			li			x1, 5
			csrw		mtvec, x1
			csrr		x2, mtvec

			j			done
	)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

