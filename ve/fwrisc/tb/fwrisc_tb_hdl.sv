/****************************************************************************
 * fwrisc_tb.sv
 ****************************************************************************/

/**
 * Module: fwrisc_tb_hdl
 * 
 * TODO: Add module documentation
 */
module fwrisc_tb_hdl(input clock);
	
	reg reset = 1;
	reg [7:0] reset_cnt = 0;
	
	always @(posedge clock) begin
		if (reset_cnt == 10) begin
			reset <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	wire [31:0]			iaddr, idata;
	wire				ivalid, iready;
	wire [31:0]			daddr, dwdata, drdata;
	wire [3:0]			dstrb;
	wire				dwrite, dvalid, dready;
	
	fwrisc u_dut (
		.clock   (clock  ), 
		.reset   (reset  ), 
		.iaddr   (iaddr  ), 
		.idata   (idata  ), 
		.ivalid  (ivalid ), 
		.iready  (iready ), 
		.daddr   (daddr  ), 
		.dwdata  (dwdata ), 
		.drdata  (drdata ), 
		.dstrb   (dstrb  ), 
		.dwrite  (dwrite ), 
		.dvalid  (dvalid ), 
		.dready  (dready ));
	
	assign dready = 1;
	assign iready = 1;

	generic_sram_byte_en_dualport #(
		.DATA_WIDTH        (32       ), 
		.ADDRESS_WIDTH     (14       ),
		.INIT_FILE         ("ram.hex")
		) u_sram (
		.i_clk             (clock            		), 
		.i_write_data_a    (32'b0   				), 
		.i_write_enable_a  (1'b0 					), 
		.i_address_a       (iaddr[31:2]				), 
		.i_byte_enable_a   (4'hf  					), 
		.o_read_data_a     (idata    				), 
		.i_write_data_b    (dwdata   				), 
		.i_write_enable_b  ((dvalid && dwrite) 		), 
		.i_address_b       (daddr[31:2]				),
		.i_byte_enable_b   (dstrb  					),
		.o_read_data_b     (drdata					));
	

endmodule


