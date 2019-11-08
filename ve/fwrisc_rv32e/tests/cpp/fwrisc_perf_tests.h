/*
 * fwrisc_perf_tests.h
 *
 *  Created on: Nov 18, 2018
 *      Author: ballance
 */

#ifndef INCLUDED_FWRISC_PER_TESTS_H
#define INCLUDED_FWRISC_PER_TESTS_H
#include "fwrisc_instr_tests.h"

class fwrisc_perf_tests : public fwrisc_instr_tests {
public:
	fwrisc_perf_tests();

	virtual ~fwrisc_perf_tests();

	virtual void regwrite(uint32_t raddr, uint32_t rdata);

	virtual void exec(uint32_t addr, uint32_t instr);

	virtual void memwrite(uint32_t addr, uint8_t mask, uint32_t data);

protected:
	uint32_t					m_instr_count;
	uint32_t					m_mem_writes;

};

#endif /* INCLUDED_FWRISC_PER_TESTS_H */
