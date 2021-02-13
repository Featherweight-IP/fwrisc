


module fwrisc_exec_formal_test(
		input					clock,
		input					reset,
		output reg				decode_valid,
		input	 				instr_complete,

		// Indicates whether the instruction is compressed
		output reg				instr_c,

		output reg[4:0]			op_type,
		
		output reg[31:0]		op_a,
		output reg[31:0]		op_b,
		output reg[5:0]			op,
		output reg[31:0]		op_c
		);
	`include "fwrisc_op_type.svh"

	reg[1:0]		state;
//	assign decode_valid = (state == 0 && !instr_complete);
	
	always @(posedge clock) begin
		if (reset) begin
			state <= 0;
			instr_c <= 0;
			op_type <= OP_TYPE_ARITH;
			op_a <= 0;
			op_b <= 0;
			op <= 0;
			op_c <= 0;
			decode_valid <= 0;
		end else begin
			case (state)
				0: begin
					// Send out a new instruction
					decode_valid <= 1;
					op_a <= `anyseq;
					op_b <= `anyseq;
					state <= 1;
				end
				1: begin
					if (instr_complete) begin
						decode_valid <= 0;
						state <= 0;
					end
				end
			endcase
			
`ifdef FORMAL
			assert(s_eventually instr_complete);
`endif
//			cover(instr_complete==1);
		end
	end
	
	

endmodule