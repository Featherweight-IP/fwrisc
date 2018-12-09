/*
 * ElfDataReader.cpp
 *
 *  Created on: Dec 9, 2018
 *      Author: ballance
 */

#include "ElfDataReader.h"
#include <stdio.h>

ElfDataReader::ElfDataReader() {
	// TODO Auto-generated constructor stub

}

ElfDataReader::~ElfDataReader() {
	// TODO Auto-generated destructor stub
}

bool ElfDataReader::read(
			const std::string 	&path,
			Elf32_Addr			addr,
			uint32_t			size,
			void				*data) {
	m_addr = addr;
	m_size = size;
	m_data = data;

	m_found = false;

	ElfFileReader::read(path);

	return m_found;
}

void ElfDataReader::visit_shdr(const Elf32_Shdr &shdr) {
	if (m_addr >= shdr.sh_addr && m_addr < (shdr.sh_addr + shdr.sh_size)) {
		ElfFileReader::read(shdr.sh_offset+(m_addr-shdr.sh_addr), m_data, m_size);
		m_found = true;
	}
}

