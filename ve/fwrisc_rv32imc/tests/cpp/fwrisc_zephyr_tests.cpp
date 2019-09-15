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

#include <stdio.h>
#include "CmdlineProcessor.h"
#include "ElfSymtabReader.h"

fwrisc_zephyr_tests::fwrisc_zephyr_tests() : fwrisc_ctest_base(10000000) {
	m_ram_console = 0;
	m_raw_console = false;
	m_halt_addr = 0; // Don't halt
	m_msg_listener = [&](const std::string &msg) { }; // Empty
}

fwrisc_zephyr_tests::~fwrisc_zephyr_tests() {
	// TODO Auto-generated destructor stub
}

void fwrisc_zephyr_tests::SetUp() {
	fwrisc_ctest_base::SetUp();

	m_ram_console = m_symtab.find_sym("ram_console").st_value;
	// _Fault is called when the main function returns
	m_halt_addr = m_symtab.find_sym("_Fault").st_value;
	filter_func("char_out");
	filter_func("ram_console_out");
	filter_func("__udivsi3");
	filter_func("__umodsi3");
	filter_func("__mulsi3");
	fprintf(stdout, "Ram Console: 0x%08x\n", m_ram_console);
}

void fwrisc_zephyr_tests::regwrite(uint32_t raddr, uint32_t rdata) {

}

void fwrisc_zephyr_tests::exec(uint32_t addr, uint32_t instr) {
	fwrisc_ctest_base::exec(addr, instr);
//	std::string sym;
//	if (m_trace_funcs) {
//		if (m_symtab.find_sym(addr, sym)) {
//			fprintf(stdout, "EXEC: %s (0x%08x)\n", sym.c_str(), addr);
//		}
//	}
//	if (m_trace_instr) {
//		fprintf(stdout, "EXEC: 0x%08x\n", addr);
//	}
//
//	if (addr == m_halt_addr) {
//		fprintf(stdout, "hit halt address 0x%08x\n", m_halt_addr);
//		m_end_of_test = true;
//		dropObjection(this);
//	}
}

void fwrisc_zephyr_tests::memwrite(uint32_t addr, uint8_t mask, uint32_t data) {
	if (addr >= m_ram_console && addr < (m_ram_console+1024)) {
		char ch;
		switch (mask) {
		case 1: ch = ((data >> 0) & 0xFF); break;
		case 2: ch = ((data >> 8) & 0xFF); break;
		case 4: ch = ((data >> 16) & 0xFF); break;
		case 8: ch = ((data >> 24) & 0xFF); break;
		}

		if (ch) {
			if (m_raw_console) {
				fputc(ch, stdout);
				fflush(stdout);
			}
			if (ch == '\n') {
				if (!m_raw_console) {
					fputs("# ", stdout);
					fputs(m_buffer.c_str(), stdout);
					fputs("\n", stdout);
					fflush(stdout);
				}

				m_msg_listener(m_buffer);
				m_console_out.push_back(m_buffer);
				m_buffer.clear();
			} else {
				m_buffer.push_back(ch);
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

TEST_F(fwrisc_zephyr_tests, dhrystone) {
	const char *exp[] = {
			"Hello World! fwrisc_sim"
	};

	m_msg_listener = [&](const std::string &msg) {
		if (msg == "Hello World! fwrisc_sim") {
			m_end_of_test = true;
			GoogletestHdl::dropObjection();
		}
	};

	run();

	check(exp, sizeof(exp)/sizeof(const char *));
}

TEST_F(fwrisc_zephyr_tests, hello_world) {
	const char *exp[] = {
			"Hello World! fwrisc_sim"
	};

	m_msg_listener = [&](const std::string &msg) {
		if (msg == "Hello World! fwrisc_sim") {
			m_end_of_test = true;
			GoogletestHdl::dropObjection();
		}
	};

	run();

	check(exp, sizeof(exp)/sizeof(const char *));
}

TEST_F(fwrisc_zephyr_tests, synchronization) {
	int threadB_count = 0;
	const char *exp[] = {
			"threadA: Hello World from fwrisc_sim!",
			"threadB: Hello World from fwrisc_sim!"
	};

	m_msg_listener = [&](const std::string &msg) {
		if (msg.substr(0, strlen("threadB")) == "threadB") {
			threadB_count++;
		}

		if (threadB_count >= 2) {
			m_end_of_test = true;
			GoogletestHdl::dropObjection();
		}
	};

	run();

	check(exp, sizeof(exp)/sizeof(const char *));
}

TEST_F(fwrisc_zephyr_tests, philosophers) {
	const char *exp[] = {
			"An implementation of a solution to the Dining Philosophers"
	};

	m_raw_console = true;

	run();

	check(exp, sizeof(exp)/sizeof(const char *));
}

TEST_F(fwrisc_zephyr_tests, ripe) {
	const char *exp[] = {
			"An implementation of a solution to the Dining Philosophers"
	};

//	m_raw_console = true;

	run();

	check(exp, sizeof(exp)/sizeof(const char *));
}

TEST_F(fwrisc_zephyr_tests, coretest) {
	run();

	ASSERT_EQ(m_end_of_test, true);
}

