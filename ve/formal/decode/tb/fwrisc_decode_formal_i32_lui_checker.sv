


module fwrisc_decode_formal_checker(
		// TODO: fill in port list
		input				clock,
		input				reset,
		input[31:0]			instr,
		input				instr_c,
		
		input				decode_valid,
		input[31:0]			op_a, 		// operand a (immediate or register)
		input[31:0]			op_b, 		// operand b (immediate or register)
		input[31:0]			op_c,		// immediate operand
		input[3:0]			op,
		input[5:0]			rd_raddr, 	// Destination register address
		input[4:0]			op_type
		);
	`include "fwrisc_op_type.svh"
	`include "fwrisc_alu_op.svh"
	
	reg[5:0]			count = 0;
	
	wire[31:0]			u_imm = {instr[31:12], 12'b0};
	wire[31:0]			imm_11_0_s = $signed(instr[31:20]);
	wire[31:0]			imm_11_0_u = instr[31:20];
	wire[31:0]			imm_b = $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});
	
	always @(posedge clock) begin
		if (reset == 0) begin
			count <= count + 1;
			cover(count == 15);
			cover(decode_valid);
			if (decode_valid) begin
				case (instr[6:0]) 
					7'b0110111: begin // LUI
						assert(rd_raddr == instr[11:7]);
						assert(op_a == u_imm);
						assert(op_type == OP_TYPE_ARITH);
						assert(op == OP_OPA);
					end
						
					default: begin
						assert(0);
					end
				endcase
				// 
			end
		end
	end
	
endmodule
		