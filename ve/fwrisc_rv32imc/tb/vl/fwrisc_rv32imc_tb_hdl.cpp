/****************************************************************************
 * fwrisc_rv32imc_tb_hdl.cpp
 ****************************************************************************/

#include "fwrisc_rv32imc_tb_hdl.h"
#include <stdio.h>


fwrisc_rv32imc_tb_hdl::fwrisc_rv32imc_tb_hdl() {
        addClock(top()->clock, 10);
}

fwrisc_rv32imc_tb_hdl::~fwrisc_rv32imc_tb_hdl() {

}

void fwrisc_rv32imc_tb_hdl::SetUp() {
}

// Register this top-level with the GoogletestVl system
static GoogletestVlEngineFactory<fwrisc_rv32imc_tb_hdl>         prv_factory;
