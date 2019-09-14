`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_mds_checker(
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
	`include "fwrisc_mul_div_shift_op.svh"
	
	reg[7:0] count = 0;
	reg[31:0]		wr_data;
	reg				instr_c_last;
	reg[31:0]		pc_last;
	reg[2:0]		rd_wr_count;
	reg[5:0]		rd_addr;
	reg[31:0]		rd_val;
	
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
				`assert(rd_waddr == rd);
				rd_val <= rd_wdata;
			end
			if (instr_complete) begin
				`assert(rd_wr_count == 1);
				case (op)
					OP_SLL: `assert(rd_val == (op_a << op_b[4:0]));
					OP_SRL: `assert(rd_val == (op_a >> op_b[4:0]));
					OP_SRA: `assert(rd_val == (op_a >>> op_b[4:0]));
					OP_MUL: `assert(rd_val == ((op_a * op_b) & 32'hffff_ffff));
					OP_MULH: `assert(rd_val == ((op_a * op_b) >> 32));
					default: `assert(0);
				endcase
				rd_wr_count <= 0;
			end
		end
	end
	
endmodule
		