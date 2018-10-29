/*
 * fwrisc_instr_tests.h
 *
 *  Created on: Oct 28, 2018
 *      Author: ballance
 */

#ifndef INCLUDED_FWRISC_INSTR_TESTS_H
#define INCLUDED_FWRISC_INSTR_TESTS_H
#include "Vfwrisc_tb_hdl.h"
#include "GoogletestVlTest.h"

class fwrisc_instr_tests : public GoogletestVlTest<Vfwrisc_tb_hdl> {
public:
	fwrisc_instr_tests();

	virtual ~fwrisc_instr_tests();

	virtual void SetUp();
};

#endif /* INCLUDED_FWRISC_INSTR_TESTS_H */
