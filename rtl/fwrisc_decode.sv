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
		output				decode_valid,
		input				exec_ready,
		output reg[31:0]	op_a, 		// operand a (immediate or register)
		output reg[31:0]	op_b, 		// operand b (immediate or register)
		output reg[5:0]		rd_raddr, 	// Destination register address
		output reg[31:0]	op_imm,		// Immediate operand (S-type, B-type)
		output reg			op_ld,
		output reg			op_st
		);

	// Compute various immediate outputs
	reg[31:0]		jal_off;
	reg[31:0]		auipc_imm_31_12;
	reg[31:0]		imm_11_0;
	reg[31:0]		st_imm_11_0;
	
	reg[31:0]		imm_lui;
	reg[31:0]		imm_branch;
	reg				r_type, i_type, s_type, b_type, u_type, j_type;
	reg				rd_valid;
	
	always @* begin
		if (instr_c && ENABLE_COMPRESSED) begin
			// TODO:
		end else begin
			jal_off = $signed({instr[31], instr[19:12], instr[20], instr[30:21],1'b0});
			auipc_imm_31_12 = {instr[31:12], {12{1'b0}}};
			imm_11_0 = $signed({instr[31:20]});
			st_imm_11_0 = $signed({instr[31:25], instr[11:7]});
			imm_lui = {instr[31:12], 12'h000};
			imm_branch = $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});	
			
			r_type = (instr[6:4] == 3'b110);
			i_type = (instr[6:4] == 3'b001 && instr[2] == 0);
			s_type = (instr[6:4] == 3'b010);
			b_type = (instr[6:4] == 3'b110 && instr[2] == 0);
			u_type = (instr[6:2] == 3'b01101 || instr[6:2] == 3'b00101);
			j_type = (instr[6:2] == 3'b11011);
			
			
			// RS1 and RS2 are always in the same place
			// TODO: integrate CSR addressing
			ra_raddr = instr[19:15];
			rb_raddr = instr[24:20];
		end
	end
	
	reg [1:0]			decode_state;
	
	assign decode_ready = exec_ready;
	assign decode_valid = (decode_state == 2'b01);
	
	always @(posedge clock) begin
		if (reset) begin
			decode_state <= 2'b00;
		end else begin
			case (decode_state) 
				2'b00: begin // Wait for data to be valid
					if (fetch_valid) begin
						decode_state <= 2'b01;
					end
				end
				2'b01: begin // Register read data is now valid
					// Select output for OP-A
					case ({r_type})
						1'b1: begin // R-Type instruction
							op_a <= ra_rdata;
						end
					endcase
				
					// Select output for OP-B (rs2)
					case ({(r_type|s_type|b_type),i_type})
						2'b10: begin // R-Type/S-Type/B-Type instruction (rs2)
							op_b <= rb_rdata;
						end
						2'b01: begin // I-Type (imm_11_0)
							op_b <= imm_11_0;
						end
						default: op_b <= 32'b0;
					endcase
			
					if (exec_ready) begin
						decode_state <= 2'b00;
					end
				end
			endcase
			
			if (fetch_valid) begin
				// Split instruction and setup appropriate register read
			end
		end
	end


endmodule


