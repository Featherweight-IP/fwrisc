/*
 * fwrisc_ctest_base.h
 *
 *  Created on: Nov 19, 2018
 *      Author: ballance
 */

#ifndef INCLUDED_FWRISC_CTEST_BASE_H
#define INCLUDED_FWRISC_CTEST_BASE_H
#include <stack>
#include <set>
#include "ElfSymtabReader.h"
#include "fwrisc_instr_tests.h"

class fwrisc_ctest_base : public fwrisc_instr_tests {
public:
	fwrisc_ctest_base(uint32_t timeout);
	virtual ~fwrisc_ctest_base();

	virtual void SetUp();

	virtual void exec(uint32_t addr, uint32_t instr);

	virtual void regwrite(uint32_t raddr, uint32_t rdata);

	void filter_func(const std::string &func) { m_filter_funcs.insert(func); }

	virtual void enter_func(uint32_t addr, const std::string &name);

	virtual void leave_func(uint32_t addr, const std::string &name);

protected:
	ElfSymtabReader										m_symtab;

	bool												m_trace_funcs;
	bool												m_trace_instr;
	bool												m_trace_regs;

	std::stack<std::pair<Elf32_Addr,Elf32_Addr>>		m_call_stack;
	std::set<std::string>								m_filter_funcs;
	std::string											m_indent;

};

#endif /* INCLUDED_FWRISC_CTEST_BASE_H */
