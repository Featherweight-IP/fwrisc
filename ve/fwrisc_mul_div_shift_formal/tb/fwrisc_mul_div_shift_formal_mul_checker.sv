
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
			assert(op >= 4'b0011 && op <= 4'b0011);
			if (op == 4'b0011) begin
				assert(out == ((in_a * in_b) & 32'hFFFFFFFF));
			end else if (op == 4'b0100) begin // mulh
				assert(out == (((in_a * in_b) >> 32) & 32'hFFFFFFFF));
			end else if (op == 4'b0101) begin // muls
				assert(out == (($signed(in_a) * $signed(in_b)) & 32'hFFFFFFFF));
			end else if (op == 4'b0110) begin // mulsh
				assert(out == ((($signed(in_a) * $signed(in_b)) >> 32) & 32'hFFFFFFFF));
			end
			cover(out_valid);
		end

		assume (s_eventually (!reset && out_valid));
	end
	
	
endmodule
		