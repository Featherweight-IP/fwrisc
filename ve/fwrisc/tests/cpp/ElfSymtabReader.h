/*
 * ElfSymtabReader.h
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

#ifndef INCLUDED_ELF_SYMTAB_READER_H
#define INCLUDED_ELF_SYMTAB_READER_H
#include <stdint.h>
#include <string>
#include <map>
#include <vector>
#include "ElfFileReader.h"

class ElfSymtabReader : public ElfFileReader {
public:
	ElfSymtabReader();

	virtual ~ElfSymtabReader();

	Elf32_Sym find_sym(const std::string &name);

	bool find_sym(Elf32_Addr addr, std::string &name);

	int32_t find_sym(Elf32_Addr addr);

	const Elf32_Sym &get_sym(int32_t idx);

	const std::string &get_sym_name(int32_t idx);

	uint32_t n_syms() const { return m_symlist.size(); }

protected:

	virtual void visit_shdr(const Elf32_Shdr &shdr);


private:
	std::map<std::string, Elf32_Sym> 					m_symtab;
	std::map<Elf32_Addr, uint32_t>						m_addrtab;
	std::vector<std::pair<Elf32_Sym, std::string>>		m_symlist;

};

extern "C" {
void *elf_symtab_reader_new(const char *file);
unsigned int elf_symtab_reader_get_sym(void *, const char *name);
}

#endif /* INCLUDED_ELF_SYMTAB_READER_H */
