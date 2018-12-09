/*
 * ElfDataReader.h
 *
 *  Created on: Dec 9, 2018
 *      Author: ballance
 */

#ifndef INCLUDED_ELF_DATA_READER_H
#define INCLUDED_ELF_DATA_READER_H
#include "ElfFileReader.h"

class ElfDataReader : public ElfFileReader {
public:
	ElfDataReader();

	virtual ~ElfDataReader();

	virtual bool read(
			const std::string 	&path,
			Elf32_Addr			addr,
			uint32_t			size,
			void				*data);

	virtual void visit_shdr(const Elf32_Shdr &shdr);

private:
	Elf32_Addr					m_addr;
	uint32_t					m_size;
	void						*m_data;
	bool						m_found;
};

#endif /* INCLUDED_ELF_DATA_READER_H */
