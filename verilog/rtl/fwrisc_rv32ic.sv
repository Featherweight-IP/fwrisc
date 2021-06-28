/****************************************************************************
 * fwrisc_rv32ic.sv
 ****************************************************************************/

/**
 * Module: fwrisc_rv32ic
 * 
 * FWRISC RV32IC configuration
 */
module fwrisc_rv32ic #(
		parameter[31:0]	FIXED_HARTID = 0,
		parameter       USE_FIXED_HARTID = 1,
		parameter[31:0] FIXED_RESVEC = 32'h80000000,
		parameter       USE_FIXED_RESVEC = 1
		) (
		input			clock,
		input			reset,
		
		input[31:0]		hartid,
		input[31:0]     resvec,
		
		output[31:0]	iaddr,
		input[31:0]		idata,
		output			ivalid,
		input			iready,
		
		output			dvalid,
		output[31:0]	daddr,
		output[31:0]	dwdata,
		output[3:0]		dwstb,
		output			dwrite,
		input[31:0]		drdata,
		input			dready		
		);
	
	fwrisc #(
		.ENABLE_COMPRESSED  (1), 
		.ENABLE_MUL_DIV     (0), 
		.ENABLE_DEP         (0), 
		.ENABLE_COUNTERS    (1),
		.FIXED_HARTID       (FIXED_HARTID),
		.USE_FIXED_HARTID   (USE_FIXED_HARTID),
		.FIXED_RESVEC       (FIXED_RESVEC),
		.USE_FIXED_RESVEC   (USE_FIXED_RESVEC)
		) u_core (
		.clock              (clock             ), 
		.reset              (reset             ), 
		.hartid             (hartid            ), 
		.resvec             (resvec            ), 
		.iaddr              (iaddr             ), 
		.idata              (idata             ), 
		.ivalid             (ivalid            ), 
		.iready             (iready            ), 
		.dvalid             (dvalid            ), 
		.daddr              (daddr             ), 
		.dwdata             (dwdata            ), 
		.dwstb              (dwstb             ), 
		.dwrite             (dwrite            ), 
		.drdata             (drdata            ), 
		.dready             (dready            ));

endmodule


