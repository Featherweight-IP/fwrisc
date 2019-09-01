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
		output				decode_ready, // signals that instr has been accepted
		input[31:0]			instr,
		input				instr_c,
	
		// Register file interface
		output reg[5:0]		ra_raddr,
		input[31:0]			ra_rdata,
		output reg[5:0]		rb_raddr,
		input[31:0]			rb_rdata,
	
		// Output to Exec phase
		output reg			decode_valid,
		input				exec_ready,
		output reg[31:0]	op_a, 		// operand a (immediate or register)
		output reg[31:0]	op_b, 		// operand b (immediate or register)
		output reg[31:0]	op_c, 		// operand b (immediate or register)
		output reg[5:0]		rd_raddr, 	// Destination register address
		output reg[4:0]		op_type
		);
	
	`include "fwrisc_op_type.svh"

	// Compute various immediate outputs
	reg[31:0]		jal_off;
	reg[31:0]		auipc_imm_31_12;
	reg[31:0]		imm_11_0;
	reg[31:0]		st_imm_11_0;
	
	reg[31:0]		imm_lui;
	reg[31:0]		imm_branch;
	reg				rd_valid;
	
	parameter[2:0]  
		I_TYPE_R = 3'd0,
		I_TYPE_I = (I_TYPE_R+3'd1),
		I_TYPE_S = (I_TYPE_I+3'd1),
		I_TYPE_B = (I_TYPE_S+3'd1),
		I_TYPE_U = (I_TYPE_B+3'd1),
		I_TYPE_J = (I_TYPE_U+3'd1)
		;
	reg[2:0]		i_type;
	
	always @* begin
	`ifdef UNDEFINED
		if (instr_c && ENABLE_COMPRESSED) begin
			// TODO:
		end else begin
	`endif
			jal_off = $signed({instr[31], instr[19:12], instr[20], instr[30:21],1'b0});
			auipc_imm_31_12 = {instr[31:12], {12{1'b0}}};
			imm_11_0 = $signed({instr[31:20]});
			st_imm_11_0 = $signed({instr[31:25], instr[11:7]});
			imm_lui = {instr[31:12], 12'h000};
			imm_branch = $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});	
			
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
			
//			r_type = (instr[6:4] == 3'b110);
//			i_type = (instr[6:4] == 3'b001 && instr[2] == 0);
//			s_type = (instr[6:4] == 3'b010);
//			b_type = (instr[6:4] == 3'b110 && instr[2] == 0);
//			u_type = (instr[6:2] == 5'b01101 || instr[6:2] == 5'b00101);
//			j_type = (instr[6:2] == 5'b11011);
			
			
			// RS1 and RS2 are always in the same place
			// TODO: integrate CSR addressing
			ra_raddr = instr[19:15];
			rb_raddr = instr[24:20];
			
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
				default: op_b = 32'b0; // TODO:
			endcase

			case (i_type)
				I_TYPE_B: begin // branch
					op_c = imm_branch;
				end
				default:
					op_c = 32'b0; 
			endcase
			
			op_type = 32'b0; // TODO:
			
	`ifdef UNDEFINED
		end
	`endif
	end

	parameter [1:0]
		STATE_DECODE = 2'd1,
		STATE_REG = (STATE_DECODE + 2'd1)
		;
	reg [1:0]			decode_state;
	
	assign decode_ready = exec_ready;
	
	always @(posedge clock) begin
		if (reset) begin
			decode_state <= STATE_DECODE;
			decode_valid <= 1'b0;
			rd_raddr <= 0;
		end else begin
			case (decode_state) 
				STATE_DECODE: begin // Wait for data to be valid
					if (fetch_valid) begin
						decode_state <= STATE_REG;
						rd_raddr <= instr[11:7];
						decode_valid <= 1'b1;
					end else begin
						decode_valid <= 1'b0;
					end
				end
				default /*STATE_REG*/: begin // Register read data is now valid
					if (exec_ready) begin
						decode_state <= STATE_DECODE;
						decode_valid <= 1'b0;
					end
				end
			endcase
			
			if (fetch_valid) begin
				// Split instruction and setup appropriate register read
			end
		end
	end


endmodule


