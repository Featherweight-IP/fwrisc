/*
 * fwrisc_instr_tests.cpp
 *
 *  Created on: Oct 28, 2018
 *      Author: ballance
 */

#include "fwrisc_instr_tests.h"
#include "AsmTestCompiler.h"

fwrisc_instr_tests::fwrisc_instr_tests() {
	// TODO Auto-generated constructor stub

}

fwrisc_instr_tests::~fwrisc_instr_tests() {
	// TODO Auto-generated destructor stub
}

fwrisc_instr_tests *fwrisc_instr_tests::test = 0;

void fwrisc_instr_tests::SetUp() {
	BaseT::SetUp();

	Vfwrisc_tb_hdl *tbp = static_cast<Vfwrisc_tb_hdl *>(0);
	fprintf(stdout, "offset of clock: %d\n", &tbp->clock);

	test = this;
	m_icount = 0;
	m_end_of_test = false;

	for (uint32_t i=0; i<64; i++) {
		m_regs[i] = std::pair<uint32_t, bool>(0, false);
	}

	raiseObjection(this);

	addClock(top()->clock, 10);
}

void fwrisc_instr_tests::regwrite(uint32_t raddr, uint32_t rdata) {
	m_regs[raddr].first = rdata;
	m_regs[raddr].second = true;
}

void fwrisc_instr_tests::exec(uint32_t addr, uint32_t instr) {
	if (addr == 0x0000004) {
		fprintf(stdout, "hit 0x4\n");
		m_end_of_test = true;
		dropObjection(this);
	}
	if (++m_icount > 100) {
		fprintf(stdout, "test timeout\n");
		dropObjection(this);
	}
}

void fwrisc_instr_tests::runtest(
		const std::string		&program,
		reg_val_s 				*regs,
		uint32_t 				n_regs) {
	ASSERT_EQ(AsmTestCompiler::compile(testname(), program), true);

	run();
	check(regs, n_regs);
}

void fwrisc_instr_tests::check(reg_val_s *regs, uint32_t n_regs) {
	ASSERT_EQ(m_end_of_test, true); // Ensure we actually reached the end of the test

	for (uint32_t i=0; i<n_regs; i++) {
		ASSERT_EQ(m_regs[regs[i].addr].second, true); // Ensure we wrote the register
		ASSERT_EQ(m_regs[regs[i].addr].first, regs[i].val);
	}
}

extern "C" int unsigned fwrisc_tracer_bfm_register(const char *path) {
	fprintf(stdout, "register: %s\n", path);
	return 0;
}

extern "C" void fwrisc_tracer_bfm_regwrite(unsigned int id, unsigned int raddr, unsigned int rdata) {
	fwrisc_instr_tests::test->regwrite(raddr, rdata);
}

extern "C" void fwrisc_tracer_bfm_exec(unsigned int id, unsigned int addr, unsigned int instr) {
	fwrisc_instr_tests::test->exec(addr, instr);
}

TEST_F(fwrisc_instr_tests, addi) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 11}
	};
	const char *program = R"(
		entry:
			li		x1, 5
			add		x3, x1, 6
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, addi_neg) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 4}
	};
	const char *program = R"(
		entry:
			li		x1, 5
			add		x3, x1, -1
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, add) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 11}
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			add		x3, x1, x2
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, and) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 4} // 5&6 == 4
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			and		x3, x1, x2
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, andi) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 4} // 5&6 == 4
	};
	const char *program = R"(
		entry:
			li		x1, 5
			andi	x3, x1, 4
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, beq_t_fwd) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 5
			beq		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, beq_t_back) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			j		t_start
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
		t_start:
			li		x1, 5
			li		x2, 5
			beq		x1, x2, 1b
		2: // fail
			li		x3, 20
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, beq_f_fwd) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			beq		x1, x2, 1f
			li		x3, 24
			j		done
		1:
			li		x3, 20
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, beq_f_back) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			j		t_start
			li		x3, 20
			j		done
		1:
			li		x3, 20
			j		done
		t_start:
			li		x1, 5
			li		x2, 6
			beq		x1, x2, 1b
		2: // pass: x1!=x2
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, bne_t_fwd) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			bne		x1, x2, 1f
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, bne_t_back) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			j		t_start
			li		x3, 20
			j		done
		1:
			li		x3, 24
			j		done
		t_start:
			li		x1, 5
			li		x2, 6
			bne		x1, x2, 1b
		2: // fail
			li		x3, 20
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, bne_f_fwd) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 5
			bne		x1, x2, 1f
			li		x3, 24
			j		done
		1:
			li		x3, 20
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, bne_f_back) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 5},
			{3, 24} // r1==r2
	};
	const char *program = R"(
		entry:
			j		t_start
			li		x3, 20
			j		done
		1:
			li		x3, 20
			j		done
		t_start:
			li		x1, 5
			li		x2, 5
			bne		x1, x2, 1b
		2: // pass: x1!=x2
			li		x3, 24
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, or) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 7} // 5|6=7
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			or		x3, x1, x2
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, ori) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 7} // 5|6=7
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			ori		x3, x1, 6
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, slti_t) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 1} // 5 < 6
	};
	const char *program = R"(
		entry:
			li		x1, 5
			slti	x3, x1, 6
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, slti_f) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 0} // !5 < 4
	};
	const char *program = R"(
		entry:
			li		x1, 5
			slti	x3, x1, 4
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, sub) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 1} // 6-5=1
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			sub		x3, x2, x1
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, xor) {
	reg_val_s exp[] = {
			{1, 5},
			{2, 6},
			{3, 3} // 5^6=3
	};
	const char *program = R"(
		entry:
			li		x1, 5
			li		x2, 6
			xor		x3, x1, x2
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

TEST_F(fwrisc_instr_tests, xori) {
	reg_val_s exp[] = {
			{1, 5},
			{3, 3} // 5^6=3
	};
	const char *program = R"(
		entry:
			li		x1, 5
			xori	x3, x1, 6
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}

