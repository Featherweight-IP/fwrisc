/****************************************************************************
 * fwrisc_regfile.sv
 ****************************************************************************/

/**
 * Module: fwrisc_regfile
 * 
 * TODO: Add module documentation
 */
module fwrisc_regfile(
		input			clock,
		input			reset,
		input[5:0]		ra_raddr,
		output[31:0]	ra_rdata,
		input[5:0]		rb_raddr,
		output[31:0]	rb_rdata,
		input[5:0]		rd_waddr,
		input[31:0]		rd_wdata,
		input			rd_wen
		);

	reg[31:0]			regs[63:0];

	assign ra_rdata = regs[ra_raddr];
	assign rb_rdata = regs[rb_raddr];
	
	always @(posedge clock) begin
		if (rd_wen) begin
			regs[rd_waddr] = rd_wdata;
		end
	end

endmodule


