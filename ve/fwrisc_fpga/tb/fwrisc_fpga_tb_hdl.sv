/****************************************************************************
 * fwrisc_tb.sv
 ****************************************************************************/

/**
 * Module: fwrisc_fpga_tb_hdl
 * 
 * TODO: Add module documentation
 */
module fwrisc_fpga_tb_hdl(input clock);
	wire				led0, led1;

	fwrisc_fpga_top u_dut (
		.clock  (clock ), 
		.led0   (led0  ), 
		.led1   (led1  ));

endmodule


