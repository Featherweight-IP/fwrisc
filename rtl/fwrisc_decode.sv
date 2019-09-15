/****************************************************************************
 * fwrisc_decode.sv
 ****************************************************************************/

/**
 * Module: fwrisc_decode
 * 
 * The decode module interprets the active instruction, determining the
 * operands passed forward to the exec phase. The decode phase performs
 * any required GPR register reads
 */
module fwrisc_decode #(
		parameter ENABLE_COMPRESSED=1
		)(
		input				clock,
		input				reset,
		
		input				fetch_valid, // valid/accept signals back to fetch
		output				decode_complete, // signals that instr has been accepted
		input[31:0]			instr_i,
		input				instr_c,
		input[31:0]			pc,
	
		// Register file interface
		output reg[5:0]		ra_raddr,
		input[31:0]			ra_rdata,
		output reg[5:0]		rb_raddr,
		input[31:0]			rb_rdata,
	
		// Output to Exec phase
		output 				decode_valid,
		input				exec_complete,
		output reg[31:0]	op_a, 		// operand a (immediate or register)
		output reg[31:0]	op_b, 		// operand b (immediate or register)
		output reg[31:0]	op_c, 		// operand b (immediate or register)
		// Instruction
		output reg[3:0]		op,
		output reg[5:0]		rd_raddr, 	// Destination register address
		output reg[4:0]		op_type
		);
	
	`include "fwrisc_op_type.svh"
	`include "fwrisc_alu_op.svh"
	`include "fwrisc_mul_div_shift_op.svh"
	`include "fwrisc_mem_op.svh"
	`include "fwrisc_csr_addr.svh"
	`include "fwrisc_system_op.svh"

	// Compute various immediate outputs
	wire[31:0]		jal_off = $signed({instr[31], instr[19:12], instr[20], instr[30:21],1'b0});
	wire[31:0]		auipc_imm_31_12 = {instr[31:12], {12{1'b0}}};
	wire[31:0]		imm_11_0 = $signed({instr[31:20]});
	wire[31:0]		st_imm_11_0 = $signed({instr[31:25], instr[11:7]});
	
	wire[31:0]		imm_lui = {instr[31:12], 12'h000};
	wire[31:0]		imm_branch = $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});	
	reg[4:0]		op_type_w;
	wire[31:0]		instr; // 32-bit instruction
	reg				decode_valid_r;

	// Hook in the compressed-instruction expander if compressed
	// instructions are enabled
	generate
		if (ENABLE_COMPRESSED) begin
			wire [31:0]		instr_exp;
			fwrisc_c_decode u_c_decode (
				.clock    (clock        ), 
				.reset    (reset        ), 
				.instr_i  (instr_i[15:0]), 
				.instr    (instr_exp    ));
		
			assign instr = (instr_c)?instr_exp:instr_i;
		end else begin
			assign instr = instr_i;
		end
	endgenerate
	
	// Compressed slices
	
	parameter[3:0]  
		I_TYPE_R = 4'd0,			// 0
		I_TYPE_I = (I_TYPE_R+4'd1),	// 1
		I_TYPE_S = (I_TYPE_I+4'd1),	// 2
		I_TYPE_B = (I_TYPE_S+4'd1),	// 3
		I_TYPE_U = (I_TYPE_B+4'd1),	// 4
		I_TYPE_J = (I_TYPE_U+4'd1)	// 5
		;
	parameter[3:0]
		CI_TYPE_CR   = 4'd0,
		CI_TYPE_CR_P = (CI_TYPE_CR+4'd1),
		CI_TYPE_CI   = (CI_TYPE_CR_P+4'd1),
		CI_TYPE_CI_P = (CI_TYPE_CI+4'd1),
		CI_TYPE_CSS  = (CI_TYPE_CI_P+4'd1),
		CI_TYPE_CIW  = (CI_TYPE_CSS+4'd1),
		CI_TYPE_CL   = (CI_TYPE_CIW+4'd1),
		CI_TYPE_CS   = (CI_TYPE_CL+4'd1),
		CI_TYPE_CB   = (CI_TYPE_CS+4'd1),
		CI_TYPE_CJ   = (CI_TYPE_CB+4'd1)
		;
	reg[2:0]		i_type;
	
	wire			c_rs_rd_eq_0 = (instr[11:7] == 0);
	wire			c_rs_rd_eq_2 = (instr[11:7] == 2);
	wire			c_rs2_eq_0   = (|instr[6:2] == 0);
	wire[5:0]		c_rs1_rd_p   = ({3'b001, instr[9:7]});
	wire[5:0]		c_rd_rs2_p   = ({3'b001, instr[4:2]});
	wire[5:0]		c_rd_rs1     = instr[11:7];
	reg[5:0]		rd_raddr_w;
	
	always @* begin
		op = 0; // TODO
		
//		if (instr_c && ENABLE_COMPRESSED) begin
//			// TODO:
//			op_type_w = 0;
//			op_a = 0;
//			op_b = 0;
//			op_c = 0;
//			ra_raddr = 0;
//			rb_raddr = 0;
//			
//			// Select i_type
//			case (instr[15:13])
//				3'b000,3'b011: i_type = CI_TYPE_CI;
//				3'b001, 3'b101: i_type = CI_TYPE_CJ;
//				3'b010: i_type = CI_TYPE_CL;
//				3'b100: i_type = (&instr[11:10])?CI_TYPE_CR_P:CI_TYPE_CI_P;
//				default /*3'b110,3'b111*/: i_type = CI_TYPE_CB;
//			endcase
//
//			// Select ra_raddr/rb_raddr
//			case (i_type)
//				CI_TYPE_CR: ra_raddr = c_rd_rs1;
//				CI_TYPE_CR_P: ra_raddr = c_rs1_rd_p;
//				default: ra_raddr = 0;
//			endcase
//			
//			// Select rd_raddr
//			case (i_type)
//				CI_TYPE_CI_P, CI_TYPE_CR_P: rd_raddr_w = c_rs1_rd_p;
//				default: rd_raddr_w = 0;
//			endcase
//			
//			// Select op_type
//			// Select op_a/op_b
//			
////			case (instr[1:0])
////			endcase
//			// TODO:
//		end else begin // RV32 instructions
			rd_raddr_w = instr[11:7];
			
			case (instr[6:4])
				3'b001: i_type = (instr[2])?I_TYPE_U:I_TYPE_I;
				3'b010: i_type = I_TYPE_S;
				3'b011: i_type = (instr[2])?I_TYPE_U:I_TYPE_R;
				3'b110: begin
					case (instr[3:2])
						2'b11: i_type = I_TYPE_J; // JAL
						2'b01: i_type = I_TYPE_U; // JALR
						default: i_type = I_TYPE_B; 
					endcase
				end
//				3'b110: op_type = I_TYPE_U; // Assume instr[6:2] == 5'b01101
				default /*3'b110*/: i_type = (instr[2])?I_TYPE_J:I_TYPE_B;
			endcase
		
			// Determine op_type
			case (instr[6:4])
				// TODO:
//				3'b000: op_type_w=(&instr[3:2])?OP_TYPE_FENCE:OP_TYPE_LD;
				3'b000: op_type_w=(&instr[3:2])?OP_TYPE_ARITH:OP_TYPE_LDST;
				3'b001: begin
					if (instr[2]) begin // AUIPC
						op_type_w = OP_TYPE_ARITH;
					end else if (instr[14:12] == 3'b101 || instr[14:12] == 3'b001) begin
						op_type_w = OP_TYPE_MDS;
					end else begin
						op_type_w = OP_TYPE_ARITH;
					end
				end
				// TODO:
//				3'b010: op_type_w = OP_TYPE_ST;
				3'b010: op_type_w = OP_TYPE_LDST;
				3'b011: begin
					if (instr[2]) begin // LUI
						op_type_w = OP_TYPE_ARITH;
					end else if (instr[14:12] == 3'b101 || instr[14:12] == 3'b001 || instr[25]) begin
						op_type_w = OP_TYPE_MDS;
					end else begin
						op_type_w = OP_TYPE_ARITH;
					end
				end
				3'b110: op_type_w = (instr[2])?OP_TYPE_JUMP:OP_TYPE_BRANCH;
				default /*3'b111*/: begin
					op_type_w = (|instr[14:12])?OP_TYPE_CSR:OP_TYPE_CALL;
				end
			endcase
			
//			r_type = (instr[6:4] == 3'b110);
//			i_type = (instr[6:4] == 3'b001 && instr[2] == 0);
//			s_type = (instr[6:4] == 3'b010);
//			b_type = (instr[6:4] == 3'b110 && instr[2] == 0);
//			u_type = (instr[6:2] == 5'b01101 || instr[6:2] == 5'b00101);
//			j_type = (instr[6:2] == 5'b11011);
			
			
			// RS1 and RS2 are always in the same place
			
			case (op_type_w)
				// Read MEPC for MRET
				OP_TYPE_SYSTEM: ra_raddr = CSR_MEPC;
				default: ra_raddr = instr[19:15];
			endcase
					
			case (op_type_w)
				OP_TYPE_CSR: begin
					case (instr[31:24])
						8'hF1: rb_raddr = (CSR_BASE_Q0 | instr[23:20]);
						8'h30: rb_raddr = (CSR_BASE_Q1 | instr[23:20]);
						8'h34: rb_raddr = (CSR_BASE_Q2 | instr[23:20]);
						8'hB0: rb_raddr = (instr[21])?CSR_MINSTRET:CSR_MCYCLE;
						8'hB8: begin
							rb_raddr = (instr[21])?CSR_MINSTRETH:CSR_MCYCLEH;
						end
						8'hBC: begin // custom CSRs
							case (instr[21:20])
								2'b00: rb_raddr = CSR_DEP_LO;
								2'b01: rb_raddr = CSR_DEP_HI;
								default: rb_raddr = CSR_SOFT_RESET;
							endcase
						end
						default: rb_raddr = 0; // ?
					endcase
				end
				default: rb_raddr = instr[24:20];
			endcase
			
			case (i_type) 
				I_TYPE_R, I_TYPE_I, I_TYPE_B: op_a = ra_rdata;
				I_TYPE_U: op_a = imm_lui;
				default: op_a = 0;
			endcase
			
			// Select output for OP-B (rs2)
			case (i_type)
				I_TYPE_R, I_TYPE_S, I_TYPE_B: begin // R-Type/S-Type/B-Type instruction (rs2)
					op_b = rb_rdata;
				end
				I_TYPE_I: begin // I-Type (imm_11_0)
					case (instr[14:12])
						3'b101, 3'b001: begin // Shift
							op_b = instr[24:20];
						end
						3'b011: begin // SLTIU
							op_b = {12'b0, instr[31:20]};
						end
						default: op_b = imm_11_0;
					endcase
				end
				I_TYPE_U: begin
					if (instr[5]) begin // LUI
						op_b = 32'b0;
					end else begin // AUIPC
						op_b = pc;
					end
				end
				default: op_b = 32'b0; // TODO:
			endcase

			case (i_type)
				I_TYPE_B: begin // branch
					op_c = imm_branch;
				end
				default:
					op_c = 32'b0; 
			endcase
			
			case (op_type) 
				OP_TYPE_ARITH: begin
					if (instr[2]) begin // AUIPC or LUI
						op = (instr[5])?OP_OPA:OP_ADD;
					end else begin
						case (instr[14:12]) 
							3'b000: begin
								if (i_type == I_TYPE_R && instr[30]) begin
									op = OP_SUB;
								end else begin
									op = OP_ADD;
								end
							end
							3'b010: op = OP_LT;
							3'b011: op = OP_LTU;
							3'b100: op = OP_XOR;
							3'b110: op = OP_OR;
							default /*3'b111*/ : op = OP_AND;
						endcase
					end
				end
				OP_TYPE_BRANCH: begin
					case (instr[14:12])
						3'b000: op = OP_EQ;
						3'b001: op = OP_NE;
						3'b100: op = OP_LT;
						3'b101: op = OP_GE;
						3'b110: op = OP_LTU;
						default /*3'b111*/: op = OP_GEU;
					endcase
				end
				OP_TYPE_LDST: begin
					case ({instr[5], instr[14:12]})
						4'b0000: op = OP_LB;
						4'b0001: op = OP_LH;
						4'b0010: op = OP_LW;
						4'b0100: op = OP_LBU;
						4'b0101: op = OP_LHU;
						4'b1000: op = OP_SB;
						4'b1001: op = OP_SH;
						default /*4'b1010*/: op = OP_SW;
					endcase
				end
				OP_TYPE_MDS: begin
					case (instr[14:12])
						3'b001: op = OP_SLL;
						3'b101: op = (instr[30])?OP_SRA:OP_SRL;
						
					endcase
				end
				OP_TYPE_SYSTEM: begin
					case (instr[31:28])
						4'b0000: op = (instr[20])?OP_TYPE_EBREAK:OP_TYPE_ECALL;
						default /*4'b0001*/: op = OP_TYPE_ERET;
					endcase
				end
				default: op = 0; // TODO:
				
			endcase
			
//		end
	end

	parameter [1:0]
		STATE_DECODE = 2'd1,
		STATE_REG = (STATE_DECODE + 2'd1)
		;
	reg [1:0]			decode_state;
	
	assign decode_complete = exec_complete;
	assign decode_valid = (decode_valid_r && !exec_complete);
	
	always @(posedge clock) begin
		if (reset) begin
			decode_state <= STATE_DECODE;
			decode_valid_r <= 1'b0;
			rd_raddr <= 0;
		end else begin
			case (decode_state) 
				STATE_DECODE: begin // Wait for data to be valid
					if (fetch_valid) begin
						decode_state <= STATE_REG;
						rd_raddr <= rd_raddr_w;
						op_type <= op_type_w;
						decode_valid_r <= 1'b1;
					end else begin
						decode_valid_r <= 1'b0;
					end
				end
				default /*STATE_REG*/: begin // Register read data is now valid
					if (exec_complete) begin
						decode_state <= STATE_DECODE;
						decode_valid_r <= 1'b0;
					end
				end
			endcase
			
			if (fetch_valid) begin
				// Split instruction and setup appropriate register read
			end
		end
	end


endmodule


