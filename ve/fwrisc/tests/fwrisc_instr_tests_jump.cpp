/*
 * fwrisc_instr_tests_jump.cpp
 *
 *  Created on: Nov 10, 2018
 *      Author: ballance
 */

#include "fwrisc_instr_tests_jump.h"

fwrisc_instr_tests_jump::fwrisc_instr_tests_jump() {
	// TODO Auto-generated constructor stub

}

fwrisc_instr_tests_jump::~fwrisc_instr_tests_jump() {
	// TODO Auto-generated destructor stub
}

TEST_F(fwrisc_instr_tests_jump, j) {
	reg_val_s exp[] = {
			{3, 4},
			{4, 5},
			{5, 6}
	};
	const char *program = R"(
		entry:
			j		1f
			lui		x2, 26
			lui		x2, 26
		1:
			li		x3, 4
			j		2f
			nop
			nop
		1:
			li		x4, 5
			j		done
		2:
			li		x5, 6
			j		1b
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_jump, jal) {
	reg_val_s exp[] = {
			{1, 0},
			{3, 0},
			{4, 4}
	};
	const char *program = R"(
		entry:
			jal		x1, 1f
			lui		x2, 26
			lui		x2, 26
		1:
			la		x3, entry
			sub		x4, x1, x3
			li		x1, 0
			li		x3, 0
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_jump, jalr) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0},
			{3, 0},
			{4, 12}
	};
	const char *program = R"(
		entry:
			la		x2, 1f // la is a two-word instruction (0x08, 0x0C)
			jalr	x1, x2 // 0x10: R[1] <= 0x14
			lui		x2, 26
			lui		x2, 26
		1:
			la		x3, entry // 0x1c
			sub		x4, x1, x3
			li		x1, 0
			li		x2, 0
			li		x3, 0
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_jump, jalr_off_pos) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0},
			{3, 0},
			{4, 0x10}
	};
	const char *program = R"(
		entry:
			la		x2, 1f // la is a two-word instruction (0x08, 0x0C)
			addi	x2, x2, -4 // We'll add in the offset now
			jalr	x1, 4(x2) // 0x14: R[1] <= 0x18
			lui		x2, 26
			lui		x2, 26
		1:
			la		x3, entry // 0x1c
			sub		x4, x1, x3
			li		x1, 0
			li		x2, 0
			li		x3, 0
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_jump, jalr_off_neg) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0},
			{3, 0},
			{4, 0x10}
	};
	const char *program = R"(
		entry:
			la		x2, 1f // la is a two-word instruction (0x08, 0x0C)
			addi	x2, x2, 4  // 0x10: We'll offset next
			jalr	x1, -4(x2) // 0x14: R[1] <= 0x18
			lui		x2, 26     // 0x18
			lui		x2, 26     // 0x1C
		1:
			la		x3, entry // 0x20
			sub		x4, x1, x3
			li		x1, 0
			li		x2, 0
			li		x3, 0
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}


