`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_mem_checker(
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
		input[31:0]			mtvec,
		input[31:0]			daddr,
		input				dvalid,
		input				dwrite,
		input[31:0]			dwdata,
		input[3:0]			dwstb,
		input[31:0]			drdata,
		input				dready		
		);
	`include "fwrisc_op_type.svh"
	`include "fwrisc_mem_op.svh"
	
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
				`cover(op == OP_LB);
				`cover(op == OP_LH);
				`cover(op == OP_LBU);
				`cover(op == OP_LHU);
				`cover(op == OP_LW);
				`cover(op == OP_SB);
				`cover(op == OP_SH);
				`cover(op == OP_SW);
//				case (op)
//				endcase
				if (op == OP_LB || op == OP_LH || op == OP_LBU || op == OP_LHU || op == OP_LW) begin
					`assert(rd_wr_count == 1);
				end else begin
					`assert(rd_wr_count == 0);
				end
				rd_wr_count <= 0;
			end
		end
	end
	
endmodule
		