


module fwrisc_fetch_formal_checker(
		input				clock,
		input				reset,
		output[31:1]		next_pc,
		output	 			next_pc_seq,
		input[31:0]			iaddr,
		input[31:0]			idata,
		input				ivalid,
		input				iready,
		input				fetch_valid,
		input				decode_ready,
		input[31:0]			instr,
		input				instr_c		
		);
	
	reg[7:0]				instr_in_count = 0;
	reg[7:0]				instr_out_count = 0;
	reg[31:0]				last_pc;
	
	always @(posedge clock) begin
		if (reset) begin
			instr_in_count <= 0;
			instr_out_count <= 0;
		end else begin
			if (ivalid && iready) begin
				instr_in_count <= 1;
			end
		end
	end
	
endmodule
		