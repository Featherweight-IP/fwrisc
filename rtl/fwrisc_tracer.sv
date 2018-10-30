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
		input [31:0]	instr,
		input			ivalid,
		input [31:0]	raddr,
		input [31:0]	rdata,
		input			rwrite,
		input [31:0]	maddr,
		input [31:0]	mdata,
		input [3:0]		mstrb,
		input			mwrite,
		input 			mvalid
		);
	// Empty
	

endmodule


