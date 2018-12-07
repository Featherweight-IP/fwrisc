/*
 * fwrisc_tracer_bfm.cpp
 *
 *  Created on: Dec 3, 2018
 *      Author: ballance
 */

#include "fwrisc_tracer_bfm.h"
#include "BfmType.h"
#include <stdio.h>

fwrisc_tracer_bfm::fwrisc_tracer_bfm() {
	// TODO Auto-generated constructor stub

}

fwrisc_tracer_bfm::~fwrisc_tracer_bfm() {
	// TODO Auto-generated destructor stub
}

extern "C" uint32_t fwrisc_tracer_bfm_register(const char *path) {
	uint32_t ret = fwrisc_tracer_bfm_t::register_bfm(path);

	return ret;
}

extern "C" int fwrisc_tracer_bfm_regwrite(
		uint32_t			id,
		uint32_t			raddr,
		uint32_t			rdata) {
	if (fwrisc_tracer_bfm_t::bfm(id)->get_rsp_if()) {
		fwrisc_tracer_bfm_t::bfm(id)->get_rsp_if()->regwrite(raddr, rdata);
	}
	return 0;
}

extern "C" int fwrisc_tracer_bfm_exec(
		uint32_t			id,
		uint32_t			addr,
		uint32_t			instr) {
	if (fwrisc_tracer_bfm_t::bfm(id)->get_rsp_if()) {
		fwrisc_tracer_bfm_t::bfm(id)->get_rsp_if()->exec(addr, instr);
	}
	return 0;
}

extern "C" int fwrisc_tracer_bfm_memwrite(
		uint32_t			id,
		uint32_t			addr,
		uint8_t				mask,
		uint32_t			data) {
	if (fwrisc_tracer_bfm_t::bfm(id)->get_rsp_if()) {
		fwrisc_tracer_bfm_t::bfm(id)->get_rsp_if()->memwrite(addr, mask, data);
	}
	return 0;
}

// Type-based BFM registry
static fwrisc_tracer_bfm_t				bfm_registry;

