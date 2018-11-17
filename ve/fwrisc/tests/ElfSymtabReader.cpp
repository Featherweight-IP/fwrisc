/*
 * ElfSymtabReader.cpp
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

#include "ElfSymtabReader.h"
#include <stdio.h>
#include <string.h>

ElfSymtabReader::ElfSymtabReader() {
	// TODO Auto-generated constructor stub

}

ElfSymtabReader::~ElfSymtabReader() {
	// TODO Auto-generated destructor stub
}

Elf32_Sym ElfSymtabReader::find_sym(const std::string &name) {
	Elf32_Sym ret;
	std::map<std::string, Elf32_Sym>::iterator it;

	memset(&ret, 0, sizeof(Elf32_Sym));

	if ((it=m_symtab.find(name)) != m_symtab.end()) {
		ret = it->second;
	}

	return ret;
}

bool ElfSymtabReader::find_sym(Elf32_Addr addr, std::string &name) {
	std::map<Elf32_Addr,std::string>::iterator it;

	if ((it=m_addrtab.find(addr)) != m_addrtab.end()) {
		name = it->second;
		return true;
	} else {
		return false;
	}
}



void ElfSymtabReader::visit_shdr(const Elf32_Shdr &shdr) {
	if (shdr.sh_type == SHT_SYMTAB) {
		Elf32_Shdr str_shdr;

		read(hdr().e_shoff+hdr().e_shentsize*shdr.sh_link,
				&str_shdr, sizeof(Elf32_Shdr));

		fprintf(stdout, "String table: %d\n", str_shdr.sh_size);
		char *str_tmp = new char[str_shdr.sh_size];
		read(str_shdr.sh_offset, str_tmp, str_shdr.sh_size);

		for (uint32_t i=0; i<shdr.sh_size; i+=sizeof(Elf32_Sym)) {
			Elf32_Sym sym;

			read(shdr.sh_offset+i, &sym, sizeof(Elf32_Sym));

			m_symtab[&str_tmp[sym.st_name]] = sym;
			m_addrtab[sym.st_value] = &str_tmp[sym.st_name];
		}
		delete [] str_tmp;
	}
}


