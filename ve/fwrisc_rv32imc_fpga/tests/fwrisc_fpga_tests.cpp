/*
 * fwrisc_fpga_tests.cpp
 *
 *  Created on: Nov 21, 2018
 *      Author: ballance
 */

#include "fwrisc_fpga_tests.h"

fwrisc_fpga_tests::fwrisc_fpga_tests() {

	m_led = [&](uint8_t led0, uint8_t led1) { };
	m_max_instr = -1;
	m_instr_count = 0;

}

fwrisc_fpga_tests::~fwrisc_fpga_tests() {
	// TODO Auto-generated destructor stub
}

void fwrisc_fpga_tests::SetUp() {
	const CmdlineProcessor &clp = GoogletestHdl::clp();
	std::string elf_file, v;

	/*
	BaseT::SetUp();
	addClock(top()->clock, 20);
	 */

	fprintf(stdout, "SetUp\n");
	fflush(stdout);

	m_trace_funcs = clp.has_plusarg("+TRACE_FUNCS");
	m_trace_instr = clp.has_plusarg("+TRACE_INSTR");
	m_trace_writes = clp.has_plusarg("+TRACE_WRITES");


	clp.get_plusarg_value("+SW_IMAGE", elf_file);

	if (!m_symtab.read(elf_file)) {
		fprintf(stdout, "Error: failed to read elf file\n");
	}
	/*
	 */

	fwrisc_tracer_bfm_t::bfm("*.u_tracer.u_core")->set_rsp_if(this);

	test = this;
}

void fwrisc_fpga_tests::regwrite(uint32_t raddr, uint32_t rdata) {

}

void fwrisc_fpga_tests::exec(uint32_t addr, uint32_t instr) {
	m_instr_count++;

	if (m_max_instr != -1 && m_instr_count >= m_max_instr) {
			GoogletestHdl::dropObjection();
	}

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

#ifdef UNDEFINED
#endif
	if (m_trace_instr) {
		fprintf(stdout, "EXEC: 0x%08x\n", addr);
	}
}

void fwrisc_fpga_tests::enter_func(uint32_t addr, const std::string &name) {
	if (m_trace_funcs) {
		fprintf(stdout, "%s==> %s\n", m_indent.c_str(), name.c_str());
		fflush(stdout);
		m_indent.append("  ");
	}
}

void fwrisc_fpga_tests::leave_func(uint32_t addr, const std::string &name) {
	if (m_trace_funcs) {
		m_indent = m_indent.substr(0, m_indent.size()-2);
		fprintf(stdout, "%s<== %s\n", m_indent.c_str(), name.c_str());
		fflush(stdout);
	}
}

void fwrisc_fpga_tests::memwrite(uint32_t addr, uint8_t mask, uint32_t data) {
	if (m_trace_writes) {
		fprintf(stdout, "Write: 0x%08x <= 0x%08x (mask=0x%02x)\n", addr, data, mask);
	}
}

void fwrisc_fpga_tests::led(uint8_t led0, uint8_t led1) {
	m_led(led0, led1);
}

TEST_F(fwrisc_fpga_tests, led_flash) {
	uint32_t cnt = 0;

	GoogletestHdl::raiseObjection();
	m_led = [&](uint8_t led0, uint8_t led1) {
		uint32_t exp = (led0 | (led1 << 1));
		cnt++;

		EXPECT_EQ((cnt&3), exp);

		/*
		if (cnt > 16) {
			GoogletestHdl::dropObjection();
		}
		 */
		fprintf(stdout, "led0=%d led1=%d\n", led0, led1);
	};
	fprintf(stdout, "--> run\n");
	GoogletestHdl::run();
	fprintf(stdout, "<-- run\n");
}

TEST_F(fwrisc_fpga_tests, memtest) {
	uint32_t cnt = 0;

	m_max_instr = 1000;

	GoogletestHdl::raiseObjection();
	m_led = [&](uint8_t led0, uint8_t led1) {
		uint32_t exp = (led0 | (led1 << 1));
		cnt++;

		EXPECT_EQ((cnt&3), exp);

		/*
		if (cnt > 16) {
			GoogletestHdl::dropObjection();
		}
		 */
		fprintf(stdout, "led0=%d led1=%d\n", led0, led1);
	};
	fprintf(stdout, "--> run\n");
	GoogletestHdl::run();
	fprintf(stdout, "<-- run\n");
}

TEST_F(fwrisc_fpga_tests, zephyr_hello_world) {
	GoogletestHdl::raiseObjection();
	GoogletestHdl::run();
}

fwrisc_fpga_tests *fwrisc_fpga_tests::test = 0;

//extern "C" int unsigned fwrisc_tracer_bfm_register(const char *path) {
//	fprintf(stdout, "register: %s\n", path);
//	return 0;
//}
//
//extern "C" void fwrisc_tracer_bfm_regwrite(unsigned int id, unsigned int raddr, unsigned int rdata) {
//	fwrisc_fpga_tests::test->regwrite(raddr, rdata);
//}
//
//extern "C" void fwrisc_tracer_bfm_memwrite(unsigned int id, unsigned int addr, unsigned char mask, unsigned int data) {
//	fwrisc_fpga_tests::test->memwrite(addr, mask, data);
//}
//
//extern "C" void fwrisc_tracer_bfm_exec(unsigned int id, unsigned int addr, unsigned int instr) {
//	fwrisc_fpga_tests::test->exec(addr, instr);
//}

extern "C" void fwrisc_fpga_tb_led(uint8_t led0, uint8_t led1) {
	fwrisc_fpga_tests::test->led(led0, led1);
}


