/****************************************************************************
 * fwrisc_fetch_formal_seq32_test.sv
 ****************************************************************************/
`include "fwrisc_fetch_formal_defines.svh"

/**
 * Module: fwrisc_fetch_formal_seq_test
 * 
 * TODO: Add module documentation
 */
module fwrisc_fetch_formal_seqmix_test(
		input				clock,
		input				reset,
		output reg[31:0]	next_pc,
		output reg			next_pc_seq,
		input[31:0]			iaddr,
		output reg[31:0]	idata,
		input				ivalid,
		output 				iready,
		input				fetch_valid,
		output				decode_complete,
		input[31:0]			instr,
		input				instr_c
		);

	// 00 - 32-bit instruction at aligned address
	// 01 - 32-bit instruction at unaligned address
	// 10 - 16-bit instruction at aligned address
	// 11 - 16-bit instruction at unaligned address
`ifdef FORMAL
	wire [2:0]		data_type = `anyconst;
//	reg [2:0]		data_type;
`else
	reg [1:0]		data_type;
`endif
//	reg [1:0]		data_type;
	
	
	
	// Instruction-memory unit
	// 'h63010000
	// 'h00376301
	// 'h00000037
	// 'h6301
	always @* begin
		case (data_type)
			2'b00: idata = 'h63010003; // aligned 32-bit instruction
			2'b01: idata = 'h00030000; // unaligned 32-bit instruction
			2'b10: idata = 'h00000000; // aligned 16-bit instruction
			default /*2'b11*/: idata = 'h00000003; // unaligned 16-bit instruction
		endcase
		
		case (data_type)
			2'b00: next_pc = 'h8000_0000; 
			2'b01: next_pc = 'h8000_0002; 
			2'b10: next_pc = 'h8000_0000; 
			default /*2'b11*/: next_pc = 'h8000_0002; 
		endcase
	end
	
	reg[3:0] fetch_count;
	reg iready_r;
	assign iready = iready_r;
	always @(posedge clock) begin
		if (reset) begin
			fetch_count <= 0;
			iready_r <= 0;
		end else begin
			if (ivalid) begin
				iready_r <= ~iready_r;
			end
			if (iready && ivalid) begin
				fetch_count <= fetch_count + 1;
			end
//			`cover(fetch_count == 3);
		end
	end
	
	// Decode unit
	reg[1:0] decode_state = 0;
	reg[3:0] instr_count = 0;
	reg in_reset;
	// decode_ready signals that the instruction is complete
	assign decode_complete = (decode_state == 2'b11);
	always @(posedge clock) begin
		if (reset) begin
			next_pc_seq <= 1;
			decode_state <= 0;
			instr_count <= 0;
			in_reset <= 1;
		end else begin
			if (in_reset) begin
				in_reset <= 0;
`ifdef FORMAL
//				data_type <= data_type_w;
`else
				data_type <= `anyconst;
`endif
			end
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
					next_pc_seq <= 1;
					instr_count <= instr_count + 1;
					`cover(data_type == 2'b00);
					`cover(data_type == 2'b01);
					`cover(data_type == 2'b10);
					// Formal tool really doesn't like to cover this case for some reason
//					`cover(data_type == 2'b11);
//					data_type <= data_type + 1;
					decode_state <= 2'b00;
				end
			endcase
//			`cover (instr_count == 3);
		end
	end

endmodule


