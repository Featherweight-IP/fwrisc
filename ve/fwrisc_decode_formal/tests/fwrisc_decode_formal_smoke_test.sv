
`include "fwrisc_decode_formal_opcode_defines.svh"


module fwrisc_decode_formal_test(
		input			clock,
		input			reset,
		output reg		fetch_valid,
		input			decode_ready,
		output[31:0]	instr,
		output			instr_c
		);

	assign instr_c = 0;
	`lui(instr, $anyconst, $anyconst);
	
	always @(posedge clock) begin
		if (reset) begin
			fetch_valid <= 0
	end
	assign fetch_valid = 1;

endmodule