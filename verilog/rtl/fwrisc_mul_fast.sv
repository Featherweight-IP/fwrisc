/****************************************************************************
 * fwrisc_mul_div_shift.sv
 *
 * Copyright 2019 Matthew Ballance
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
 ****************************************************************************/

/**
 * Module: fwrisc_mul_div_shift
 * 
 * Single-cycle multiply/divide/shift unit. 
 */
module fwrisc_mul_fast(
		input				clock,
		input				reset,
		input[31:0]			in_a,
		input[31:0]			in_b,
		input[3:0]			op,
		input				in_valid,
		output reg[31:0]		out,
		output reg			out_valid
		);
	
	`include "fwrisc_mul_div_shift_op.svh"

`define ONE
`ifdef ONE
	reg[32:0]				op_a;
	reg[32:0]				op_b;
`else
	wire[16:0]				op_a = in_a;
	wire[16:0]				op_b = in_b;
`endif

	always @(posedge clock) begin
		if (reset) begin
			out <= 32'b0;
			out_valid <= 0;
		end else begin
			if (in_valid) begin
`ifdef ONE
				op_a <= in_a;
				op_b <= in_b;
`endif
				case (op)
					OP_MUL, OP_MULS: begin
						out <= (op_a * op_b);
					end
					OP_MULH, OP_MULSH: begin // mul
						out <= ((op_a * op_b) >> 32);
					end
				endcase
				out_valid <= 1;
			end else begin
				out_valid <= 0;
			end
		end
	end

endmodule


