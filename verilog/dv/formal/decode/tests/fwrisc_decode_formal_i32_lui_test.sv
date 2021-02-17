
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
	wire[31:0] instr_lui;
	`lui(instr_lui, $anyconst, $anyconst);
	
	reg state = 0;
	
	always @(posedge clock) begin
		if (reset) begin
			fetch_valid <= 0;
			instr <= 0;
			state <= 0;
		end else begin
			case (state)
				0: begin
					fetch_valid <= 1;
					instr <= instr_lui;
					state <= 1;
				end
				1: begin
					if (decode_ready) begin
						fetch_valid <= 0;
						state <= 0;
					end
				end
			endcase
		end
	end

endmodule