/****************************************************************************
 * fwrisc_fetch.sv
 *
 * Copyright 2018 Matthew Ballance
 * 
 * Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in
 * writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See
 * the License for the specific language governing
 * permissions and limitations under the License.
 ****************************************************************************/

/**
 * Module: fwrisc_fetch
 * 
 * TODO: Add module documentation
 */
module fwrisc_fetch #(
		parameter ENABLE_COMPRESSED=1
		)(
		input				clock,
		input				reset,

		// Input
		input[31:0]			next_pc,
		input				next_pc_seq, // The next instruction follows the previous
		
		// Instruction-fetch interface
		output reg[31:0]	iaddr,
		input[31:0]			idata,
		output 				ivalid,
		input				iready,
		
		// Output to decode stage
		output 			    fetch_valid, // Indicates that 'instr' is valid
		input				decode_complete, // Signals that decode is done with instr
		output reg[31:0]	instr,
		output reg			instr_c
		);
	
	reg[2:0]		state;
	reg[15:0]		instr_cache;
	// Indicates whether the cached half-word is also compressed
	wire 			instr_cache_c = (&instr_cache[1:0] != 1);
	reg				instr_cache_valid;
	// Note: Compressed instructions have 00, 01, or 10 low bits
	// Low half-word is a compressed instruction
	wire			instr_c_lo = (idata[1:0] != 2'b11);
	// High half-word is a compressed instruction
	wire			instr_c_hi = (idata[17:16] != 2'b11);
	
	wire			instr_c_next = (next_pc[1])?instr_c_hi:instr_c_lo;
	
	parameter [2:0]
		STATE_FETCH1 = 3'd0,
		STATE_FETCH2 = (STATE_FETCH1 + 3'd1),
		STATE_WAIT_DECODE = (STATE_FETCH2 + 3'd1)
		;

	reg fetch_valid_r;	
	// Always perform aligned fetches
	assign fetch_valid = (fetch_valid_r && !decode_complete);
	reg ivalid_r;
	assign ivalid = (ivalid_r /*&& iready == 0*/); 
	
	always @(posedge clock) begin
		if (reset) begin
			state <= STATE_FETCH1;
			instr_cache_valid <= 0;
			instr_cache <= {16{1'b0}};
			fetch_valid_r <= 0;
			ivalid_r <= 0;
			instr_c <= 0;
			instr <= {32{1'b0}};
		end else begin 
			// 
			case (state)
				default /*STATE_FETCH1*/: begin // Wait for fetch to complete
					if (iready && ivalid_r) begin
						if (ENABLE_COMPRESSED) begin
							instr_c <= instr_c_next;
							// Decide what to do based on alignment and fetched data
							case ({next_pc[1], instr_c_next})
								2'b00: begin // Aligned fetch of a 32-bit instruction
									instr <= idata;
									instr_cache_valid <= 0;
									fetch_valid_r <= 1;
									ivalid_r <= 0;
									state <= STATE_WAIT_DECODE; // Wait for instruction to be accepted
								end
								2'b01: begin // Aligned fetch of a 16-bit instruction
									instr <= idata[15:0];
									instr_cache <= idata[31:16];
									instr_cache_valid <= 1;
									fetch_valid_r <= 1;
									ivalid_r <= 0;
									state <= STATE_WAIT_DECODE; // Wait for instruction to be accepted
								end
								2'b10: begin // Unaligned fetch of a 32-bit instruction
									// We received the first half
									instr[15:0] <= idata[31:16];
									instr_cache_valid <= 0;
									ivalid_r <= 1;
									iaddr <= {next_pc[31:2]+1'd1, 2'b0};
									state <= STATE_FETCH2; // Need to fetch upper half-word
								end
								2'b11: begin // Fetch the high half-word
									instr[15:0] <= idata[31:16];
									instr_cache_valid <= 0;
									ivalid_r <= 0;
									fetch_valid_r <= 1;
									state <= STATE_WAIT_DECODE; 
								end
							endcase
						end else begin // COMPRESSED not enabled
							instr_c <= 1'b0;
							instr <= idata;
							instr_cache_valid <= 0;
							fetch_valid_r <= 1;
							ivalid_r <= 0;
							state <= STATE_WAIT_DECODE; // Wait for instruction to be accepted
						end
					end else begin
						ivalid_r <= 1;
						iaddr <= {next_pc[31:2], 2'b0};
					end
				end
						
				STATE_WAIT_DECODE: begin // Wait for instruction to be accepted
					if (decode_complete) begin
						// Decide what to do next based on current state
						// - Go back to fetch if the instr_cache is not valid or the next instruction is nonsequential
						// - 
						fetch_valid_r <= 0;
						// TODO: for now, we always go back to fetch
						// This is wasteful, but reliable
						state <= STATE_FETCH1;
						instr <= {32{1'b0}};
`ifdef UNDEFINED
						if (!next_pc_seq) begin
							instr_cache_valid <= 0;
							state <= STATE_FETCH1; // Back to the beginning with a fresh slate
						end else begin
							// PC is sequential
							
							case ({instr_c, instr_cache_valid, instr_cache_c})
								// If the current instruction is compressed
								// and the instruction cache is valid, then we 
								// can use the instruction cache for the next instruction
								3'b111: begin 
									instr_cache_valid <= 0;
									instr <= instr_cache;
									instr_c <= 1;
									state <= 3'b001; 
								end
								default: begin
									// Go back and fetch from scratch
									instr_cache_valid <= 0;
									state <= STATE_FETCH1;
								end
							endcase
						end
`endif
					end
				end
				
				STATE_FETCH2: begin // Wait for fetch of upper half-word to complete
					if (iready) begin
						ivalid_r <= 0;
						// Fetch of upper half-word is complete
						instr[31:16] <= idata[15:0];
						instr_c <= (instr[1:0] != 2'b11);
						
						// Cache the leftover data for later 
						instr_cache <= idata[31:16];
						instr_cache_valid <= 1;
						
						fetch_valid_r <= 1;
						state <= STATE_WAIT_DECODE; // Wait for instruction to be accepted
					end
				end
			endcase
		end
	end

endmodule


