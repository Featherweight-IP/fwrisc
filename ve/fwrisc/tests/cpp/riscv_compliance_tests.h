/*
 * riscv_compliance_tests.h
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
 *
 *  Created on: Oct 24, 2018
 *      Author: ballance
 */

#ifndef INCLUDED_RISCV_COMPLIANCE_TESTS_H
#define INCLUDED_RISCV_COMPLIANCE_TESTS_H
#include <stdint.h>
#include "fwrisc_instr_tests.h"

class riscv_compliance_tests : public fwrisc_instr_tests {
public:

	riscv_compliance_tests() : fwrisc_instr_tests(10000) { };

	virtual ~riscv_compliance_tests() { };

	virtual void SetUp();

	virtual void memwrite(uint32_t addr, uint8_t mask, uint32_t data);

	virtual void check();

};

#endif /* INCLUDED_RISCV_COMPLIANCE_TESTS_H */
