/*
 * fwrisc_ctest_base.h
 *
 *  Created on: Nov 19, 2018
 *      Author: ballance
 */

#ifndef INCLUDED_FWRISC_CTEST_BASE_H
#define INCLUDED_FWRISC_CTEST_BASE_H
#include "fwrisc_instr_tests.h"
#include "ElfSymtabReader.h"
#include <stack>
#include <set>

class fwrisc_ctest_base : public fwrisc_instr_tests {
public:
	fwrisc_ctest_base(uint32_t timeout);
	virtual ~fwrisc_ctest_base();

	virtual void SetUp();

	virtual void exec(uint32_t addr, uint32_t instr);

	void filter_func(const std::string &func) { m_filter_funcs.insert(func); }

protected:
	ElfSymtabReader										m_symtab;

	bool												m_trace_funcs;
	bool												m_trace_instr;

	std::stack<std::pair<Elf32_Addr,Elf32_Addr>>		m_call_stack;
	std::set<std::string>								m_filter_funcs;
	std::string											m_indent;

};

#endif /* INCLUDED_FWRISC_CTEST_BASE_H */
