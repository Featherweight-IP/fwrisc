/*
 * fwrisc_ripe_tests.cpp
 *
 *  Created on: Aug 12, 2019
 *      Author: ballance
 */

#include "fwrisc_ripe_tests.h"

fwrisc_ripe_tests::fwrisc_ripe_tests() : fwrisc_zephyr_tests() {
	// TODO Auto-generated constructor stub

	m_intrusion_functions.insert("shellcode_target");
	m_intrusion_functions.insert("ret2libc_target");

}

fwrisc_ripe_tests::~fwrisc_ripe_tests() {
	// TODO Auto-generated destructor stub
}

void fwrisc_ripe_tests::SetUp() {
	fwrisc_zephyr_tests::SetUp();
	m_attack_attempted = false;
}

TEST_F(fwrisc_ripe_tests, ripe) {
	run();
}

void fwrisc_ripe_tests::enter_func(uint32_t addr, const std::string &name) {
	fwrisc_zephyr_tests::enter_func(addr, name);

	if (name == "perform_attack") {
		m_attack_attempted = true;
	}

	if (m_intrusion_functions.find(name) != m_intrusion_functions.end()) {
		GoogletestHdl::dropObjection();
		fprintf(stdout, "Note: attack_attempted=%d\n", m_attack_attempted);
		fprintf(stdout, "FAILED: hit intrusion function \"%s\"\n", name.c_str());
		FAIL();
	}
}

void fwrisc_ripe_tests::leave_func(uint32_t addr, const std::string &name) {
	fwrisc_zephyr_tests::leave_func(addr, name);

}
