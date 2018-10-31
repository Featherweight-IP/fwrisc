/*
 * fwrisc_instr_tests.h
 *
 *
 * Copyright 2018 Matthew Ballance
 *
 * Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in
 * writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See
 * the License for the specific language governing
 * permissions and limitations under the License.
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

	void memwrite(uint32_t addr, uint8_t mask, uint32_t data);

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
	std::pair<uint32_t, bool>		m_mem[1024];
};

#endif /* INCLUDED_FWRISC_INSTR_TESTS_H */
