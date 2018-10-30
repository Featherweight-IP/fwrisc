/****************************************************************************
 * fwrisc_comparator.sv
 ****************************************************************************/
 
typedef enum {
	COMPARE_EQ,
	COMPARE_LT,
	COMPARE_LTU
} compare_op_e;

/**
 * Module: fwrisc_comparator
 * 
 * TODO: Add module documentation
 */
module fwrisc_comparator(
		input			clock,
		input			reset,
		input[31:0]		in_a,
		input[31:0]		in_b,
		input[1:0]		op,
		output			out
		);
	
	wire signed [31:0] in_a_s = in_a;
	wire signed [31:0] in_b_s = in_b;
	
	always @* begin
		case (op) 
			COMPARE_EQ: out = (in_a == in_b);
			COMPARE_LT: out = (in_a_s < in_b_s);
			COMPARE_LTU: out = (in_a < in_b);
		endcase
	end

endmodule


