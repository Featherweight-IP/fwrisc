/*
 * GoogletestHdlTest.h
 *
 *  Created on: Nov 28, 2018
 *      Author: ballance
 */

#ifndef INCLUDED_FWRISC_TB_HDL_H
#define INCLUDED_FWRISC_TB_HDL_H
#include "GoogletestVlEngine.h"
#include "Vfwrisc_fpga_tb_hdl.h"

using namespace gtest_hdl;

class fwrisc_fpga_tb_hdl : public GoogletestVlEngine<Vfwrisc_fpga_tb_hdl> {
public:
	fwrisc_fpga_tb_hdl();

	virtual ~fwrisc_fpga_tb_hdl();

	virtual void SetUp();

	static uint32_t			m_fwrisc_field;

};


#endif /* INCLUDED_FWRISC_TB_HDL_H */
