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

//	assign out = (

endmodule


