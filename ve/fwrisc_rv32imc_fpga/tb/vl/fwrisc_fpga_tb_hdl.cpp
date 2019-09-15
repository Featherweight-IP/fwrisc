/*
 * fwrisc_fpga_tb_hdl.cpp
 *
 *  Created on: Nov 28, 2018
 *      Author: ballance
 */
#include <stdio.h>
#include "fwrisc_fpga_tb_hdl.h"


fwrisc_fpga_tb_hdl::fwrisc_fpga_tb_hdl() {
	addClock(top()->clock, 10);
}

fwrisc_fpga_tb_hdl::~fwrisc_fpga_tb_hdl() {

}

void fwrisc_fpga_tb_hdl::SetUp() {
}

// Register this top-level with the GoogletestVl system
static GoogletestVlEngineFactory<fwrisc_fpga_tb_hdl>		prv_factory;


