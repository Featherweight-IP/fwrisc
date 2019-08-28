/****************************************************************************
 * fwrisc_decode.sv
 ****************************************************************************/

/**
 * Module: fwrisc_decode
 * 
 * The decode module interprets the active instruction, determining the
 * operands passed forward to the exec phase. The decode phase performs
 * any required GPR register reads
 */
module fwrisc_decode #(
		parameter ENABLE_COMPRESSED=1
		)(
		input				clock,
		input				reset,
		
		input				fetch_valid, // valid/accept signals back to fetch
		output				decode_ready, // signals that instr has been accepted
		input[31:0]			instr,
		
		output reg[5:0]		ra_raddr,
		input[31:0]			ra_rdata,
		output reg[5:0]		rb_raddr,
		input[31:0]			rb_rdata,
		
		output				decode_valid,
		input				exec_ready,
		output reg[31:0]	op_a, // operand a (immediate or register)
		output reg[31:0]	op_b, // operand b (immediate or register)
		output reg[5:0]		rd_raddr,
		output reg			op_ld,
		output reg			op_st
		);
	
	always @(posedge clock) begin
		if (reset) begin
			decode_ready <= 0;
			decode_valid <= 0;
		end else begin
			if (fetch_valid) begin
				// Split instruction and setup appropriate register read
			end
		end
	end


endmodule


