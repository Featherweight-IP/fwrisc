/****************************************************************************
 * fwrisc_rv32imc_tb_hdl.h
 ****************************************************************************/

#ifndef INCLUDED_fwrisc_rv32imc_TB_HDL_H
#define INCLUDED_fwrisc_rv32imc_TB_HDL_H
#include "GoogletestVlEngine.h"
#include "Vfwrisc_rv32imc_tb_hdl.h"

using namespace gtest_hdl;

class fwrisc_rv32imc_tb_hdl : public GoogletestVlEngine<Vfwrisc_rv32imc_tb_hdl> {
public:
        fwrisc_rv32imc_tb_hdl();

        virtual ~fwrisc_rv32imc_tb_hdl();

        virtual void SetUp();

};


#endif /* INCLUDED_fwrisc_rv32imc_TB_HDL_H */
