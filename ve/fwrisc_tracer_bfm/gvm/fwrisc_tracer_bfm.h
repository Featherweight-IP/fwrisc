/*
 * fwrisc_tracer_bfm.h
 *
 *  Created on: Dec 3, 2018
 *      Author: ballance
 */

#ifndef VE_FWRISC_TRACER_BFM_GVM_FWRISC_TRACER_BFM_H_
#define VE_FWRISC_TRACER_BFM_GVM_FWRISC_TRACER_BFM_H_
#include "Bfm.h"
#include "fwrisc_tracer_bfm_if.h"
#include <stdint.h>
#include <vector>

class fwrisc_tracer_bfm : public Bfm<fwrisc_tracer_bfm_rsp_if> {
public:
	fwrisc_tracer_bfm();

	virtual ~fwrisc_tracer_bfm();

	void dumpregs();

public:

};

typedef BfmType<fwrisc_tracer_bfm>			fwrisc_tracer_bfm_t;

#endif /* VE_FWRISC_TRACER_BFM_GVM_FWRISC_TRACER_BFM_H_ */
