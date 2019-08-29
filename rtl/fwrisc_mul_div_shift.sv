/****************************************************************************
 * fwrisc_mul_div_shift.sv
 ****************************************************************************/

/**
 * Module: fwrisc_mul_div_shift
 * 
 * Multi-cycle multiply/divide/shift unit. 
 */
module fwrisc_mul_div_shift #(
		parameter ENABLE_MUL=1
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

	reg[3:0]				op_r;
	reg[4:0]				shift_amt_r;
	reg						working;
	reg[63:0]				mul_res;
	reg[31:0]				mul_tmp1;
	reg[31:0]				mul_tmp2;
	
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
					4'b0000, 4'b0001, 4'b0010: begin // sll
						shift_amt_r <= in_b[4:0];
						out <= in_a;
					end
					4'b0011, 4'b0100: begin // mul/mulh
						if (ENABLE_MUL) begin
							mul_res <= 64'b0;
							mul_tmp1 <= in_a;
							mul_tmp2 <= in_b;
							shift_amt_r <= 5'd31;
						end
					end
					4'b0101, 4'b0110: begin // muls/mulsh
						if (ENABLE_MUL) begin
							mul_res <= 64'b0;
							mul_tmp1 <= $signed(in_a);
							mul_tmp2 <= $signed(in_b);
							shift_amt_r <= 5'd31;
						end
					end
				endcase
			end
			
			if (working) begin
				case (op_r)
					4'b0000: begin // sll
						if (|shift_amt_r) begin
							out <= (out << 1);
						end
					end
					4'b0001: begin // srl
						if (|shift_amt_r) begin
							out <= (out >> 1);
						end
					end
					4'b0010: begin // sra
						if (|shift_amt_r) begin
							out <= (out >>> 1);
						end
					end
					
					4'b0011, 4'b0100, 4'b0101, 4'b0110: begin // mul
						if (ENABLE_MUL) begin
							if (mul_tmp1[0]) begin
								mul_res <= (mul_res + mul_tmp2);
							end
							mul_tmp2 <= (mul_tmp2 << 1);
							mul_tmp1 <= (mul_tmp1 >> 1);
							if (op_r == 4'b0011 || op_r == 4'b0101) begin // mul/muls
								out <= mul_res[31:0];
							end else begin // mulh/mulsh
								out <= mul_res[63:32];
							end
						end
					end
				endcase
		
				case (op_r)
					4'b0000, 4'b0001, 4'b0010, 4'b0011: begin // lsl, lsr, rsr, mul
						if (|shift_amt_r == 0) begin
							// We're done
							working <= 1'b0;
							out_valid <= 1'b1;
						end else begin
							shift_amt_r <= shift_amt_r - 1;
						end
					end
				endcase
			end else begin
				out_valid <= 0;
			end
		end
	end

endmodule


