/****************************************************************************
 * fwrisc_rv32i.sv
 ****************************************************************************/

/**
 * Module: fwrisc_rv32i
 * 
 * FWRISC RV32I configuration
 */
module fwrisc_rv32i(
		input			clock,
		input			reset,
		
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
		input			dready,
		input			irq
		);
	
	fwrisc #(
		.ENABLE_COMPRESSED  (0), 
		.ENABLE_MUL_DIV     (0), 
		.ENABLE_DEP         (0), 
		.ENABLE_COUNTERS    (1)
		) u_core (
		.clock              (clock             ), 
		.reset              (reset             ), 
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
		.dready             (dready            ),
		.irq				(irq               )
		);

endmodule


