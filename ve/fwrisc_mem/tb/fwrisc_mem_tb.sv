/****************************************************************************
 * fwrisc_mem_tb.sv
 ****************************************************************************/


/**
 * Module: fwrisc_mem_tb
 * 
 * TODO: Add module documentation
 */
module fwrisc_mem_tb(input clock);

	reg[3:0]	reset_cnt = 0;
	reg 		reset = 1;
	
	`ifndef FORMAL
		reg clk = 0;
		always #10 clk = ~clk;
		assign clock = clk;
	
		initial begin
			$dumpfile("simx.vcd");
			$dumpvars(0, fwrisc_mem_tb);
			
			#1000;
			$finish;
		end
	`endif	
	
	always @(posedge clock) begin
		if (reset_cnt == 1) begin
			reset <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	wire			req_valid;
	wire[31:0]		req_addr;
	wire[3:0]		req_op;
	wire[31:0]		req_data;
	wire			ack_valid;
	wire[31:0]		ack_data;

	wire			dvalid;
	wire[31:0]		daddr;
	wire[31:0]		dwdata;
	wire[3:0]		dwstb;
	wire			dwrite;
	wire[31:0]		drdata;
	wire			dready;

	// TODO: instance checker, test, and DUT
	
	fwrisc_mem_test u_test(
		.clock      (clock     ), 
		.reset      (reset     ), 
		.req_valid  (req_valid ), 
		.req_addr   (req_addr  ), 
		.req_op     (req_op    ), 
		.req_data   (req_data  ), 
		.ack_valid  (ack_valid ),
		
		.dvalid		(dvalid    ),
		.drdata		(drdata    ),
		.dready		(dready    )
			);

	// TODO: instance DUT
	fwrisc_mem u_dut (
		.clock      (clock     ), 
		.reset      (reset     ), 
		.req_valid  (req_valid ), 
		.req_addr   (req_addr  ), 
		.req_op     (req_op    ), 
		.req_data   (req_data  ), 
		.ack_valid  (ack_valid ), 
		.ack_data   (ack_data  ), 
		.dvalid     (dvalid    ), 
		.daddr      (daddr     ), 
		.dwdata     (dwdata    ), 
		.dwstb      (dwstb     ), 
		.dwrite     (dwrite    ), 
		.drdata     (drdata    ), 
		.dready     (dready    ));
	
	fwrisc_mem_checker u_checker(
			.clock      (clock     ), 
			.reset      (reset     ), 
			.req_valid  (req_valid ), 
			.req_addr   (req_addr  ), 
			.req_op     (req_op    ), 
			.req_data   (req_data  ), 
			.ack_valid  (ack_valid ), 
			.ack_data   (ack_data  ), 
			.dvalid     (dvalid    ), 
			.daddr      (daddr     ), 
			.dwdata     (dwdata    ), 
			.dwstb      (dwstb     ), 
			.dwrite     (dwrite    ), 
			.drdata     (drdata    ), 
			.dready     (dready    )			
		);
			
endmodule

