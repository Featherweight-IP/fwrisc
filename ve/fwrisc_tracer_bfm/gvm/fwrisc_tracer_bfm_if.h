/*
 * fwrisc_tracer_bfm_if.h
 *
 *  Created on: Dec 4, 2018
 *      Author: ballance
 */

#ifndef VE_FWRISC_TRACER_BFM_GVM_FWRISC_TRACER_BFM_IF_H_
#define VE_FWRISC_TRACER_BFM_GVM_FWRISC_TRACER_BFM_IF_H_
#include <stdint.h>

class fwrisc_tracer_bfm_rsp_if {
public:

	virtual ~fwrisc_tracer_bfm_rsp_if() { }

	virtual void regwrite(uint32_t raddr, uint32_t rdata) = 0;

	virtual void exec(uint32_t addr, uint32_t instr) = 0;

	virtual void memwrite(uint32_t addr, uint8_t mask, uint32_t data) = 0;

};



#endif /* VE_FWRISC_TRACER_BFM_GVM_FWRISC_TRACER_BFM_IF_H_ */
