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





TEST_F(fwrisc_instr_tests, lui) {
	reg_val_s exp[] = {
			{1, 0x00005000}
	};
	const char *program = R"(
		entry:
			lui		x1, 5
			j		done
			)";

	runtest(program, exp, sizeof(exp)/sizeof(reg_val_s));
}


