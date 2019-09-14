`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_branch_checker(
		input				clock,
		input				reset,
		input				decode_valid,
		input	 			instr_complete,

		// Indicates whether the instruction is compressed
		input				instr_c,

		input[4:0]			op_type,
		
		input[31:0]			op_a,
		input[31:0]			op_b,
		input[5:0]			op,
		input[31:0]			op_c,
		input[5:0]			rd,
		
		input[5:0]			rd_waddr,
		input[31:0]			rd_wdata,
		input				rd_wen,
		
		input[31:0]			pc,
		// Indicates that the PC is sequential to the last PC
		input				pc_seq,
		input[31:0]			daddr,
		input				dvalid,
		input				dwrite,
		input[31:0]			dwdata,
		input[3:0]			dwstb,
		input[31:0]			drdata,
		input				dready		
		);
	`include "fwrisc_op_type.svh"
	`include "fwrisc_alu_op.svh"
	
	reg[7:0] count = 0;
	reg[31:0]		wr_data;
	reg				instr_c_last;
	reg[31:0]		pc_last;
	wire[31:0]		pc_branch_taken = (pc_last + $signed(op_c[11:0]));
	wire[31:0]		pc_branch_nottaken = (instr_c_last)?(pc_last+31'd2):(pc_last+31'd4);
	
	always @(posedge clock) begin
		if (reset) begin
			count <= 0;
			wr_data <= 0;
			pc_last <= 0;
		end else begin
			if (decode_valid) begin
				pc_last <= pc;
				instr_c_last <= instr_c;
			end
			if (instr_complete) begin
				case (op_type)
					OP_TYPE_BRANCH: begin
						`cover(op==OP_EQ);
						`cover(op==OP_LT);
						`cover(op==OP_LTU);
						`assert(op == OP_EQ || op == OP_LT || op == OP_LTU);
						case (op)
							OP_EQ: begin
								`cover(op_a == op_b);
								`cover(op_a != op_b);
								if (op_a == op_b) begin
									`assert(pc == pc_branch_taken);
									`assert(pc_seq == 0);
								end else begin // branch not taken
									`assert(pc == pc_branch_nottaken);
									`assert(pc_seq == 1);
								end
							end
							
							OP_LT: begin
								`cover($signed(op_a) < $signed(op_b));
								`cover($signed(op_a) >= $signed(op_b));
								if ($signed(op_a) < $signed(op_b)) begin
									`assert(pc == pc_branch_taken);
									`assert(pc_seq == 0);
								end else begin // branch not taken
									`assert(pc == pc_branch_nottaken);
									`assert(pc_seq == 1);
								end
							end
							
							OP_LTU: begin
								`cover(op_a < op_b);
								`cover(op_a >= op_b);
								if (op_a < op_b) begin
									`assert(pc == pc_branch_taken);
									`assert(pc_seq == 0);
								end else begin // branch not taken
									`assert(pc == pc_branch_nottaken);
									`assert(pc_seq == 1);
								end
							end
						endcase
					end
					default: begin
						`assert(0);
					end
				endcase
			end
			if (count == 15) begin
				`assert(1);
			end else begin
				count <= count + 1;
			end
//			if (instr_complete) begin
//				assert(0);
//			end
		end
	end
	
endmodule
		