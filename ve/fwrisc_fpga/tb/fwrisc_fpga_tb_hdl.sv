/****************************************************************************
 * fwrisc_tb.sv
 ****************************************************************************/

/**
 * Module: fwrisc_fpga_tb_hdl
 * 
 * TODO: Add module documentation
 */
module fwrisc_fpga_tb_hdl(input clock);
	wire				led0, led1, clock_o;
	wire				tx, d0_p, d0_n;
	reg					led0_r, led1_r;

	fwrisc_fpga_top u_dut (
		.clock  (clock ), 
		.clk_o	(clock_o),
		.led0   (led0  ), 
		.led1   (led1  ),
		.tx	(tx    ),
		.d0_p   (d0_p ),
		.d0_n   (d0_n ));
	
	import "DPI-C" context function void fwrisc_fpga_tb_led(
			byte unsigned		led0,
			byte unsigned		led1);
	
	always @(posedge clock) begin
		if (led0 != led0_r || led1 != led1_r) begin
			$display("--> led(%0d %0d)", led0, led1);
			fwrisc_fpga_tb_led(led0, led1);
			led0_r <= led0;
			led1_r <= led1;
			$display("<-- led(%0d %0d)", led0, led1);
		end
	end
	
	bind fwrisc_tracer fwrisc_tracer_bfm u_tracer(
			.clock(clock),
			.reset(reset),
			.addr(addr),
			.instr(instr),
			.ivalid(ivalid),
			.raddr(raddr),
			.rdata(rdata),
			.rwrite(rwrite),
			.maddr(maddr),
			.mdata(mdata),
			.mstrb(mstrb),
			.mwrite(mwrite),
			.mvalid(mvalid)
		);

endmodule


