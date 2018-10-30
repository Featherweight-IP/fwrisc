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
	struct reg_val_s {
		uint32_t	addr;
		uint32_t	val;
	};
public:
	fwrisc_instr_tests();

	virtual ~fwrisc_instr_tests();

	virtual void SetUp();

	void regwrite(uint32_t raddr, uint32_t rdata);

	void exec(uint32_t addr, uint32_t instr);

protected:

	void runtest(
			const std::string 	&program,
			reg_val_s			*regs,
			uint32_t			n_regs);

	void check(reg_val_s *regs, uint32_t n_regs);

public:
	static fwrisc_instr_tests		*test;

private:
	uint32_t						m_icount;
	bool							m_end_of_test;
	std::pair<uint32_t, bool>		m_regs[64];
};

#endif /* INCLUDED_FWRISC_INSTR_TESTS_H */
