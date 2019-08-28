/****************************************************************************
 * fwrisc_exec.sv
 ****************************************************************************/

/**
 * Module: fwrisc_exec
 * 
 * TODO: Add module documentation
 */
module fwrisc_exec #(
		)(
		input				clock,
		input				reset,
		input				decode_valid,
		output reg			exec_ready,
		
		output reg[5:0]		rd_raddr,
		output reg			rd_wen
		
		);


endmodule


