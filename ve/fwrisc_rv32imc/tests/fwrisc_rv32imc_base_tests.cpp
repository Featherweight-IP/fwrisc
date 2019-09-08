/****************************************************************************
 * fwrisc_rv32imc_base_tests.cpp
 ****************************************************************************/

#include "fwrisc_rv32imc_base_tests.h"

void fwrisc_rv32imc_base_tests::SetUp() {
}

void fwrisc_rv32imc_base_tests::TearDown() {
}

void fwrisc_rv32imc_base_tests::run() {
	GoogletestHdl::run();
}

/**
 * smoke test
 */
TEST_F(fwrisc_rv32imc_base_tests,smoke) {
	const CmdlineProcessor &clp = GoogletestHdl::clp();

	GoogletestHdl::raiseObjection();

	run();
}
