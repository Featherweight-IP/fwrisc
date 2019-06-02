/*
 * riscv_compliance_tests.cpp
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
 *  Created on: Oct 24, 2018
 *      Author: ballance
 */

#include "riscv_compliance_tests.h"

#include <stdlib.h>
#include <elf.h>

#include "ElfSymtabReader.h"
#include "CmdlineProcessor.h"

void riscv_compliance_tests::SetUp() {
	fprintf(stdout, "SetUp\n");
	fwrisc_instr_tests::SetUp();

	GoogletestHdl::raiseObjection();
}

void riscv_compliance_tests::memwrite(uint32_t addr, uint8_t mask, uint32_t data) {
	if (addr == 0x80001000) {
		fprintf(stdout, "Note: end of test\n");
		GoogletestHdl::dropObjection();
	} else {
		fwrisc_instr_tests::memwrite(addr, mask, data);
	}
}

void riscv_compliance_tests::check() {
	const CmdlineProcessor &clp = GoogletestHdl::clp();
	FILE *ref_file_fp, *elf_file_fp;
	std::string elf_file, ref_file;
	char line[256];
	uint32_t addr=0x2030/4, exp, actual;
	uint32_t begin_signature=0, end_signature=0;
	char *p;

	clp.get_plusarg_value("+REF_FILE", ref_file);
	clp.get_plusarg_value("+SW_IMAGE", elf_file);

	ElfSymtabReader symtab;

	if (!symtab.read(elf_file)) {
		fprintf(stdout, "Error: failed to read ELF symbol table\n");
	}

	begin_signature = symtab.find_sym("begin_signature").st_value;
	end_signature = symtab.find_sym("end_signature").st_value;


	ASSERT_NE(0, begin_signature);
	ASSERT_NE(0, end_signature);


	fprintf(stdout, "REF_FILE=%s\n", ref_file.c_str());

	ref_file_fp = fopen(ref_file.c_str(), "rb");
	ASSERT_TRUE(ref_file_fp);

	addr = (begin_signature & 0xFFFF)/4;
	while (fgets(line, sizeof(line), ref_file_fp)) {
		char *p = line + strlen(line) - 2;

		while (p > line) {
			char *old_p = p;
			p -= 8;
			*old_p = 0;

			exp = strtoul(p, 0, 16);

			actual = m_mem[addr].first;

			fprintf(stdout, "0x%08x: exp=0x%08x actual=0x%08x\n", 4*addr, exp, actual);
			ASSERT_EQ(exp, actual);

			addr++;
		}
	}
}

TEST_F(riscv_compliance_tests, runtest) {
	GoogletestHdl::run();
	check();
}

