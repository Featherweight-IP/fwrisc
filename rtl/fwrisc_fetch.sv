/****************************************************************************
 * fwrisc_fetch.sv
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
		input[31:1]			next_pc,
		input				next_pc_seq, // The next instruction follows the previous
		
		// Instruction-fetch interface
		output[31:0]		iaddr,
		input[31:0]			idata,
		output				ivalid,
		input				iready,
		
		// Output to decode stage
		output 			fetch_valid, // Indicates that 'instr' is valid
		input				decode_ready, // Signals that decode is done with instr
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
	wire			instr_c_lo = (&idata[1:0] != 1);
	// High half-word is a compressed instruction
	wire			instr_c_hi = (&idata[17:16] != 1);
	
	wire			instr_c_next = (next_pc[1])?instr_c_hi:instr_c_lo;
	
	// Always perform aligned fetches
	assign iaddr = (state == 3'b000)?{next_pc[31:2], 2'b0}:{next_pc[31:2]+1'b1, 2'b0};
	assign fetch_valid = (state == 3'b001);
	assign ivalid = (state == 3'b000 || state == 3'b010);
	
	always @(posedge clock) begin
		if (reset) begin
			state <= 0;
			instr_cache_valid <= 0;
		end else begin 
			// 
			case (state)
				3'b000: begin // Wait for fetch to complete
					if (ivalid && iready) begin
						instr_c <= instr_c_next;
						// Decide what to do based on alignment and fetched data
						case ({next_pc[1], instr_c_next})
							2'b00: begin // Aligned fetch of a 32-bit instruction
								instr <= idata;
//								fetch_valid <= 1;
								instr_cache_valid <= 0;
								state <= 3'b001; // Wait for instruction to be accepted
							end
							2'b01: begin // Aligned fetch of a 16-bit instruction
								instr <= idata[15:0];
								instr_cache <= idata[31:16];
								instr_cache_valid <= 1;
								state <= 3'b001; // Wait for instruction to be accepted
							end
							2'b10: begin // Unaligned fetch of a 32-bit instruction
								// We received the first half
								instr[15:0] <= idata[31:16];
								instr_cache_valid <= 0;
								state <= 3'b010; // Need to fetch upper half-word
							end
						endcase
					end
				end
						
				3'b001: begin // Wait for instruction to be accepted
					if (decode_ready) begin
						// Decide what to do next based on current state
						// - Go back to fetch if the instr_cache is not valid or the next instruction is nonsequential
						// - 
						if (!next_pc_seq) begin
							instr_cache_valid <= 0;
							state <= 3'b000; // Back to the beginning with a fresh slate
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
									state <= 3'b000;
								end
							endcase
						end
					end
				end
				
				3'b010: begin // Wait for fetch of upper half-word to complete
					if (ivalid && iready) begin
						// Fetch of upper half-word is complete
						instr[31:16] <= idata[15:0];
						
						// Cache the leftover data for later 
						instr_cache <= idata[31:16];
						instr_cache_valid <= 1;
						
						state <= 3'b001; // Wait for instruction to be accepted
					end
				end
			endcase
		end
	end

endmodule


