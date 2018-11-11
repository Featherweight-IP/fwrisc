/*
 * fwrisc_instr_tests_exception.cpp
 *
 *  Created on: Nov 11, 2018
 *      Author: ballance
 */

#include "fwrisc_instr_tests_exception.h"

fwrisc_instr_tests_exception::fwrisc_instr_tests_exception() {
	// TODO Auto-generated constructor stub

}

fwrisc_instr_tests_exception::~fwrisc_instr_tests_exception() {
	// TODO Auto-generated destructor stub
}

TEST_F(fwrisc_instr_tests_exception, j) {
	reg_val_s exp[] = {
			{8, 	4},
			{37, 	0x8000002C}, // MTVEC
			{41,	0x80000018}, // MEPC
			{42,	0x00000000}, // MCAUSE
			{43,	0x80000022}, // MTVAL
	};
	const char *program = R"(
		entry:
			la		x8, _trap_handler 
			csrw	mtvec, x8
			j		1f+2		// Jump will not be taken, since the address is misaligned
		
			li		x8, 4		// When we come back, clear out x8
			j		done
		1:
			li		x8, 26
			j		done
			nop
		_trap_handler:
			csrr	x8, mepc // Increment beyond the faulting instruction
			addi	x8, x8, 4
			csrw	mepc, x8
			mret
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

