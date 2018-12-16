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
#include "BfmType.h"
#include "ElfDataReader.h"

fwrisc_instr_tests::fwrisc_instr_tests(uint32_t max_instr) : m_max_instr(max_instr) {
	m_halt_addr = 0x80000004;
	test = this;
}

fwrisc_instr_tests::~fwrisc_instr_tests() {
	// TODO Auto-generated destructor stub
	fprintf(stdout, "fwrisc_instr_tests::~fwrisc_instr_tests\n");
	fflush(stdout);
	test = 0;
}

fwrisc_instr_tests *fwrisc_instr_tests::test = 0;

void fwrisc_instr_tests::SetUp() {
	fprintf(stdout, "--> fwrisc_instr_tests::SetUp\n");
	fflush(stdout);

//	GoogletestHdl::SetUp();

	test = this;
	m_icount = 0;
	m_end_of_test = false;

	for (uint32_t i=0; i<64; i++) {
		m_regs[i] = std::pair<uint32_t, bool>(0, false);
	}

	for (uint32_t i=0; i<1024; i++) {
		m_mem[i] = std::pair<uint32_t, bool>(0, false);
	}

	// Register ourselves as a listener on this BFM
	fwrisc_tracer_bfm_t::bfm("*.u_tracer")->set_rsp_if(this);


	GoogletestHdl::raiseObjection();
	fprintf(stdout, "<-- fwrisc_instr_tests::SetUp\n");
	fflush(stdout);
}

void fwrisc_instr_tests::TearDown() {
	fprintf(stdout, "-- fwrisc_instr_tests::TearDown\n");
	fflush(stdout);
	test = 0;
}

void fwrisc_instr_tests::regwrite(uint32_t raddr, uint32_t rdata) {
	fprintf(stdout, "--> regwrite 0x%02x <= 0x%08x\n", raddr, rdata);
	fflush(stdout);
	if (raddr == 0) {
		fprintf(stdout, "ERROR: writing to $zero\n");
	}
	if (raddr < 64) {
		m_regs[raddr].first = rdata;
		m_regs[raddr].second = true;
	} else {
		fprintf(stdout, "Error: raddr 0x%08x outside 0..63 range\n", raddr);
	}

	fprintf(stdout, "<-- regwrite 0x%02x <= 0x%08x\n", raddr, rdata);
	fflush(stdout);
}

void fwrisc_instr_tests::memwrite(uint32_t addr, uint8_t mask, uint32_t data) {
	fprintf(stdout, "memwrite 0x%08x=0x%08x mask=%02x\n", addr, data, mask);
	fflush(stdout);
	if ((addr & 0xFFFF8000) == 0x80000000) {
		uint32_t offset = ((addr & 0x0000FFFF) >> 2);
		fprintf(stdout, "offset=%d\n", offset);
		m_mem[offset].second = true; // accessed

		if (mask & 1) {
			m_mem[offset].first &= ~0x000000FF;
			m_mem[offset].first |= (data & 0x000000FF);
		}
		if (mask & 2) {
			m_mem[offset].first &= ~0x0000FF00;
			m_mem[offset].first |= (data & 0x0000FF00);
		}
		if (mask & 4) {
			m_mem[offset].first &= ~0x00FF0000;
			m_mem[offset].first |= (data & 0x00FF0000);
		}
		if (mask & 8) {
			m_mem[offset].first &= ~0xFF000000;
			m_mem[offset].first |= (data & 0xFF000000);
		}
		fprintf(stdout, "  mem=0x%08x\n", m_mem[offset].first);
	} else {
		fprintf(stdout, "Error: illegal access to address 0x%08x\n", addr);
		ASSERT_EQ((addr & 0xFFFFF000), 0x00000000);
	}
}

void fwrisc_instr_tests::exec(uint32_t addr, uint32_t instr) {
	fprintf(stdout, "EXEC: 0x%08x - 0x%08x\n", addr, instr);
	fflush(stdout);
	if (m_halt_addr != 0 && addr == m_halt_addr) {
		fprintf(stdout, "hit halt address 0x%08x\n", m_halt_addr);
		m_end_of_test = true;
		fprintf(stdout, "--> dropObjection\n");
		fflush(stdout);
		GoogletestHdl::dropObjection();
		fprintf(stdout, "<-- dropObjection\n");
		fflush(stdout);
	}
	if (++m_icount > m_max_instr) {
		fprintf(stdout, "test timeout\n");
		GoogletestHdl::dropObjection();
	}
}

void fwrisc_instr_tests::run() {
	GoogletestHdl::run();
}

void fwrisc_instr_tests::runtest(
		const std::string		&program,
		reg_val_s 				*regs,
		uint32_t 				n_regs) {
	runtest(regs, n_regs);
}

void fwrisc_instr_tests::runtest(
		reg_val_s 				*regs,
		uint32_t 				n_regs) {
	fprintf(stdout, "--> runtest (DEPRECATED)\n");
	fflush(stdout);

	GoogletestHdl::run();

	check(regs, n_regs);
	fprintf(stdout, "<-- runtest\n");
	fflush(stdout);
}


void fwrisc_instr_tests::check(reg_val_s *regs, uint32_t n_regs) {
	bool accessed[64];
	ASSERT_EQ(m_end_of_test, true); // Ensure we actually reached the end of the test

	memset(accessed, 0, sizeof(accessed));

	// First, display all registers that were written
	fprintf(stdout, "Written Registers:\n");
	for (uint32_t i=0; i<sizeof(m_regs)/sizeof(reg_val_s); i++) {
		if (m_regs[i].second) {
			fprintf(stdout, "R[%d] = 0x%08x\n", i, m_regs[i].first);
		}
	}
	fprintf(stdout, "Expected Registers:\n");
	for (uint32_t i=0; i<n_regs; i++) {
		fprintf(stdout, "Expect R[%d] = 0x%08x\n", regs[i].addr, regs[i].val);
	}

	// Perform the affirmative test
	for (uint32_t i=0; i<n_regs; i++) {
		if (!m_regs[regs[i].addr].second) {
			fprintf(stdout, "Error: reg %d was not written\n", regs[i].addr);
		}
		ASSERT_EQ(m_regs[regs[i].addr].second, true); // Ensure we wrote the register
		if (m_regs[regs[i].addr].first != regs[i].val) {
			fprintf(stdout, "Error: reg %d regs.value='h%08x expected='h%08hx\n",
					regs[i].addr, m_regs[regs[i].addr].first, regs[i].val);
		}
		ASSERT_EQ(m_regs[regs[i].addr].first, regs[i].val);
		accessed[regs[i].addr] = true;
	}

	for (uint32_t i=0; i<63; i++) { // r63 is the CSR temp register
		if (m_regs[i].second != accessed[i]) {
			fprintf(stdout, "Error: reg %d: regs.accessed=%s accessed=%s\n",
					i, (m_regs[i].second)?"true":"false",
					(accessed[i])?"true":"false");
		}
		ASSERT_EQ(m_regs[i].second, accessed[i]);
	}
}

TEST_F(fwrisc_instr_tests,runtest) {
	ElfSymtabReader					symtab;

	GoogletestHdl::run();

	const CmdlineProcessor &clp = GoogletestHdl::clp();
	std::string sw_image;
	ASSERT_TRUE(clp.get_plusarg_value("+SW_IMAGE", sw_image));
	symtab.read(sw_image);

	Elf32_Sym start_expected = symtab.find_sym("start_expected");
	Elf32_Sym end_expected = symtab.find_sym("end_expected");

	ASSERT_TRUE(start_expected.st_value >= 0x80000000);
	ASSERT_TRUE(end_expected.st_value >= 0x80000000);

	uint32_t n_regs = (end_expected.st_value-start_expected.st_value)/(sizeof(uint32_t)*2);
	reg_val_s *regs = new reg_val_s[n_regs];

	ElfDataReader reader;
	ASSERT_TRUE(reader.read(sw_image,
			start_expected.st_value,
			n_regs*(sizeof(reg_val_s)),
			regs));

	check(regs, n_regs);
}


