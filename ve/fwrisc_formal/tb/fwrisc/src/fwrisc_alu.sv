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
 
`include "fwrisc_defines.vh"

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
		input[2:0]				op,
		output reg[31:0]		out,
		output 					carry,
		output					eqz);
	
	wire[31:0] or_xor = (op == `OP_XOR)?(op_a ^ op_b):(op_a | op_b);
	wire[31:0] add_sub = (op == `OP_ADD)?(op_a + op_b):(op_a - op_b);
	
//	assign carry = (op_b > op_a);
	assign carry = ($signed(op_b) > $signed(op_a));
	assign eqz = (op_b == op_a);
//	assign carry = 0;
	
//	genvar i;
//	for (i=0; i<31; i++) 
//		assign or_xor[i] = (op == `OP_XOR)?(op_a[i] ^ op_b[i]):(op_a[i] | op_b[i]);

//	assign eqz = 0;
	
	always @* begin
		case (op) 
			/*
			`OP_ADD: out = op_a + op_b;
			`OP_SUB: out = op_a - op_b;
			 */
			`OP_ADD,`OP_SUB: out = add_sub;
			`OP_SLL: out = op_a << 1;
			`OP_SRL: out = op_a >> 1;
			`OP_SRA: out = $signed(op_a) >>> 1;
			`OP_AND: out = op_a & op_b;
//			`OP_XOR: out = op_a ^ op_b;
//			default: /*`OP_OR:*/ out = op_a | op_b;
			default: out = or_xor;
		endcase
	end

endmodule


