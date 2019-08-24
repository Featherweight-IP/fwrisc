/****************************************************************************
 * fwrisc_mul_div_shift.sv
 ****************************************************************************/

/**
 * Module: fwrisc_mul_div_shift
 * 
 * TODO: Add module documentation
 */
module fwrisc_mul_div_shift(
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
	reg[31:0]				tmp_r;
	reg[4:0]				shift_amt_r;
	reg						working;
	
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
					4'b0000, 4'b0001, 4'b0010: begin // lsl
						shift_amt_r <= in_b[4:0];
						out <= in_a;
					end
				endcase
			end
			
			if (working) begin
				case (op_r)
					4'b0000: begin // lsl
						if (|shift_amt_r) begin
							out <= (out << 1);
						end
					end
					4'b0000: begin // lsr
						if (|shift_amt_r) begin
							out <= (out >> 1);
						end
					end
					4'b0000: begin // rsr
						if (|shift_amt_r) begin
							out <= (out >>> 1);
						end
					end
				endcase
		
				case (op_r)
					4'b0000, 4'b0001, 4'b0010: begin // lsl, lsr, rsr
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


