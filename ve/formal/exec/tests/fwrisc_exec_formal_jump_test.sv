
`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_jump_test(
		input					clock,
		input					reset,
		output 					decode_valid,
		input	 				instr_complete,
		
		input[31:0]				pc,

		// Indicates whether the instruction is compressed
		output reg				instr_c,

		output reg[4:0]			op_type,
		
		output reg[31:0]		op_a,
		output reg[31:0]		op_b,
		output reg[5:0]			op,
		output reg[31:0]		op_c,
		output reg[5:0]			rd,
		output reg[31:0]		mtvec,
		
		input					dvalid,
		output reg[31:0]		drdata,
		output reg				dready
		
		
		);
	`include "fwrisc_op_type.svh"
	`include "fwrisc_alu_op.svh"

	reg[1:0]		state;
	reg				decode_valid_r;
	wire            instr_c_w = `anyconst;
	wire			cond = `anyconst;
	wire[1:0]		op_w = `anyconst;
	wire[31:0]		value = `anyconst;
	wire[11:0]		branch = `anyconst;
	wire[31:1]		jump_base = `anyconst;
	wire[21:1]		jump_off = `anyconst;
	wire[5:0]		rd_w;
	assign rd_w[5] = 0;
	assign rd_w[4:0] = `anyconst;
	
	assign decode_valid = (decode_valid_r && !instr_complete);
	
	always @(posedge clock) begin
		if (reset) begin
			state <= 0;
			instr_c <= 0;
			op_type <= OP_TYPE_JUMP;
			op_a <= 0; // RS1 in the case of JR ; PC in the case of J
			op_b <= 0; // Always zero
			op <= OP_OPA; // Always NOP
			op_c <= 0; // Offset
			rd <= 0;
			decode_valid_r <= 0;
			mtvec <= 0;
		end else begin
			case (state)
				0: begin
					// Send out a new instruction
					decode_valid_r <= 1;
					instr_c <= instr_c_w;
					op_a <= jump_base;
					op_c <= $signed(jump_off);
					rd <= rd_w;
				end
				1: begin
					if (instr_complete) begin
						decode_valid_r <= 0;
						state <= 0;
					end
				end
			endcase
			
`ifdef FORMAL
			assert(s_eventually instr_complete);
`endif
		end
	end
	
	

endmodule