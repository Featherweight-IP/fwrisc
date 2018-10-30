/****************************************************************************
 * fwrisc_alu.sv
 ****************************************************************************/
 
typedef enum {
	OP_ADD,
	OP_SUB,
	OP_AND,
	OP_OR,
	OP_XOR
} fwrisc_alu_op_e;

/**
 * Module: fwrisc_alu
 * 
 * TODO: Add module documentation
 */
module fwrisc_alu (
		input					clock,
		input					reset,
		input[31:0]				op_a,
		input[31:0]				op_b,
		wire[4:0]				op,
		output[31:0]			out);

	always @* begin
		case (op) 
			OP_ADD: out = op_a + op_b;
			OP_SUB: out = op_a - op_b;
			OP_AND: out = op_a & op_b;
			OP_OR:  out = op_a | op_b;
			OP_XOR: out = op_a ^ op_b;
		endcase
	end

endmodule


