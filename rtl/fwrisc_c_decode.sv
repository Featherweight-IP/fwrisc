/****************************************************************************
 * fwrisc_c_decode.sv
 ****************************************************************************/

/**
 * Module: fwrisc_c_decode
 * 
 * Expands a RISC-V compressed instruction to a 32-bit instruction
 * This implementation significantly borrows from the IBEX core implementation
 */
module fwrisc_c_decode(
		input			clock,
		input			reset,
		input[15:0]		instr_i,
		output[31:0]	instr
		);
	
	// TODO:


endmodule


