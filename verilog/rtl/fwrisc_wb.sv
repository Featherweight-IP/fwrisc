
/****************************************************************************
 * fwrisc_wb.sv
 ****************************************************************************/
`include "wishbone_macros.svh"
  
/**
 * Module: fwrisc_wb
 * 
 * Parameterizable Featherweight RISC-V core
 * with a Wishbone bus
 */
module fwrisc_wb #(
		parameter ENABLE_COMPRESSED=1,
		parameter ENABLE_MUL_DIV=1,
		parameter ENABLE_DEP=1,
		parameter ENABLE_COUNTERS=1
		) (
		input			clock,
		input			reset,
	
		`WB_INITIATOR_PORT(wbi_,32,32),
		`WB_INITIATOR_PORT(wbd_,32,32),
		input			irq
		);
	
	assign wbi_dat_w = {32{1'b0}};
	assign wbi_sel = {4{1'b0}};
	assign wbi_we  = 1'b0;

	wire[31:0]		iaddr;
	wire[31:0]		idata;
	wire			ivalid;
	wire			iready;
	
	wire			dvalid;
	wire[31:0]		daddr;
	wire[31:0]		dwdata;
	wire[3:0]		dwstb;
	wire			dwrite;
	wire[31:0]		drdata;
	wire			dready;

	fwrisc #(
			.ENABLE_COMPRESSED(ENABLE_COMPRESSED),
			.ENABLE_MUL_DIV(ENABLE_MUL_DIV),
			.ENABLE_DEP(ENABLE_DEP),
			.ENABLE_COUNTERS(ENABLE_COUNTERS)
			) u_core (
			.clock(clock),
			.reset(reset),
		
			.iaddr(iaddr),
			.idata(idata),
			.ivalid(ivalid),
			.iready(iready),
		
			.dvalid(dvalid),
			.daddr(daddr),
			.dwdata(dwdata),
			.dwstb(dwstb),
			.dwrite(dwrite),
			.drdata(drdata),
			.dready(dready),
			.irq(irq)
			);
	
	assign wbi_adr = iaddr;
	assign idata = wbi_dat_r;
	assign wbi_cyc = ivalid;
	assign wbi_stb = ivalid;
	assign iready = wbi_ack;
	
	assign wbd_adr 		= daddr;
	assign drdata 		= wbd_dat_r;
	assign wbd_dat_w 	= dwdata;
	assign wbd_cyc 		= dvalid;
	assign wbd_stb 		= dvalid;
	assign dready 		= wbd_ack;
	assign wbd_sel 		= dwstb;
	assign wbd_we 		= dwrite;

endmodule

