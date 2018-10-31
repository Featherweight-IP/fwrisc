/*
 * fwrisc_instr_tests_branch.cpp
 *
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
 *  Created on: Oct 29, 2018
 *      Author: ballance
 */

#include "fwrisc_instr_tests_branch.h"

fwrisc_instr_tests_branch::fwrisc_instr_tests_branch() {
	// TODO Auto-generated constructor stub

}

fwrisc_instr_tests_branch::~fwrisc_instr_tests_branch() {
	// TODO Auto-generated destructor stub
}

TEST_F(fwrisc_instr_tests_branch, beq_t_fwd) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 5
			beq		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, beq_t_back) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			j		t_start
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
		t_start:
			li		x1, 5
			li		x2, 5
			beq		x1, x2, 1b
		2: // fail
			li		x3, 20
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, beq_f_fwd) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			beq		x1, x2, 1f
			li		x3, 24
			j		done
		1:
			li		x3, 20
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, beq_f_back) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			j		t_start
			li		x3, 20
			j		done
		1:
			li		x3, 20
			j		done
		t_start:
			li		x1, 5
			li		x2, 6
			beq		x1, x2, 1b
		2: // pass: x1!=x2
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, bge_eq_t_pos) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 5
			bge		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, bge_gt_t_pos) {
	reg_val_s exp[] = {
			{1, 6},
			{2, 5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 6
			li		x2, 5
			bge		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, bge_gt_t_neg) {
	reg_val_s exp[] = {
			{1, -5},
			{2, -6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, -5
			li		x2, -6
			bge		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, bge_eq_t_neg) {
	reg_val_s exp[] = {
			{1, -5},
			{2, -5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, -5
			li		x2, -5
			bge		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, blt_t_pos) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			blt		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, blt_t_neg) {
	reg_val_s exp[] = {
			{1, -6},
			{2, -5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, -6
			li		x2, -5
			blt		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, bltu_t_pos) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			bltu	x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, bltu_t_neg) {
	reg_val_s exp[] = {
			{1, 0x80000000},
			{2, 0x80000001},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 0x80000000
			li		x2, 0x80000001
			bltu	x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, bne_t_fwd) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			bne		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, bne_t_back) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			j		t_start
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
		t_start:
			li		x1, 5
			li		x2, 6
			bne		x1, x2, 1b
		2: // fail
			li		x3, 20
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, bne_f_fwd) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 5
			bne		x1, x2, 1f
			li		x3, 24
			j		done
		1:
			li		x3, 20
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_branch, bne_f_back) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			j		t_start
			li		x3, 20
			j		done
		1:
			li		x3, 20
			j		done
		t_start:
			li		x1, 5
			li		x2, 5
			bne		x1, x2, 1b
		2: // pass: x1!=x2
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}
