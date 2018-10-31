/*
 * fwrisc_instr_tests.cpp
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

#include "fwrisc_instr_tests.h"
#include "AsmTestCompiler.h"

fwrisc_instr_tests::fwrisc_instr_tests() {
	// TODO Auto-generated constructor stub

}

fwrisc_instr_tests::~fwrisc_instr_tests() {
	// TODO Auto-generated destructor stub
}

fwrisc_instr_tests *fwrisc_instr_tests::test = 0;

void fwrisc_instr_tests::SetUp() {
	BaseT::SetUp();

	Vfwrisc_tb_hdl *tbp = static_cast<Vfwrisc_tb_hdl *>(0);
	fprintf(stdout, "offset of clock: %d\n", &tbp->clock);

	test = this;
	m_icount = 0;
	m_end_of_test = false;

	for (uint32_t i=0; i<64; i++) {
		m_regs[i] = std::pair<uint32_t, bool>(0, false);
	}

	for (uint32_t i=0; i<1024; i++) {
		m_mem[i] = std::pair<uint32_t, bool>(0, false);
	}

	raiseObjection(this);

	addClock(top()->clock, 10);
}

void fwrisc_instr_tests::regwrite(uint32_t raddr, uint32_t rdata) {
	m_regs[raddr].first = rdata;
	m_regs[raddr].second = true;
}

void fwrisc_instr_tests::memwrite(uint32_t addr, uint8_t mask, uint32_t data) {
	if ((addr & 0xFFFFF000) == 0x00000000) {
		uint32_t offset = ((addr & 0x00000FFF) >> 2);
		m_mem[offset].first = true; // accessed

		if (mask & 1) {
			m_mem[offset].second &= ~0x000000FF;
			m_mem[offset].second |= (data & 0x000000FF);
		}
		if (mask & 2) {
			m_mem[offset].second &= ~0x0000FF00;
			m_mem[offset].second |= (data & 0x0000FF00);
		}
		if (mask & 4) {
			m_mem[offset].second &= ~0x00FF0000;
			m_mem[offset].second |= (data & 0x00FF0000);
		}
		if (mask & 8) {
			m_mem[offset].second &= ~0xFF000000;
			m_mem[offset].second |= (data & 0xFF000000);
		}
	} else {
		fprintf(stdout, "Error: illegal access to address 0x%08x\n", addr);
		ASSERT_EQ((addr & 0xFFFFF000), 0x00000000);
	}
}

void fwrisc_instr_tests::exec(uint32_t addr, uint32_t instr) {
	if (addr == 0x0000004) {
		fprintf(stdout, "hit 0x4\n");
		m_end_of_test = true;
		dropObjection(this);
	}
	if (++m_icount > 100) {
		fprintf(stdout, "test timeout\n");
		dropObjection(this);
	}
}

void fwrisc_instr_tests::runtest(
		const std::string		&program,
		reg_val_s 				*regs,
		uint32_t 				n_regs) {
	ASSERT_EQ(AsmTestCompiler::compile(testname(), program), true);

	run();
	check(regs, n_regs);
}

void fwrisc_instr_tests::check(reg_val_s *regs, uint32_t n_regs) {
	bool accessed[64];
	ASSERT_EQ(m_end_of_test, true); // Ensure we actually reached the end of the test

	memset(accessed, 0, sizeof(accessed));

	// Perform the affirmative test
	for (uint32_t i=0; i<n_regs; i++) {
		if (!m_regs[regs[i].addr].second) {
			fprintf(stdout, "Error: reg %d was not written\n", regs[i].addr);
		}
		ASSERT_EQ(m_regs[regs[i].addr].second, true); // Ensure we wrote the register
		if (m_regs[regs[i].addr].first != regs[i].val) {
			fprintf(stdout, "Error: reg %d regs.value='h%08x expected='h%08hx\n",
					regs[i].addr, m_regs[regs[i].addr], regs[i].val);
		}
		ASSERT_EQ(m_regs[regs[i].addr].first, regs[i].val);
		accessed[regs[i].addr] = true;
	}

	for (uint32_t i=0; i<64; i++) {
		if (m_regs[i].second != accessed[i]) {
			fprintf(stdout, "Error: reg %d: regs.accessed=%s accessed=%s\n",
					i, (m_regs[i].second)?"true":"false",
					(accessed[i])?"true":"false");
		}
		ASSERT_EQ(m_regs[i].second, accessed[i]);
	}
}

extern "C" int unsigned fwrisc_tracer_bfm_register(const char *path) {
	fprintf(stdout, "register: %s\n", path);
	return 0;
}

extern "C" void fwrisc_tracer_bfm_regwrite(unsigned int id, unsigned int raddr, unsigned int rdata) {
	fwrisc_instr_tests::test->regwrite(raddr, rdata);
}

extern "C" void fwrisc_tracer_bfm_memwrite(unsigned int id, unsigned int addr, unsigned char mask, unsigned int data) {
	fwrisc_instr_tests::test->memwrite(addr, mask, data);
}

extern "C" void fwrisc_tracer_bfm_exec(unsigned int id, unsigned int addr, unsigned int instr) {
	fwrisc_instr_tests::test->exec(addr, instr);
}


TEST_F(fwrisc_instr_tests, lui) {
	reg_val_s exp[] = {
			{1, 0x00005000}
	};
	const char *program = R"(
		entry:
			lui		x1, 5
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, j) {
	reg_val_s exp[] = {
			{3, 4},
			{4, 5},
			{5, 6}
	};
	const char *program = R"(
		entry:
			j		1f
			lui		x2, 26
			lui		x2, 26
		1:
			li		x3, 4
			j		2f
			nop
			nop
		1:
			li		x4, 5
			j		done
		2:
			li		x5, 6
			j		1b
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, jal) {
	reg_val_s exp[] = {
			{1, 0},
			{3, 0},
			{4, 4}
	};
	const char *program = R"(
		entry:
			jal		x1, 1f
			lui		x2, 26
			lui		x2, 26
		1:
			la		x3, entry
			sub		x4, x1, x3
			li		x1, 0
			li		x3, 0
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, jalr) {
	reg_val_s exp[] = {
			{1, 0},
			{2, 0},
			{3, 0},
			{4, 12}
	};
	const char *program = R"(
		entry:
			la		x2, 1f // la is a two-word instruction
			jalr	x1, x2
			lui		x2, 26
			lui		x2, 26
		1:
			la		x3, entry
			sub		x4, x1, x3
			li		x1, 0
			li		x2, 0
			li		x3, 0
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

