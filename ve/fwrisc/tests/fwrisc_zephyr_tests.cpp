/*
 * fwrisc_zephyr_tests.cpp
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
 *
 *  Created on: Nov 16, 2018
 *      Author: ballance
 */

#include "fwrisc_zephyr_tests.h"
#include "ElfSymtabReader.h"
#include "GoogletestVlCmdlineProcessor.h"
#include <stdio.h>

fwrisc_zephyr_tests::fwrisc_zephyr_tests() : fwrisc_instr_tests(10000000) {
	m_ram_console = 0;
	m_halt_addr = 0; // Don't halt
}

fwrisc_zephyr_tests::~fwrisc_zephyr_tests() {
	// TODO Auto-generated destructor stub
}

void fwrisc_zephyr_tests::SetUp() {
	const GoogletestVlCmdlineProcessor &clp = GoogletestVlCmdlineProcessor::instance();
	std::string elf_file, v;
	fwrisc_instr_tests::SetUp();

	m_trace_funcs = clp.has_plusarg("+TRACE_FUNCS");
	m_trace_instr = clp.has_plusarg("+TRACE_INSTR");


	clp.get_plusarg_value("+SW_IMAGE", elf_file);

	if (!m_symtab.read(elf_file)) {
		fprintf(stdout, "Error: failed to read elf file\n");
	}

	m_ram_console = m_symtab.find_sym("ram_console").st_value;
	// _Fault is called when the main function returns
	m_halt_addr = m_symtab.find_sym("_Fault").st_value;
	fprintf(stdout, "Ram Console: 0x%08x\n", m_ram_console);
}

void fwrisc_zephyr_tests::regwrite(uint32_t raddr, uint32_t rdata) {

}

void fwrisc_zephyr_tests::exec(uint32_t addr, uint32_t instr) {
	std::string sym;
	if (m_trace_funcs) {
		if (m_symtab.find_sym(addr, sym)) {
			fprintf(stdout, "EXEC: %s (0x%08x)\n", sym.c_str(), addr);
		}
	}
	if (m_trace_instr) {
		fprintf(stdout, "EXEC: 0x%08x\n", addr);
	}

	if (addr == m_halt_addr) {
		fprintf(stdout, "hit halt address 0x%08x\n", m_halt_addr);
		m_end_of_test = true;
		dropObjection(this);
	}
}

void fwrisc_zephyr_tests::memwrite(uint32_t addr, uint8_t mask, uint32_t data) {
//	fprintf(stdout, "WRITE: 0x%08x\n", addr);
	if (addr >= m_ram_console && addr < (m_ram_console+1024)) {
		char ch;
		switch (mask) {
		case 1: ch = ((data >> 0) & 0xFF); break;
		case 2: ch = ((data >> 8) & 0xFF); break;
		case 4: ch = ((data >> 16) & 0xFF); break;
		case 8: ch = ((data >> 24) & 0xFF); break;
		}

		if (ch) {
			m_buffer.push_back(ch);
			if (ch == '\n') {
				m_buffer.push_back(0);
				fputs("# ", stdout);
				fputs(m_buffer.c_str(), stdout);
				fflush(stdout);
				m_console_out.push_back(m_buffer);
				m_buffer.clear();
			}
		}
	}
}

void fwrisc_zephyr_tests::check(const char *exp[], uint32_t exp_sz) {
	ASSERT_EQ(m_end_of_test, true);

	for (uint32_t i=0; i<exp_sz; i++) {
		const char *msg = exp[i];
		bool found = false;

		for (std::vector<std::string>::const_iterator it=m_console_out.begin();
				it!=m_console_out.end(); it++) {
			std::string line = (*it);
			line = line.substr(0, line.size()-2); // Trim the CR

			if (line == msg) {
				found = true;
				break;
			}
		}

		if (!found) {
			fprintf(stdout, "Error: Failed to find msg \"%s\"\n", msg);
		}
		ASSERT_EQ(true, found);
	}
}

TEST_F(fwrisc_zephyr_tests, hello_world) {
	const char *exp[] = {
			"Hello World! fwrisc_sim"
	};

	run(100000);

	check(exp, sizeof(exp)/sizeof(const char *));
}

TEST_F(fwrisc_zephyr_tests, synchronization) {
	const char *exp[] = {
			"Hello World! fwrisc_sim"
	};

	run(1000000);

	check(exp, sizeof(exp)/sizeof(const char *));
}

TEST_F(fwrisc_zephyr_tests, philosophers) {
	const char *exp[] = {
			"An implementation of a solution to the Dining Philosophers"
	};

	run(1000000);

	check(exp, sizeof(exp)/sizeof(const char *));
}

TEST_F(fwrisc_zephyr_tests, coretest) {
	run(100000);

	ASSERT_EQ(m_end_of_test, true);
}

