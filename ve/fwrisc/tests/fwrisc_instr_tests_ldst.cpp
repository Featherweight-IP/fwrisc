/*
 * fwrisc_instr_tests_ldst.cpp
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
 *  Created on: Oct 30, 2018
 *      Author: ballance
 */

#include "fwrisc_instr_tests_ldst.h"

fwrisc_instr_tests_ldst::fwrisc_instr_tests_ldst() {
	// TODO Auto-generated constructor stub

}

fwrisc_instr_tests_ldst::~fwrisc_instr_tests_ldst() {
	// TODO Auto-generated destructor stub
}

TEST_F(fwrisc_instr_tests_ldst, lb) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0x04},
			{3, 0x03},
			{4, 0x02},
			{5, 0x01},
	};
	const char *program = R"(
		entry:
			la		x1, data
			lb		x2, 0(x1)
			lb		x3, 1(x1)
			lb		x4, 2(x1)
			lb		x5, 3(x1)
			li		x1, 0
			j		done
		data:
			.word 0x01020304
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_ldst, lb_u) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0x04},
			{3, 0x03},
	};
	const char *program = R"(
		entry:
			la		x1, data
			lb		x2, 0(x1)
			lb		x3, 1(x1)
			li		x1, 0
			j		done
		data:
			.word 0x01020304
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_ldst, lb_s) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0xFFFFFF84},
			{3, 0xFFFFFF83},
	};
	const char *program = R"(
		entry:
			la		x1, data
			lb		x2, 0(x1)
			lb		x3, 1(x1)
			li		x1, 0
			j		done
		data:
			.word 0x81828384
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_ldst, lh_u) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0x0304},
			{3, 0x0102},
	};
	const char *program = R"(
		entry:
			la		x1, data
			lh		x2, 0(x1)
			lh		x3, 2(x1)
			li		x1, 0
			j		done
		data:
			.word 0x01020304
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_ldst, lh_s) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0xFFFF8384},
			{3, 0xFFFF8182},
	};
	const char *program = R"(
		entry:
			la		x1, data
			lh		x2, 0(x1)
			lh		x3, 2(x1)
			li		x1, 0
			j		done
		data:
			.word 0x81828384
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_ldst, lhu_s) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0x00008384},
			{3, 0x00008182},
	};
	const char *program = R"(
		entry:
			la		x1, data  // 0x08
			lhu		x2, 0(x1) // 0x0C
			lhu		x3, 2(x1) // 0x10
			li		x1, 0     // 0x14
			j		done
		data:
			.word 0x81828384
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_ldst, lw) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0x01020304},
			{3, 0x05060708},
	};
	const char *program = R"(
		entry:
			la		x1, data
			lw		x2, 0(x1)
			lw		x3, 4(x1)
			li		x1, 0
			j		done
		data:
			.word 0x01020304
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_ldst, sw_lw) {
	reg_val_s exp[] = {
			{1, 0x00000000},
			{2, 0x55aaeeff},
			{3, 0x55aaeeff}
	};
	const char *program = R"(
		entry:
			la		x1, data
			li		x2, 0x55aaeeff
			sw		x2, 0(x1)
			lw		x3, 0(x1)
			li		x1, 0
			j		done
		data:
			.word 0x01020304
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_ldst, sb_lw) {
	reg_val_s exp[] = {
			{1, 0x00000000},
			{2, 0x00000055},
			{3, 0x55aaeeff}
	};
	const char *program = R"(
		entry:
			la		x1, data
			li		x2, 0xff
			sb		x2, 0(x1)
			li		x2, 0xee
			sb		x2, 1(x1)
			li		x2, 0xaa
			sb		x2, 2(x1)
			li		x2, 0x55
			sb		x2, 3(x1)
			lw		x3, 0(x1)
			li		x1, 0
			j		done
		data:
			.word 0x01020304
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_ldst, sh_lw) {
	reg_val_s exp[] = {
			{1, 0x00000000},
			{2, 0x000055aa},
			{3, 0x55aaeeff}
	};
	const char *program = R"(
		entry:
			la		x1, data
			li		x2, 0xeeff
			sh		x2, 0(x1)
			li		x2, 0x55aa
			sh		x2, 2(x1)
			lw		x3, 0(x1)
			li		x1, 0
			j		done
		data:
			.word 0x01020304
			.word 0x05060708
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}
