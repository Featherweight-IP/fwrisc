/****************************************************************************
 * fwrisc_alu.sv
 * 
 * Copyright 2018-2019 Matthew Ballance
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
		input[3:0]				op,
		output reg[31:0]		out);
	
	`include "fwrisc_alu_op.svh"
	
	always @* begin
		case (op) 
			OP_ADD:  out = op_a + op_b;
			OP_SUB:  out = op_a - op_b; // sub;
			OP_AND:  out = op_a & op_b;
			OP_OR:   out = op_a | op_b;
			OP_CLR:  out = op_b ^ (op_a & op_b); // Used for CSRC
			OP_EQ:   out = {31'b0, op_a == op_b};
			OP_NE:   out = {31'b0, op_a != op_b};
			OP_LT:   out = {31'b0, $signed(op_a) < $signed(op_b)}; // {31'b0, carry};
			OP_GE:   out = {31'b0, $signed(op_a) >= $signed(op_b)}; // {31'b0, carry};
			OP_LTU:  out = {31'b0, op_a < op_b};
			OP_GEU:  out = {31'b0, op_a >= op_b};
			OP_OPA:  out = op_a; // passthrough
			OP_OPB:  out = op_b; // passthrough
			default /*OP_XOR */: out = op_a ^ op_b;
		endcase
	end

endmodule


