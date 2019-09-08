`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_csr_checker(
		input				clock,
		input				reset,
		input				decode_valid,
		input	 			instr_complete,

		// Indicates whether the instruction is compressed
		input				instr_c,

		input[4:0]			op_type,
		
		input[31:0]			op_a, // jump_base
		input[31:0]			op_b, // always zero
		input[5:0]			op,
		input[31:0]			op_c, // jump_offset
		input[5:0]			rd,
		
		input[5:0]			rd_waddr,
		input[31:0]			rd_wdata,
		input				rd_wen,
		
		input[31:0]			pc,
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
	reg				instr_c_last;
	reg[31:0]		pc_last;
	reg[2:0]		rd_wr_count;
	reg[5:0]		rd_addr;
	reg[31:0]		rd_val;
	reg[31:0]		csr_val;
	
	always @(posedge clock) begin
		if (reset) begin
			count <= 0;
			wr_data <= 0;
			pc_last <= 0;
			rd_wr_count <= 0;
			rd_val <= 0;
		end else begin
			if (decode_valid) begin
				pc_last <= pc;
				instr_c_last <= instr_c;
			end
			if (rd_wen) begin
				rd_wr_count <= rd_wr_count + 1;
				assert(rd_waddr == rd || rd_waddr == op_c);
				if (rd_waddr == rd) begin
					rd_val <= rd_wdata;
				end else begin
					csr_val <= rd_wdata;
				end
			end
			if (instr_complete) begin
				`assert(rd_wr_count == 2);
				`assert(rd_val == op_b); // original CSR value
				`assert(op == OP_OPA || op == OP_OR || op == OP_CLR);
				`cover(op == OP_OPA);
				`cover(op == OP_OR);
				`cover(op == OP_CLR);
				
				case (op)
					OP_OPA: begin
						`assert(csr_val == op_a); // RS1
					end
					OP_OR: begin
						`assert(csr_val == (op_a | op_b));
					end
					OP_CLR: begin
						`assert(csr_val == (op_b ^ (op_a & op_b)));
					end
					default: `assert(0);
				endcase
				rd_wr_count <= 0;
			end
		end
	end
	
endmodule
		