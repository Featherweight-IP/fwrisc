/*
 * fwrisc_zephyr_tests.h
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
 *
 *  Created on: Nov 16, 2018
 *      Author: ballance
 */

#ifndef INCLUDED_FWRISC_ZEPHYR_TESTS_H
#define INCLUDED_FWRISC_ZEPHYR_TESTS_H
#include "fwrisc_ctest_base.h"
#include "ElfSymtabReader.h"

class fwrisc_zephyr_tests : public fwrisc_ctest_base {
public:
	fwrisc_zephyr_tests();

	virtual ~fwrisc_zephyr_tests();

	virtual void SetUp();

	virtual void regwrite(uint32_t raddr, uint32_t rdata);

	virtual void exec(uint32_t addr, uint32_t instr);

	virtual void memwrite(uint32_t addr, uint8_t mask, uint32_t data);

protected:

	void check(const char *exp[], uint32_t exp_sz);

protected:
	uint32_t					m_ram_console;
	std::string					m_buffer;
	std::vector<std::string>	m_console_out;
};

#endif /* INCLUDED_FWRISC_ZEPHYR_TESTS_H */
