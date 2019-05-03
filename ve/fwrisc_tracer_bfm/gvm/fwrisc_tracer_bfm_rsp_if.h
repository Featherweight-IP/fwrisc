/****************************************************************************
 * fwrisc_tracer_bfm_rsp_if.h
 *
 ****************************************************************************/
#pragma once
#include <stdint.h>

class fwrisc_tracer_bfm_rsp_if {
public:

	virtual ~fwrisc_tracer_bfm_rsp_if() { }

    virtual void regwrite(uint32_t raddr, uint32_t rdata) = 0;
    virtual void exec(uint32_t addr, uint32_t instr) = 0;
    virtual void memwrite(uint32_t addr, uint8_t mask, uint32_t data) = 0;


};
