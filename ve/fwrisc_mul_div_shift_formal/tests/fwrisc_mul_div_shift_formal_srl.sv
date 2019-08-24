
module fwrisc_mul_div_shift_formal_op(
		output[31:0]		in_a,
		output[31:0]		in_b,
		output[3:0]			op
		);
	
assign op = 4'b0001; // srl
assign in_a = $anyconst;
assign in_b = $anyconst;

endmodule