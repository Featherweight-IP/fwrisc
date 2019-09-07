`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_checker(
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
		
		input[5:0]			rd_waddr,
		input[31:0]			rd_wdata,
		input				rd_wen,
		
		input[31:1]			pc,
		// Indicates that the PC is sequential to the last PC
		input				pc_seq		
		// TODO: fill in port list
		);
	`include "fwrisc_op_type.svh"
	`include "fwrisc_alu_op.svh"
	
	reg[7:0] count = 0;
	reg[31:0]		wr_data;
	(* keep *)
	reg[31:0]		exp_data;
	
	always @(posedge clock) begin
		if (reset) begin
			count <= 0;
			wr_data <= 0;
		end else begin
			if (instr_complete) begin
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
						`assert(op == OP_ADD || op == OP_SUB || op == OP_AND ||
								op == OP_OR || op == OP_CLR || op == OP_EQ ||
								op == OP_LT || op == OP_LTU || op == OP_XOR);
						case (op)
							OP_ADD: begin
								exp_data <= (op_a + op_b);
								`assert(rd_wdata == (op_a + op_b));
							end
							OP_SUB: begin
								exp_data <= (op_a - op_b);
								`assert(rd_wdata == (op_a - op_b));
							end
							OP_AND: begin
								exp_data <= (op_a & op_b);
								`assert(rd_wdata == (op_a & op_b));
							end
							OP_OR: begin
								exp_data <= (op_a | op_b);
								`assert(rd_wdata == (op_a | op_b));
							end
							OP_CLR: begin
								exp_data <= (op_a ^ (op_a & op_b));
								`assert(rd_wdata == (op_a ^ (op_a & op_b)));
							end
							OP_EQ: begin
								exp_data <= (op_a == op_b);
								`assert(rd_wdata == (op_a == op_b));
							end
							OP_LT: begin
								exp_data <= ($signed(op_a) < $signed(op_b));
								`assert(rd_wdata == ($signed(op_a) < $signed(op_b)));
							end
							OP_LTU: begin
								exp_data <= (op_a < op_b);
								`assert(rd_wdata == (op_a < op_b));
							end
							OP_XOR: begin
								exp_data <= (op_a ^ op_b);
								`assert(rd_wdata == (op_a ^ op_b));
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
		