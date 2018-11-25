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

	fwrisc_fpga_top u_dut (
		.clock  (clock ), 
		.clk_o	(clock_o),
		.led0   (led0  ), 
		.led1   (led1  ),
		.tx	(tx    ),
		.d0_p   (d0_p ),
		.d0_n   (d0_n ));

endmodule


