/****************************************************************************
 * fwrisc_formal_tb.sv
 ****************************************************************************/
 
`include "fwrisc_formal_opcode_defines.svh"

/**
 * Module: fwrisc_formal_tb
 * 
 * TODO: Add module documentation
 */
module fwrisc_formal_tb(input clock);

	reg[3:0]	reset_cnt = 0;
	reg 		reset = 1;
	
	always @(posedge clock) begin
		if (reset_cnt == 1) begin
			reset <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	wire[31:0]			iaddr, idata;

	// Include file to force the instruction
`include "fwrisc_formal_instruction.svh"
	
	wire				ivalid;
	wire				iready = ivalid;
	wire[31:0]			daddr;
	wire[31:0]          fwrisc_formal_drdata = $anyconst; // 'h04030201;
	wire[31:0]          dwdata;
	wire[3:0]			dstrb;
	wire				dvalid;
	wire				dwrite;
	wire				dready = dvalid;
	

	fwrisc u_dut (
		.clock   (clock  ), 
		.reset   (reset  ), 
		.iaddr   (iaddr  ), 
		.idata   (idata  ), 
		.ivalid  (ivalid ), 
		.iready  (iready ), 
		.daddr   (daddr  ), 
		.dwdata  (dwdata ), 
		.drdata  (fwrisc_formal_drdata ), 
		.dstrb   (dstrb  ), 
		.dwrite  (dwrite ), 
		.dvalid  (dvalid ), 
		.dready  (dready ),
		);
	assign u_dut.u_tracer.fwrisc_formal_drdata = fwrisc_formal_drdata;

endmodule


