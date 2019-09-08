
`include "fwrisc_fetch_formal_defines.svh"


module fwrisc_fetch_formal_seqmix_checker(
		input				clock,
		input				reset,
		input[31:0]			next_pc,
		input	 			next_pc_seq,
		input[31:0]			iaddr,
		input[31:0]			idata,
		input				ivalid,
		input				iready,
		input				fetch_valid,
		input				decode_complete,
		input[31:0]			instr,
		input				instr_c		
		);
	
	reg[7:0]				instr_in_count = 0;
	reg[7:0]				instr_out_count = 0;
	reg[31:0]				last_pc;
	
	// Track stream of fetched instructions 
	// against what is delivered
	reg[1:0]				num_fetch;
	reg[31:0]				idata0;
	reg[31:0]				idata1;
	reg						state;
	
	always @(posedge clock) begin
		if (reset) begin
			instr_in_count <= 0;
			instr_out_count <= 0;
			num_fetch <= 0;
			state <= 0;
		end else begin
			if (ivalid && iready) begin
				if (num_fetch == 0) begin
					idata0 <= idata;
				end else if (num_fetch == 1) begin
					idata1 <= idata;
				end else begin
					`assert(0);
				end
				num_fetch <= num_fetch + 1;
			end
			
			case (state)
				0: begin // Wait for an instruction to be fetched
					if (fetch_valid) begin
						`assert(num_fetch == 1 || num_fetch == 2);
						`cover({next_pc[1], instr_c} == 2'b00);
						`cover({next_pc[1], instr_c} == 2'b01);
						`cover({next_pc[1], instr_c} == 2'b10);
//						`cover({next_pc[1], instr_c} == 2'b11);
						case ({next_pc[1], instr_c})
							2'b00: `assert(num_fetch == 1);
							2'b01: `assert(num_fetch == 1);
							2'b10: `assert(num_fetch == 2);
							2'b11: `assert(num_fetch == 1);
						endcase
						num_fetch <= 0;
						state <= 1;
					end
				end
				1: begin //
					if (decode_complete) begin
						instr_out_count <= instr_out_count + 1;
//						`cover(instr_out_count == 2);
						state <= 0;
					end else begin
					end
				end
			endcase
		end
	end
	
endmodule
		