/*
 * fwrisc_tb_hdl.cpp
 *
 *  Created on: Nov 28, 2018
 *      Author: ballance
 */
#include "fwrisc_tb_hdl.h"
#include <stdio.h>


fwrisc_tb_hdl::fwrisc_tb_hdl() {
	addClock(top()->clock, 10);
}

fwrisc_tb_hdl::~fwrisc_tb_hdl() {

}

void fwrisc_tb_hdl::SetUp() {
}

// Register this top-level with the GoogletestVl system
static GoogletestVlEngineFactory<fwrisc_tb_hdl>		prv_factory;


