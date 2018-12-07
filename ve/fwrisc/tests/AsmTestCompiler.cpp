/*
 * AsmTestCompiler.cpp
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

#include "AsmTestCompiler.h"
#include <stdlib.h>
#include <stdio.h>
#include <vector>
#include <ctype.h>
#include <string.h>

AsmTestCompiler::AsmTestCompiler(
		const std::string	&basename,
		const std::string 	&program,
		const std::string 	&out) {
	m_basename = basename;
	m_program = program;
	m_out = out;

}

AsmTestCompiler::~AsmTestCompiler() {
	// TODO Auto-generated destructor stub
}

bool AsmTestCompiler::compile(
		const std::string	&basename,
		const std::string 	&program,
		const std::string 	&out) {
	AsmTestCompiler compiler(basename, program, out);

	return compiler.compile();
}

bool AsmTestCompiler::compile() {
	std::string full_program = R"(
		.section .text.init;
		.globl _start
		_start:
			j		test_program
		done:
			j		done
		test_program:	// 
	)";
	full_program += m_program;

	std::string cmd;

	std::string filename;
	FILE *fh;

	filename = m_basename + ".link.ld";
	fh = fopen(filename.c_str(), "wb");
	fputs(R"(
		OUTPUT_ARCH("riscv")
		ENTRY(_start)

		SECTIONS
		{
			. = 0x00000000;
			.text.init : { *(.text.init) }
			. = ALIGN(0x1000);
			_end = .;
		}
		
	)", fh);
	fclose(fh);


	filename = m_basename + ".test.S";
	fh = fopen(filename.c_str(), "wb");

	if (!fh) {
		fprintf(stdout, "Error: failed to open file \"%s\"\n", filename.c_str());
		fflush(stdout);
		return false;
	}
	fputs(full_program.c_str(), fh);
	fclose(fh);

	cmd = "riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -o ";
	cmd += m_basename + ".test.elf ";
	cmd += "-static -mcmodel=medany -fvisibility=hidden ";
	cmd += "-nostdlib -nostartfiles ";
	cmd += m_basename + ".test.S ";
	cmd += "-T ";
	cmd += m_basename + ".link.ld";

	if (system(cmd.c_str()) != 0) {
		fprintf(stdout, "Error: compile failed\n");
		fflush(stdout);
		return false;
	}

	cmd = "riscv32-unknown-elf-objcopy ";
	cmd += m_basename + ".test.elf ";
	cmd += "-O verilog ";
	cmd += m_basename + ".test.vlog";

	if (system(cmd.c_str()) != 0) {
		fprintf(stdout, "Error: objcopy failed\n");
		fflush(stdout);
		return false;
	}

	if (!tohex(m_basename + ".test.vlog", m_out)) {
		fprintf(stdout, "Error: tohex failed\n");
		fflush(stdout);
		return false;
	}

	return true;
}

bool AsmTestCompiler::tohex(
		const std::string &file_vlog,
		const std::string &file_hex) {
	char tmp[1024];
	bool ret = true;
	FILE *fh_vlog = fopen(file_vlog.c_str(), "rb");
	FILE *fh_hex = fopen(file_hex.c_str(), "wb");

	if (!fh_vlog || !fh_hex) {
		fprintf(stdout, "Error: failed to open files\n");
		return false;
	}

	// Prime the pump
	fgets(tmp, sizeof(tmp), fh_vlog);

	while (true) {
		uint32_t wordaddr;
		if (tmp[0] != '@') {
			fprintf(stdout, "Error: unknown record: %s", tmp);
			ret = false;
			break;
		}

		wordaddr = strtoul(&tmp[1], 0, 16);
		wordaddr /= 4;

		fprintf(fh_hex, "@%08x\n", wordaddr);

		while (fgets(tmp, sizeof(tmp), fh_vlog)) {
			if (tmp[0] != '@') {
				std::vector<std::string> bytes;
				uint32_t len = strlen(tmp);
				uint32_t i=0;

				while (i<len) {
					std::string byte;
					// Skip whitespace
					while (i < len && isspace(tmp[i])) {
						i++;
					}

					// Stuff non-whitespace into a byte
					while (i < len && !isspace(tmp[i])) {
						byte.push_back(tmp[i]);
						i++;
					}

					if (byte.size() > 0) {
						bytes.push_back(byte);
					}
				}

				for (i=0; i<bytes.size(); i+=4) {
					for (int j=4-1; j>=0; j--) {
						if (i+j < bytes.size()) {
							fprintf(fh_hex, "%s", bytes.at(i+j).c_str());
						} else {
							fprintf(fh_hex, "00");
						}
					}
					fprintf(fh_hex, "\n");
				}
			} else {
				break;
			}
		}

		if (feof(fh_vlog)) {
			break;
		}
	}

	fclose(fh_vlog);
	fclose(fh_hex);

	return ret;
}
