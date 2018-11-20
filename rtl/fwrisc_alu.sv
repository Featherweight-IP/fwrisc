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

	wire[32:0] out_add = op_a + op_b;
	wire[32:0] out_sub = op_a - $signed(op_b);
	wire[31:0] out_and = op_a & op_b;
	wire[31:0] out_or  = op_a | op_b;
//	assign carry = (op == `OP_SUB)?out_sub[32]:out_add[32];
	assign carry = 0;
//	assign eqz = (out_sub == 0);
	assign eqz = 0;
	
	wire[31:0] logic_group;// = (op == `OP_AND)?(op_a & op_b):(op == `OP_XOR)?(op_a ^ op_b):(op_a | op_b);

	genvar i;
	for (i=0; i<32; i=i+1) begin
		assign logic_group[i] = (op == `OP_AND)?(op_a[i] & op_b[i]):(op == `OP_XOR)?(op_a[i]^op_b[i]):(op_a[i] | op_b[i]);
	end
	
	reg[31:0] shift_group;

	genvar j;
	for (j=0; j<32; j=j+1) begin
		if (j == 31) begin
			assign shift_group[31] = (op == `OP_SRA)?op_a[31]:(op == `OP_SRL)?1'b0:op_a[30];
		end else if (j == 0) begin
			assign shift_group[0] = (op == `OP_SLL)?0:op_a[1];
		end else begin
			assign shift_group[j] = (op == `OP_SLL)?op_a[j-1]:op_a[j+1];
		end
	end
//	always @* begin
//		if (op == `OP_SLL) begin
//			shift_group = {op_a[30:0], 1'b0};
//		end else if (op == `OP_SRL) begin
//			shift_group = {1'b0, op_a[31:1]};
//		end else begin
//			shift_group = {op_a[31], op_a[31:1]};
//		end
//	end
	
	wire is_logic_group = (op == `OP_AND || op == `OP_OR || op == `OP_XOR);
	wire is_shift_group = (op == `OP_SLL || op == `OP_SRL || op == `OP_SRA);
	
	always @* begin
		if (is_logic_group) begin
			out = logic_group;
		end else if (is_shift_group) begin
			out = shift_group;
		end else if (op == `OP_SUB) begin
			out = out_sub;
		end else begin
			out = out_add;
		end
		
//		case (op) 
//			`OP_AND, `OP_OR, `OP_XOR: out = logic_group;
//			`OP_SLL, `OP_SRL, `OP_SRA: out = shift_group;
////			`OP_SUB: out = out_sub[31:0];
//			default: /*ADD*/ out = out_add[31:0];
//		endcase
	end

endmodule


