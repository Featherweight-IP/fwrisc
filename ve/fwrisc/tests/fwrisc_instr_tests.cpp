/*
 * fwrisc_instr_tests.cpp
 *
 *  Created on: Oct 28, 2018
 *      Author: ballance
 */

#include "fwrisc_instr_tests.h"
#include "AsmTestCompiler.h"

fwrisc_instr_tests::fwrisc_instr_tests() {
	// TODO Auto-generated constructor stub

}

fwrisc_instr_tests::~fwrisc_instr_tests() {
	// TODO Auto-generated destructor stub
}

void fwrisc_instr_tests::SetUp() {
	BaseT::SetUp();

	fprintf(stdout, "offset of clock: %d\n",
			&((Vfwrisc_tb_hdl *)0)->clock);

	addClock(top()->clock, 10);
}

TEST_F(fwrisc_instr_tests, add) {
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			add		x3, x1, x2
			j		done
			)";

	ASSERT_EQ(AsmTestCompiler::compile(testname(), program), true);

	run();

	// TODO: Now, check results
//	ASSERT_EQ(AsmTestCompiler::compile(program), true);
}

