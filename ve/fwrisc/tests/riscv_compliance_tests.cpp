/*
 * riscv_compliance_tests.cpp
 *
 *  Created on: Oct 24, 2018
 *      Author: ballance
 */

#include "riscv_compliance_tests.h"

riscv_compliance_tests::riscv_compliance_tests() {
	m_top = 0;
	m_tfp = 0;
	m_timestamp = 0;
}

riscv_compliance_tests::~riscv_compliance_tests() {
	// TODO Auto-generated destructor stub
}

void riscv_compliance_tests::SetUp() {
	fprintf(stdout, "SetUp\n");
	BaseT::SetUp();

	// Define a 10ns-period clock
	addClock(&top()->clock, 10);
}

TEST_F(riscv_compliance_tests, smoke1) {
	fprintf(stdout, "smoketest1\n");
	run();
}

//TEST_F(riscv_compliance_tests, smoke2) {
//	fprintf(stdout, "smoketest2\n");
//}

