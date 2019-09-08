
`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_csr_test(
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
		output reg[5:0]			rd
		
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
	wire[5:0]		csr_w;
	assign csr_w[5] = 0;
	assign csr_w[4:0] = `anyconst;
	wire[31:0]		op_a_w = `anyconst;
	wire[31:0]		op_b_w = `anyconst;
	
	assign decode_valid = (decode_valid_r && !instr_complete);
	
	always @(posedge clock) begin
		if (reset) begin
			state <= 0;
			instr_c <= 0;
			op_type <= OP_TYPE_CSR;
			op_a <= 0; 
			op_b <= 0; 
			op <= OP_OPA; 
			op_c <= 0; 
			rd <= 0;
			decode_valid_r <= 0;
		end else begin
			case (state)
				0: begin
					// Send out a new instruction
					decode_valid_r <= 1;
					instr_c <= instr_c_w;
					case (op_w)
						2'b00: op <= OP_OPA; // store regs[rs1] to CSR
						2'b01: op <= OP_OR; // set regs[csr] <= regs[csr] | regs[rs1]
						default: op <= OP_CLR; // set regs[csr] <= regs[csr] | regs[rs1]
					endcase
					rd <= rd_w;
					op_a <= op_a_w;
					op_b <= op_b_w;
					rd <= rd_w;
					op_c <= csr_w;
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