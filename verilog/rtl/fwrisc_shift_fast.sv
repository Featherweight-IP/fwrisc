/****************************************************************************
 * fwrisc_shift_fast.sv
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
 * Multi-cycle multiply/divide/shift unit. 
 */
module fwrisc_shift_fast(
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

	always @(posedge clock) begin
		if (reset) begin
			out <= 32'b0;
			out_valid <= 0;
		end else begin
			if (in_valid) begin
				out_valid <= 1;
				case (op)
					OP_SLL: begin // sll
						if (|in_b[4:0]) begin
							out <= (out << in_b[4:0]);
						end
					end
					OP_SRL: begin // srl
						if (|in_b[4:0]) begin
							out <= (out >> in_b[4:0]);
						end
					end
					OP_SRA: begin // sra
						if (|in_b[4:0]) begin
							out <= (out >>> in_b[4:0]);
						end
					end
				endcase
			end else begin
				out_valid <= 0;
			end
		end
	end

endmodule


