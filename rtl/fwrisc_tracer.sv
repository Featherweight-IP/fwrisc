/****************************************************************************
 * fwrisc_tracer.sv
 ****************************************************************************/

/**
 * Module: fwrisc_tracer
 * 
 * Dummy module that provides an attachment site for the
 * monitor BFM
 */
module fwrisc_tracer (
		input			clock,
		input			reset,
		input [31:0]	addr,
		input [31:0]	insn,
		input [31:0]	rs1,
		input [31:0]	rs2,
		input [31:0]	rt
		);
	// Empty
endmodule


