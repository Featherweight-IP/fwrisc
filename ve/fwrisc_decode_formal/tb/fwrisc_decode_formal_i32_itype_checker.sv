


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
	`include "fwrisc_mul_div_shift_op.svh"
	
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
					7'b0010011: begin // ADDI, SLTI, SLTIU, XORI, ORI, ANDI
						assert(op_a == instr[19:15]);
						cover (op == OP_ADD);
						cover (op == OP_LT);
						cover (op == OP_LTU);
						cover (op == OP_XOR);
						cover (op == OP_OR);
						cover (op == OP_AND);
						case (instr[14:12])
							3'b000: assert(op == OP_ADD);
							3'b010: assert(op == OP_LT);
							3'b011: assert(op == OP_LTU);
							3'b100: assert(op == OP_XOR);
							3'b110: assert(op == OP_OR);
							3'b111: assert(op == OP_AND);
						endcase
						if (instr[14:12] == 3'b011) begin // SLTIU
							assert(op_b == imm_11_0_u);
						end else begin
							assert(op_b == imm_11_0_s);
							assert(op_type == OP_TYPE_ARITH);
						end
						assert(rd_raddr == instr[11:7]);
						cover(rd_raddr != 0);
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
		