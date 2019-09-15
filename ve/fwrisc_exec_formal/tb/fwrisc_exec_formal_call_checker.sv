`include "fwrisc_exec_formal_defines.svh"


module fwrisc_exec_formal_call_checker(
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
	`include "fwrisc_csr_addr.svh"
	`include "fwrisc_mul_div_shift_op.svh"
	`include "fwrisc_system_op.svh"
	
	reg[7:0] count = 0;
	reg[31:0]		wr_data;
	reg				instr_c_last;
	reg[31:0]		pc_last;
	reg[2:0]		rd_wr_count;
	reg[5:0]		rd_addr;
	reg[31:0]		mcause;
	reg[31:0]		mepc;
	reg[31:0]		mtval;
	
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
				if (rd_waddr == CSR_MEPC) begin
					mepc <= rd_wdata;
				end
				if (rd_waddr == CSR_MTVAL) begin
					mtval <= rd_wdata;
				end
				if (rd_waddr == CSR_MCAUSE) begin
					mcause <= rd_wdata;
				end
			end
			if (instr_complete) begin
				if (op == OP_TYPE_EBREAK || op == OP_TYPE_ECALL) begin
					`assert(rd_wr_count == 3);
					`assert(mepc == pc_last);
					if (op == OP_TYPE_EBREAK) begin
						`assert(mcause == 3); // breakpoint
					end else begin
						`assert(mcause == 11); // call
					end
					`assert(pc[31:2] == mtvec[31:2]);
				end else begin
					// ERET
					`assert(pc[31:2] == op_a[31:2]);
				end
				rd_wr_count <= 0;
			end
		end
	end
	
endmodule
		