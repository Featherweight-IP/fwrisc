


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
					7'b1100011: begin // beq, bne, blt, bge, bltu, bgeu
						assert(op_a == instr[19:15]);
						assert(op_b == instr[24:20]);
						assert(op_c == imm_b);
						assert(op >= OP_EQ && op <= OP_GEU);
						case (instr[14:12])
							3'b000: assert(op == OP_EQ);
							3'b001: assert(op == OP_NE);
							3'b100: assert(op == OP_LT);
							3'b101: assert(op == OP_GE);
							3'b110: assert(op == OP_LTU);
							3'b111: assert(op == OP_GEU);
							default: assert(0);
						endcase
						cover(op == OP_EQ);
						cover(op == OP_NE);
						cover(op == OP_LT);
						cover(op == OP_GE);
						cover(op == OP_LTU);
						cover(op == OP_GEU);
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
		