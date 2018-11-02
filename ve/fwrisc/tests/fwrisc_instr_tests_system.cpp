/*
 * fwrisc_instr_tests_system.cpp
 *
 * Copyright 2018 Matthew Ballance
 *
 * Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in
 * writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See
 * the License for the specific language governing
 * permissions and limitations under the License.
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

TEST_F(fwrisc_instr_tests_system, ecall) {
	reg_val_s exp[] = {
		{1, 0},
		{2, 25},
		{0x25, 0} // MTVEC
	};

	const char *program = R"(
		entry:
			la			x1, pass
			csrw		mtvec, x1
			ecall
			j			done
		pass:
			li			x1, 0
			li			x2, 25
			csrw		mtvec, x1
			j			done
	)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_system, eret) {
	reg_val_s exp[] = {
		{1, 0},
		{2, 25},
		{0x29, 0}
	};

	const char *program = R"(
		entry:
			la			x1, pass
			csrw		mepc, x1
			mret
			j			done
		pass:
			li			x1, 0
			li			x2, 25
			csrw		mepc, x1
			j			done
	)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}
