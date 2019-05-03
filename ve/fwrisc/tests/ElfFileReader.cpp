/*
 * ElfFileReader.cpp
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
 *  Created on: Nov 17, 2018
 *      Author: ballance
 */

#include "ElfFileReader.h"
#include <stdio.h>
#include <elf.h>

ElfFileReader::ElfFileReader() {
	m_fp = 0;
}

ElfFileReader::~ElfFileReader() {
	// TODO Auto-generated destructor stub
}

bool ElfFileReader::read(const std::string &path) {
	Elf32_Phdr phdr;
	Elf32_Shdr shdr;

	m_fp = fopen(path.c_str(), "rb");

	if (!m_fp) {
		fprintf(stdout, "Error: failed to open file %s\n", path.c_str());
		return false;
	}

	fread(&m_hdr, sizeof(Elf32_Ehdr), 1, m_fp);

	for (uint32_t i=0; i<m_hdr.e_shnum; i++) {
		read(m_hdr.e_shoff+m_hdr.e_shentsize*i, &shdr, sizeof(Elf32_Shdr));

		visit_shdr(shdr);
	}

	fclose(m_fp);
	m_fp = 0;

	return true;
}

void ElfFileReader::read(uint32_t off, void *dst, uint32_t sz) {
	fseek(m_fp, off, 0);
	fread(dst, sz, 1, m_fp);
}


