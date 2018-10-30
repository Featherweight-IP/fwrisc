/****************************************************************************
 * fwrisc_alu.sv
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
 * 
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


