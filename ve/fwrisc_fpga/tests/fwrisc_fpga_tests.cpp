/*
 * fwrisc_fpga_tests.cpp
 *
 *  Created on: Nov 21, 2018
 *      Author: ballance
 */

#include "fwrisc_fpga_tests.h"

fwrisc_fpga_tests::fwrisc_fpga_tests() {
	// TODO Auto-generated constructor stub

}

fwrisc_fpga_tests::~fwrisc_fpga_tests() {
	// TODO Auto-generated destructor stub
}

void fwrisc_fpga_tests::SetUp() {
	BaseT::SetUp();
	addClock(top()->clock, 20);
}

TEST_F(fwrisc_fpga_tests, led_flash) {
	raiseObjection(this);
	run(5000000);
}

