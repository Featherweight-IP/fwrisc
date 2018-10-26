/*
 * riscv_compliance_tests.h
 *
 *  Created on: Oct 24, 2018
 *      Author: ballance
 */

#ifndef VE_FWRISC_TESTS_RISCV_COMPLIANCE_TESTS_H_
#define VE_FWRISC_TESTS_RISCV_COMPLIANCE_TESTS_H_
#include "GoogletestVlTest.h"
#include "gtest/gtest.h"
#include "Vfwrisc_tb_hdl.h"
#include "verilated.h"
#include "verilated_lxt2_c.h"
#include <stdint.h>

class riscv_compliance_tests : public GoogletestVlTest<Vfwrisc_tb_hdl> {
public:

	riscv_compliance_tests();

	virtual ~riscv_compliance_tests();

	virtual void SetUp();

private:
	uint64_t			m_timestamp;

};

#endif /* VE_FWRISC_TESTS_RISCV_COMPLIANCE_TESTS_H_ */
