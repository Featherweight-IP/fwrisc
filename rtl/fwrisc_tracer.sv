/****************************************************************************
 * fwrisc_tracer.sv
 ****************************************************************************/

/**
 * Module: fwrisc_tracer
 * 
 * Dummy module that provides an attachment site for the
 * monitor BFM
 */
module fwrisc_tracer (
		input			clock,
		input			reset,
		input [31:0]	addr,
		input [31:0]	instr,
		input			ivalid,
		input [31:0]	raddr,
		input [31:0]	rdata,
		input			rwrite
		);
	// Empty
	
	always @(posedge clock) begin
		if (rwrite) begin
			$display("Write: r%0d <= 'h%08h", raddr, rdata);
		end
	end
	
	always @(posedge clock) begin
		if (ivalid) begin
			$display("Exec: 'h%08h @ 'h%08h", instr, addr);
		end
	end
endmodule


