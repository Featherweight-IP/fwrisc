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
#include <stack>
#include <set>
#include <string>
#include <functional>
#include "../../fwrisc/tests/cpp/ElfSymtabReader.h"

class fwrisc_fpga_tests : public GoogletestVlTest<Vfwrisc_fpga_tb_hdl> {
public:
	fwrisc_fpga_tests();

	virtual ~fwrisc_fpga_tests();

	virtual void SetUp();

	virtual void regwrite(uint32_t raddr, uint32_t rdata);

	virtual void exec(uint32_t addr, uint32_t instr);

	virtual void memwrite(uint32_t addr, uint8_t mask, uint32_t data);

	virtual void led(uint8_t led0, uint8_t led1);

	void filter_func(const std::string &func) { m_filter_funcs.insert(func); }

public:
	static fwrisc_fpga_tests		*test;

protected:
	ElfSymtabReader										m_symtab;

	bool												m_trace_funcs;
	bool												m_trace_instr;

	std::stack<std::pair<Elf32_Addr,Elf32_Addr>>		m_call_stack;
	std::set<std::string>								m_filter_funcs;
	std::string											m_indent;
	std::function<void (uint8_t,uint8_t)>				m_led;
};

#endif /* INCLUDED_FWRISC_FPGA_TESTS_H */
