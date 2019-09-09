


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
					7'b0110011: begin // ADD,SUB,SLL,SLT,SLTU,XOR,SRL,SRA
//						assert(rd_raddr == instr[11:7]);
						assert(op_a == instr[19:15]);
						assert(op_b == instr[24:20]);
						assert(rd_raddr == instr[11:7]);
						if (instr[14:12] == 3'b101 || instr[14:12] == 3'b001 || instr[25]) begin
							assert(op_type == OP_TYPE_MDS);
							cover (op == OP_SLL);
							cover (op == OP_SRL);
							cover (op == OP_SRA);
						end else begin
							assert(op_type == OP_TYPE_ARITH);
							cover (op == OP_ADD);
							cover (op == OP_SUB);
							cover (op == OP_LT);
							cover (op == OP_LTU);
							cover (op == OP_XOR);
							cover (op == OP_OR);
							cover (op == OP_AND);
						case (instr[14:12])
							3'b000: begin
								if (instr[30]) begin
									assert(op == OP_SUB);
								end else begin
									assert(op == OP_ADD);
								end
							end
							3'b010: assert(op == OP_LT);
							3'b011: assert(op == OP_LTU);
							3'b100: assert(op == OP_XOR);
							3'b110: assert(op == OP_OR);
							3'b111: assert(op == OP_AND);
						endcase
						end
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
		