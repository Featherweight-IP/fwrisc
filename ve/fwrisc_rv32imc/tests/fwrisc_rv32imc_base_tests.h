/****************************************************************************
 * fwrisc_rv32imc_base_tests.h
 ****************************************************************************/

#pragma once
#include "gtest/gtest.h"
#include "GoogletestHdl.h"

class fwrisc_rv32imc_base_tests : public ::testing::Test {
public:

	virtual void SetUp();

	virtual void TearDown();

	virtual void run();

};
