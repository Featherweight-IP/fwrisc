/****************************************************************************
 * fwrisc_tracer_bfm.sv
 ****************************************************************************/

/**
 * Module: fwrisc_tracer_bfm
 * 
 * TODO: Add interface documentation
 */
module fwrisc_tracer_bfm(
		input			clock,
		input			reset,
		input [31:0]	addr,
		input [31:0]	instr,
		input			ivalid,
		input [31:0]	raddr,
		input [31:0]	rdata,
		input			rwrite,
		input [31:0]	maddr,
		input [31:0]	mdata,
		input [3:0]		mstrb,
		input			mwrite,
		input 			mvalid		
		);
	
	int unsigned			m_id;
	
	import "DPI-C" context function int unsigned fwrisc_tracer_bfm_register(string path);
	
	initial begin
		$display("fwrisc_tracer_bfm: %m");
		m_id = fwrisc_tracer_bfm_register($sformatf("%m"));
	end

	import "DPI-C" function void fwrisc_tracer_bfm_regwrite(
			int unsigned	id,
			int unsigned	raddr,
			int unsigned	rdata);
	
	always @(posedge clock) begin
		if (rwrite) begin
			fwrisc_tracer_bfm_regwrite(m_id, raddr, rdata);
		end
	end

	import "DPI-C" function void fwrisc_tracer_bfm_exec(
			int unsigned	id,
			int unsigned	addr,
			int unsigned	instr);
			
	always @(posedge clock) begin
		if (ivalid) begin
			fwrisc_tracer_bfm_exec(m_id, addr, instr);
		end
	end
	
	always @(posedge clock) begin
		if (mvalid) begin
			$display("%0s: 'h%08h 'h%08h", (mwrite)?"WRITE":"READ", maddr, mdata);
		end
	end	

endmodule


