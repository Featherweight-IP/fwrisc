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
 * Multi-cycle multiply/divide/shift unit. 
 */
module fwrisc_mul_div_shift #(
		parameter ENABLE_MUL_DIV=1,
		parameter ENABLE_MUL=ENABLE_MUL_DIV,
		parameter ENABLE_DIV=ENABLE_MUL_DIV,
		parameter SINGLE_CYCLE_SHIFT=0
		)(
		input				clock,
		input				reset,
		input[31:0]			in_a,
		input[31:0]			in_b,
		input[3:0]			op,
		input				in_valid,
		output reg[31:0]	out,
		output reg			out_valid
		);
	
	`include "fwrisc_mul_div_shift_op.svh"

	reg[3:0]				op_r;
	reg[4:0]				shift_amt_r;
	reg						working;
	reg[63:0]				mul_res;
	reg[31:0]				mul_tmp1;
	reg[31:0]				mul_tmp2;
	reg[62:0]				div_divisor;
	reg[31:0]				div_dividend;
	reg[31:0]				div_quotient;
	reg[31:0]				div_msk;
	reg						div_sign;
	
	
	wire mul_tmp2_zero = (|mul_tmp2 == 0);
	
	always @(posedge clock) begin
		if (reset) begin
			out <= 32'b0;
			out_valid <= 0;
			working <= 0;
			op_r <= 0;
		end else begin
			if (in_valid) begin
				op_r <= op;
				working <= 1;
				case (op)
					OP_SLL, OP_SRL, OP_SRA: begin // sll
						if (SINGLE_CYCLE_SHIFT) begin
							shift_amt_r <= 0;
							case (op_r)
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
							shift_amt_r <= in_b[4:0];
							out <= in_a;
						end
					end
					OP_MUL, OP_MULH: begin // mul/mulh
						if (ENABLE_MUL) begin
							mul_res <= 64'b0;
							mul_tmp1 <= in_a;
							mul_tmp2 <= in_b;
							shift_amt_r <= 5'd31;
						end
					end
					OP_MULS, OP_MULSH: begin // muls/mulsh
						if (ENABLE_MUL) begin
							mul_res <= 64'b0;
							mul_tmp1 <= $signed(in_a);
							mul_tmp2 <= $signed(in_b);
							shift_amt_r <= 5'd31;
						end
					end
					OP_DIV, OP_REM: begin 
						if (ENABLE_DIV) begin
							if (in_a[31]) begin
								div_dividend <= -in_a;
							end else begin
								div_dividend <= in_a;
							end
							if (in_b[31]) begin
								div_divisor <= (-in_b) << 31;
							end else begin
								div_divisor <= in_b << 31;
							end
							shift_amt_r <= 5'd31;
							div_msk <= 'h8000_0000;
						end
					end
				endcase
				if (op == OP_DIV) begin
					div_sign <= (in_a[31] != in_b[31]);
				end else begin
					// OP_REM and others
					div_sign <= in_a[31];
				end
			end
			
			if (working) begin
				case (op_r)
					OP_SLL: begin // sll
						if (|shift_amt_r) begin
							out <= (out << 1);
						end
					end
					OP_SRL: begin // srl
						if (|shift_amt_r) begin
							out <= (out >> 1);
						end
					end
					OP_SRA: begin // sra
						if (|shift_amt_r) begin
							out <= ($signed(out) >>> 1);
						end
					end
					
					OP_MUL, OP_MULS, OP_MULH, OP_MULSH: begin // mul
						if (ENABLE_MUL) begin
							if (mul_tmp1[0]) begin
								mul_res <= (mul_res + mul_tmp2);
							end
							mul_tmp2 <= (mul_tmp2 << 1);
							mul_tmp1 <= (mul_tmp1 >> 1);
							if (op_r == OP_MUL || op_r == OP_MULS) begin // mul/muls
								out <= mul_res[31:0];
							end else begin // mulh/mulsh
								out <= mul_res[63:32];
							end
						end
					end
					OP_DIV, OP_REM: begin
						if (ENABLE_DIV) begin
							if (div_divisor <= div_dividend) begin
								div_dividend <= div_dividend - div_divisor;
								div_quotient <= div_quotient | div_msk;
							end
							div_divisor <= div_divisor >> 1;
							div_msk <= div_msk >> 1;
							if (op == OP_DIV) begin
								out <= (div_sign)?-div_quotient:div_quotient;
							end else begin
								out <= (div_sign)?-div_dividend:div_dividend;
							end
						end
					end
				endcase
		
				if (|shift_amt_r == 0) begin
					// We're done
					working <= 1'b0;
					out_valid <= 1'b1;
				end else begin
					shift_amt_r <= shift_amt_r - 1;
				end
			end else begin
				out_valid <= 0;
			end
		end
	end

endmodule


