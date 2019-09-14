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
		input				pc_seq,
		input[31:0]			daddr,
		input				dvalid,
		input				dwrite,
		input[31:0]			dwdata,
		input[3:0]			dwstb,
		input[31:0]			drdata,
		input				dready		
		);
	
	reg[7:0] count = 0;
	reg[31:0]		wr_data;
	
	always @(posedge clock) begin
		if (reset) begin
			count <= 0;
		end else begin
			if (instr_complete) begin
				case (op)
					OP_TYPE_ARITH: begin
					end
					default: begin
						`assert(0);
					end
				endcase
			end
			if (count == 15) begin
				`assert(0);
			end else begin
				count <= count + 1;
			end
//			if (instr_complete) begin
//				assert(0);
//			end
		end
	end
	
endmodule
		