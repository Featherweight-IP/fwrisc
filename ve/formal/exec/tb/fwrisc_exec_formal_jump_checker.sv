`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_jump_checker(
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
	
	wire[31:0]		opa_plus_opc = $signed(op_a) + $signed(op_c);
	
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
				rd_addr <= rd_waddr;
				rd_val <= rd_wdata;
			end
			if (instr_complete) begin
				`cover(1);
				// op_a is jump_base
				`assert(pc == opa_plus_opc);
				`assert(rd_wr_count == 1);
				if (instr_c) begin
					`assert(rd_val == (pc_last + 2));
				end else begin
					`assert(rd_val == (pc_last + 4));
				end
				rd_wr_count <= 0;
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
		