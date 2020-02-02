
`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_mds_test(
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
	`include "fwrisc_mul_div_shift_op.svh"
	
	reg[1:0]		state;
	reg				decode_valid_r;
	wire[31:0]		st_data = `anyconst;
	wire[31:0]		mem_base = `anyconst;
	wire[7:0]		mem_off = `anyconst;
	wire[31:0]		op_a_w = `anyconst;
	wire[31:0]		op_b_w = `anyconst;
	
	wire[5:0]		rd_w;
	assign rd_w[5] = 0;
	assign rd_w[4:0] = `anyconst;
	wire[3:0]		mds_op = `anyconst;
	
	assign decode_valid = (decode_valid_r && !instr_complete);
	
	always @(posedge clock) begin
		if (reset) begin
			state <= 0;
			instr_c <= 0;
			op_type <= OP_TYPE_MDS;
			op_a <= 0; 
			op_b <= 0; 
			op <= 0; 
			op_c <= 0; 
			rd <= 0;
			decode_valid_r <= 0;
			mtvec <= 0;
		end else begin
			case (state)
				0: begin
					// Send out a new instruction
					decode_valid_r <= 1;
					state <= 1;

`ifdef FORMAL
					op <= (mds_op % OP_NUM_MDS);
					op_b <= st_data;
`else
					op <= (op_w % OP_NUM_MDS); // start with just shift
					op_b <= 0;
`endif
					
					// Specify where the load is going
					rd <= rd_w;
					
					// Select base address and offset
					case (mds_op % OP_NUM_MDS)
						OP_SLL, OP_SRL, OP_SRA: begin
							op_a <= op_a_w;
							op_b <= op_b_w[4:0];
						end
						default /*OP_MUL*/: begin
							op_a <= op_a_w;
							op_b <= op_b_w;
						end
					endcase
				end
				1: begin
					if (instr_complete) begin
						`cover(op == OP_SLL);
						`cover(op == OP_SRL);
						`cover(op == OP_SRA);
						`cover(op == OP_MUL);
						`cover(op == OP_MULH);
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