
`include "fwrisc_decode_formal_opcode_defines.svh"


module fwrisc_decode_formal_test(
		input				clock,
		input				reset,
		output reg			fetch_valid,
		input				decode_ready,
		output reg[31:0]	instr,
		output				instr_c
		);

	assign instr_c = 0;
	wire[31:0] instr_w;
	`lui(instr_w, $anyconst, $anyconst);
	
	always @(posedge clock) begin
		if (reset) begin
			fetch_valid <= 0;
			instr <= 0;
		end else begin
			instr <= instr_w;
			fetch_valid <= 1;
		end
	end

endmodule