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

void riscv_compliance_tests::SetUp() {
	fprintf(stdout, "SetUp\n");
	fwrisc_instr_tests::SetUp();

	raiseObjection(this);
}

TEST_F(riscv_compliance_tests, coretest) {
	run();
}

TEST_F(riscv_compliance_tests, smoke2) {
	fprintf(stdout, "smoketest2\n");
	run();
}

