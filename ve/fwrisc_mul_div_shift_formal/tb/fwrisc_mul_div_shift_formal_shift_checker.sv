
module fwrisc_mul_div_shift_formal_checker(
		input			clock,
		input			reset,
		input[31:0]		in_a,
		input[31:0]		in_b,
		input[3:0]		op,
		input			in_valid,
		input[31:0]		out,
		input			out_valid);
	
	always @(posedge clock) begin
		if (!reset && out_valid) begin
			assert(op >= 4'b0000 && op <= 4'b0010);
			if (op == 4'b0000) begin
				assert(out == (in_a << in_b[4:0]));
			end else if (op == 4'b0001) begin // srl
				assert(out == (in_a >> in_b[4:0]));
			end else if (op == 4'b0010) begin // sra
				assert(out == (in_a >>> in_b[4:0]));
			end
			cover(out_valid);
		end

		assume (s_eventually (!reset && out_valid));
	end
	
	
endmodule
		