`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_arith_checker(
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
		
		input[31:1]			pc,
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
	reg[1:0]		rd_wr_count;
	reg[31:0]		rd_wr_data;
	reg[5:0]		rd_wr;
	reg[2:0]		instr_count;
	
	always @(posedge clock) begin
		if (reset) begin
			count <= 0;
			wr_data <= 0;
			rd_wr_count <= 0;
			instr_count <= 0;
		end else begin
			if (rd_wen) begin
				rd_wr_count <= rd_wr_count + 1;
				rd_wr_data <= rd_wdata;
				rd_wr <= rd_waddr;
			end
			
			if (instr_complete) begin
				`assert(rd_wr_count == 1);
				`assert(rd_wr == rd);
				rd_wr_count <= 0;
				instr_count <= instr_count + 1;
				case (op_type)
					OP_TYPE_ARITH: begin
						`cover(op==OP_ADD);
						`cover(op==OP_SUB);
						`cover(op==OP_AND);
						`cover(op==OP_OR);
						`cover(op==OP_CLR);
						`cover(op==OP_EQ);
						`cover(op==OP_LT);
						`cover(op==OP_LTU);
						`cover(op==OP_XOR);
						`cover(op==OP_OPA);
						`cover(op==OP_OPB);
						`assert(op == OP_ADD || op == OP_SUB || op == OP_AND ||
								op == OP_OR || op == OP_CLR || op == OP_EQ ||
								op == OP_LT || op == OP_LTU || op == OP_XOR || 
								op == OP_OPA || op == OP_OPB);
						case (op)
							OP_ADD: begin
								`assert(rd_wr_data == (op_a + op_b));
							end
							OP_SUB: begin
								`assert(rd_wr_data == (op_a - op_b));
							end
							OP_AND: begin
								`assert(rd_wr_data == (op_a & op_b));
							end
							OP_OR: begin
								`assert(rd_wr_data == (op_a | op_b));
							end
							OP_CLR: begin
								`assert(rd_wr_data == (op_b ^ (op_a & op_b)));
							end
							OP_EQ: begin
								`assert(rd_wr_data == (op_a == op_b));
							end
							OP_LT: begin
								`assert(rd_wr_data == ($signed(op_a) < $signed(op_b)));
							end
							OP_LTU: begin
								`assert(rd_wr_data == (op_a < op_b));
							end
							OP_XOR: begin
								`assert(rd_wr_data == (op_a ^ op_b));
							end
							OP_OPA: begin
								`assert(rd_wr_data == op_a);
							end
							OP_OPB: begin
								`assert(rd_wr_data == op_b);
							end
							default: begin
								`assert(0);
							end
						endcase
					end
					default: begin
						`assert(0);
					end
				endcase
			end
			`cover(instr_count == 2);
		end
	end
	
endmodule
		