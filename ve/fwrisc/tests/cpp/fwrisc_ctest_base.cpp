/*
 * fwrisc_ctest_base.cpp
 *
 *  Created on: Nov 19, 2018
 *      Author: ballance
 */

#include "fwrisc_ctest_base.h"

#include <stdio.h>
#include "CmdlineProcessor.h"

fwrisc_ctest_base::fwrisc_ctest_base(uint32_t timeout) : fwrisc_instr_tests(timeout) {
	// TODO Auto-generated constructor stub

}

fwrisc_ctest_base::~fwrisc_ctest_base() {
	// TODO Auto-generated destructor stub
}

void fwrisc_ctest_base::SetUp() {
	const CmdlineProcessor &clp = GoogletestHdl::clp();
	std::string elf_file, v;
	fwrisc_instr_tests::SetUp();

	m_trace_funcs = clp.has_plusarg("+TRACE_FUNCS");
	m_trace_instr = clp.has_plusarg("+TRACE_INSTR");


	clp.get_plusarg_value("+SW_IMAGE", elf_file);

	if (!m_symtab.read(elf_file)) {
		fprintf(stdout, "Error: failed to read elf file\n");
	}

//	m_ram_console = m_symtab.find_sym("ram_console").st_value;
//	// _Fault is called when the main function returns
//	m_halt_addr = m_symtab.find_sym("_Fault").st_value;
//	fprintf(stdout, "Ram Console: 0x%08x\n", m_ram_console);
}

void fwrisc_ctest_base::exec(uint32_t addr, uint32_t instr) {
//	fprintf(stdout, "exec: 0x%08x\n", addr);
	if (m_trace_funcs) {
	if (m_call_stack.size() == 0) {
		// Look for an entry symbol
		int32_t sym_idx;

		if ((sym_idx = m_symtab.find_sym(addr)) != -1) {
			if (sym_idx+1 >= m_symtab.n_syms()) {
				fprintf(stdout, "Error: entering the last symbol in the file\n");
				fflush(stdout);
			}
			const Elf32_Sym &next = m_symtab.get_sym(sym_idx+1);
			const std::string &func = m_symtab.get_sym_name(sym_idx);
			if (m_filter_funcs.find(func) == m_filter_funcs.end()) {
				enter_func(next.st_value, func);
			}
			m_call_stack.push(std::pair<Elf32_Addr,Elf32_Addr>(addr,next.st_value-4));
		}
	} else {
		// We should be in a function
		const std::pair<Elf32_Addr,Elf32_Addr> &func = m_call_stack.top();

		if (addr < func.first || addr > func.second) {
			// We're outside the current function
			int32_t sym_idx;

			if ((sym_idx = m_symtab.find_sym(addr)) != -1) {
				// We jumped to the beginning of a new function
				// Consider this entering a new function
				if (sym_idx+1 >= m_symtab.n_syms()) {
					fprintf(stdout, "Error: entering the last symbol in the file\n");
					fflush(stdout);
				}
				const Elf32_Sym &next = m_symtab.get_sym(sym_idx+1);
				const std::string &func = m_symtab.get_sym_name(sym_idx);
				if (m_filter_funcs.find(func) == m_filter_funcs.end()) {
					enter_func(next.st_value, func);
				}
				m_call_stack.push(std::pair<Elf32_Addr,Elf32_Addr>(addr,next.st_value-4));
			} else {
				sym_idx = m_symtab.find_sym(func.first);
				// Consider this exiting the current scope
				m_call_stack.pop();

				if (m_call_stack.size() > 0) {
					const std::pair<Elf32_Addr,Elf32_Addr> &new_func = m_call_stack.top();

					if (addr >= new_func.first && addr <= new_func.second) {
						const std::string &func = m_symtab.get_sym_name(sym_idx);
						if (m_filter_funcs.find(func) == m_filter_funcs.end()) {
							leave_func(new_func.first, func);
						}
					} else {
//						fprintf(stdout, "Error: left function for unknown scope 0x%08x..0x%08x (0x%08x)\n",
//							new_func.first, new_func.second, addr);
//					fflush(stdout);
					}
				} else {
					fprintf(stdout, "Error: stack is now empty\n");
					fflush(stdout);
				}
			}
		}
	}
	}

//	std::string sym;
//	if (m_trace_funcs) {
//		if (m_symtab.find_sym(addr, sym)) {
//			fprintf(stdout, "EXEC: %s (0x%08x)\n", sym.c_str(), addr);
//		}
//	}
	if (m_trace_instr) {
		fprintf(stdout, "EXEC: 0x%08x 0x%08x\n", addr, instr);
	}

	if (addr == m_halt_addr) {
		fprintf(stdout, "hit halt address 0x%08x\n", m_halt_addr);
		m_end_of_test = true;
		GoogletestHdl::dropObjection();
	}
}

void fwrisc_ctest_base::enter_func(uint32_t addr, const std::string &name) {
	fprintf(stdout, "%s==> %s\n", m_indent.c_str(), name.c_str());
	fflush(stdout);
	m_indent.append("  ");
}

void fwrisc_ctest_base::leave_func(uint32_t addr, const std::string &name) {
	m_indent = m_indent.substr(0, m_indent.size()-2);
	fprintf(stdout, "%s<== %s\n", m_indent.c_str(), name.c_str());
	fflush(stdout);
}

