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
#include "GoogletestVlCmdlineProcessor.h"
#include <stdlib.h>
#include <elf.h>

void riscv_compliance_tests::SetUp() {
	fprintf(stdout, "SetUp\n");
	fwrisc_instr_tests::SetUp();

	raiseObjection(this);
}

void riscv_compliance_tests::memwrite(uint32_t addr, uint8_t mask, uint32_t data) {
	if (addr == 0x80001000) {
		fprintf(stdout, "Note: end of test\n");
		dropObjection(this);
	} else {
		fwrisc_instr_tests::memwrite(addr, mask, data);
	}
}

void riscv_compliance_tests::runtest() {
	run();
	check();
}

void riscv_compliance_tests::check() {
	const GoogletestVlCmdlineProcessor &clp = GoogletestVlCmdlineProcessor::instance();
	FILE *ref_file_fp, *elf_file_fp;
	std::string elf_file, ref_file;
	char line[256];
	uint32_t addr=0x2030/4, exp, actual;
	uint32_t begin_signature=0, end_signature=0;
	char *p;

	clp.get_plusarg_value("+REF_FILE", ref_file);
	clp.get_plusarg_value("+SW_IMAGE", elf_file);

	{
		Elf32_Ehdr	hdr;
		Elf32_Phdr	phdr;
		Elf32_Shdr	shdr;

		elf_file_fp = fopen(elf_file.c_str(), "rb");
		fread(&hdr, sizeof(Elf32_Ehdr), 1, elf_file_fp);

		for (uint32_t i=0; i<hdr.e_shnum; i++) {
			fseek(elf_file_fp, hdr.e_shoff+hdr.e_shentsize*i, 0);

			fread(&shdr, sizeof(Elf32_Shdr), 1, elf_file_fp);

			if (shdr.sh_type == SHT_SYMTAB) {
				Elf32_Shdr str_shdr;

				fseek(elf_file_fp, hdr.e_shoff+hdr.e_shentsize*shdr.sh_link, 0);
				fread(&str_shdr, sizeof(Elf32_Shdr), 1, elf_file_fp);

				fprintf(stdout, "String table: %d\n", str_shdr.sh_size);
				char *str_tmp = new char[str_shdr.sh_size];
				fseek(elf_file_fp, str_shdr.sh_offset, 0);
				fread(str_tmp, str_shdr.sh_size, 1, elf_file_fp);

				for (uint32_t j=0; j<shdr.sh_size; j+=sizeof(Elf32_Sym)) {
					Elf32_Sym sym;

					fseek(elf_file_fp, (shdr.sh_offset+j), 0);
					fread(&sym, sizeof(Elf32_Sym), 1, elf_file_fp);

					fprintf(stdout, "Symbol: %s\n", &str_tmp[sym.st_name]);
					if (!strcmp(&str_tmp[sym.st_name], "begin_signature")) {
						begin_signature = sym.st_value;
					} else if (!strcmp(&str_tmp[sym.st_name], "end_signature")) {
						end_signature = sym.st_value;
					}
				}
				delete [] str_tmp;
			}
		}
		fclose(elf_file_fp);
	}

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

TEST_F(riscv_compliance_tests, coretest) {
	runtest();
}

TEST_F(riscv_compliance_tests, smoke2) {
	fprintf(stdout, "smoketest2\n");
	run();
}

