/*
 * ElfFileReader.h
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

#ifndef INCLUDED_ELF_FILE_READER_H
#define INCLUDED_ELF_FILE_READER_H
#include <string>
#include <elf.h>

class ElfFileReader {
public:
	ElfFileReader();

	virtual ~ElfFileReader();

	virtual bool read(const std::string &path);

protected:

	virtual void visit_shdr(const Elf32_Shdr &shdr) { }

	virtual void read(uint32_t off, void *dst, uint32_t sz);

	virtual const Elf32_Ehdr &hdr() const { return m_hdr; }

private:
	FILE					*m_fp;
	Elf32_Ehdr				m_hdr;
};

#endif /* INCLUDED_ELF_FILE_READER_H */

