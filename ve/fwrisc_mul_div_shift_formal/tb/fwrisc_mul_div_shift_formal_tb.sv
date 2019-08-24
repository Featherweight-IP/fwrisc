/****************************************************************************
 * fwrisc_mul_div_shift_formal_tb.sv
 ****************************************************************************/
 
/**
 * Module: fwrisc_mul_div_shift_formal_tb
 * 
 * TODO: Add module documentation
 */
module fwrisc_mul_div_shift_formal_tb(input clock);

	reg[3:0]	reset_cnt = 0;
	reg 		reset = 1;
	
	always @(posedge clock) begin
		if (reset_cnt == 1) begin
			reset <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	// Include file to force the instruction
	wire[31:0]			in_a;
	wire[31:0]			in_b;
	wire[3:0]			op;
	wire[31:0]			out;
	wire				out_valid;
	reg					state;
	reg					in_valid;
	reg					in_valid_d;
	
	always @(posedge clock) begin
		if (reset) begin
			state <= 0;
			in_valid <= 0;
			in_valid_d <= 0;
		end else begin
			if (state == 0) begin
				in_valid <= 1;
				state <= 1;
			end else if (state == 1) begin
				in_valid <= 0;
				if (out_valid) begin
					state <= 0;
				end
			end
		end
	end
	
	fwrisc_mul_div_shift_formal_op u_op(
		.in_a       (in_a      ), 
		.in_b       (in_b      ), 
		.op         (op        )
		);
	
	fwrisc_mul_div_shift u_dut (
		.clock      (clock     ), 
		.reset      (reset     ), 
		.in_a       (in_a      ), 
		.in_b       (in_b      ), 
		.op         (op        ), 
		.in_valid   (in_valid  ), 
		.out        (out       ), 
		.out_valid  (out_valid )
		);
	
	fwrisc_mul_div_shift_formal_checker u_checker(
		.clock      (clock     ), 
		.reset      (reset     ), 
		.in_a       (in_a      ), 
		.in_b       (in_b      ), 
		.op         (op        ), 
		.in_valid   (in_valid  ), 
		.out        (out       ), 
		.out_valid  (out_valid )
		);
			
endmodule


