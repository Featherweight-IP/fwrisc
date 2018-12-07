/*
 * fwrisc_instr_tests_arith.cpp
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
 *  Created on: Oct 29, 2018
 *      Author: ballance
 */

#include "fwrisc_instr_tests_arith.h"
#include <stdint.h>

fwrisc_instr_tests_arith::fwrisc_instr_tests_arith() {
	// TODO Auto-generated constructor stub

}

fwrisc_instr_tests_arith::~fwrisc_instr_tests_arith() {
	// TODO Auto-generated destructor stub
}

TEST_F(fwrisc_instr_tests_arith, addi) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 11}
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, addi_neg) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 4}
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, add) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 11}
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, and) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 4} // 5&6 == 4
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, andi) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 4} // 5&6 == 4
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, or) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 7} // 5|6=7
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, ori) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 7} // 5|6=7
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, sll) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 1},
			{3, (1 << 5)}
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, slli) {
	reg_val_s exp[] = {
			{1, 1},
			{3, (1 << 5)}
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, slt_t_pos) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 1} // 5 < 6
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, slt_t_neg) {
	reg_val_s exp[] = {
			{1, (uint32_t)-6},
			{2, (uint32_t)-5},
			{3, 1} // 5 < 6
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}


TEST_F(fwrisc_instr_tests_arith, slt_f) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 5},
			{3, 0} // !5 < 4
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, slti_t) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 1} // 5 < 6
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, slti_f) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 0} // !5 < 4
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, sltu_t) {
	reg_val_s exp[] = {
			{1, 0x80000000},
			{2, 0x80000001},
			{3, 1} // 5 < 6
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, sra) {
	reg_val_s exp[] = {
			{1, 4},
			{2, 0x80000000},
			{3, 0xF8000000}
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, srai) {
	reg_val_s exp[] = {
			{2, 0x80000000},
			{3, 0xF8000000}
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, srl) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 0x80000000},
			{3, (0x80000000 >> 5)}
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, srli) {
	reg_val_s exp[] = {
			{2, 0x80000000},
			{3, (0x80000000 >> 5)}
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, sub) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 1} // 6-5=1
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, xor) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 3} // 5^6=3
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests_arith, xori) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 3} // 5^6=3
	};

	runtest(exp, sizeof(exp)/sizeof(reg_val_s));
}


