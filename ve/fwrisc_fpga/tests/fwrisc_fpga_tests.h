/*
 * fwrisc_fpga_tests.h
 *
 *  Created on: Nov 21, 2018
 *      Author: ballance
 */

#ifndef INCLUDED_FWRISC_FPGA_TESTS_H
#define INCLUDED_FWRISC_FPGA_TESTS_H
#include "Vfwrisc_fpga_tb_hdl.h"
#include "GoogletestVlTest.h"

class fwrisc_fpga_tests : public GoogletestVlTest<Vfwrisc_fpga_tb_hdl> {
public:
	fwrisc_fpga_tests();

	virtual ~fwrisc_fpga_tests();

	virtual void SetUp();
};

#endif /* INCLUDED_FWRISC_FPGA_TESTS_H */
