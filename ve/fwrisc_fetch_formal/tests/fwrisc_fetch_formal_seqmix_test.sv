/****************************************************************************
 * fwrisc_fetch_formal_seq32_test.sv
 ****************************************************************************/

/**
 * Module: fwrisc_fetch_formal_seq_test
 * 
 * TODO: Add module documentation
 */
module fwrisc_fetch_formal_test(
		input				clock,
		input				reset,
		output reg[31:1]	next_pc,
		output reg			next_pc_seq,
		input[31:0]			iaddr,
		output[31:0]		idata,
		input				ivalid,
		output 				iready,
		input				fetch_valid,
		output				decode_ready,
		input[31:0]			instr,
		input				instr_c
		);
	
	// Instruction-memory unit
	assign iready = 1;
	// 'h63010000
	// 'h00376301
	// 'h00000037
	// 'h6301
	always @* begin
		case (iaddr[3:2])
			2'b00: idata = 'h63010000;
			2'b01: idata = 'h00376301;
			2'b10: idata = 'h00376301;
			2'b11: idata = 'h63010000;
		endcase
	end
	
	reg[3:0] fetch_count;
	always @(posedge clock) begin
		if (reset) begin
			fetch_count <= 0;
		end else begin
			if (iready && ivalid) begin
				fetch_count <= fetch_count + 1;
			end
			cover(fetch_count == 3);
		end
		
	end
	
	// Decode unit
	reg[1:0] decode_state = 0;
	reg[3:0] instr_count = 0;
	// decode_ready signals that the instruction is complete
	assign decode_ready = (decode_state == 2'b11);
	always @(posedge clock) begin
		if (reset) begin
			next_pc <= 0;
			next_pc_seq <= 1;
			decode_state <= 0;
			instr_count <= 0;
		end else begin
			case (decode_state)
				2'b00: begin // wait for fetch to complete
					if (fetch_valid) begin
						decode_state <= 2'b01;
					end
				end
				2'b01: begin // instruction executing
					decode_state <= 2'b10;
				end
				
				2'b10: begin // instruction executing
					decode_state <= 2'b11;
				end
				
				2'b11: begin // ready for next instruction
					next_pc <= next_pc + 1;
					next_pc_seq <= 1;
					instr_count <= instr_count + 1;
					decode_state <= 2'b00;
				end
			endcase
			cover (instr_count == 3);
		end
	end

endmodule


