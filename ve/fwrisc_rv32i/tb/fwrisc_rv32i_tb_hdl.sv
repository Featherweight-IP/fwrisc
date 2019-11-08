/****************************************************************************
 * fwrisc_tb.sv
 ****************************************************************************/

/**
 * Module: fwrisc_rv32i_tb_hdl
 * 
 * Unit-level testbench for the FWRISC core
 */
module fwrisc_rv32i_tb_hdl(input clock);
	
`ifdef HAVE_HDL_CLKGEN
	reg clk_r = 0;
	
	initial begin
		forever begin
			#10ns;
			clk_r <= ~clk_r;
		end
	end
	
	assign clock = clk_r;
`endif
	
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
	wire [3:0]			dwstb;
	wire				dwrite, dvalid, dready;
	
	fwrisc #(
			.ENABLE_COMPRESSED(0),
			.ENABLE_MUL_DIV(0),
			.ENABLE_DEP(0),
			.ENABLE_COUNTERS(1)
		) u_dut (
		.clock   (clock  ), 
		.reset   (reset  ), 
		.iaddr   (iaddr  ), 
		.idata   (idata  ), 
		.ivalid  (ivalid ), 
		.iready  (iready ), 
		.daddr   (daddr  ), 
		.dwdata  (dwdata ), 
		.drdata  (drdata ), 
		.dwstb   (dwstb  ), 
		.dwrite  (dwrite ), 
		.dvalid  (dvalid ), 
		.dready  (dready ));
	
	assign dready = 1;
	assign iready = 1;

	generic_sram_byte_en_dualport #(
		.DATA_WIDTH        (32       ), 
		.ADDRESS_WIDTH     (14       ), // 64k (4x16k)
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
		.i_byte_enable_b   (dwstb  					),
		.o_read_data_b     (drdata					));
	

	// Connect the tracer BFM to 
	bind fwrisc_tracer fwrisc_tracer_bfm u_tracer(
			.clock(clock),
			.reset(reset),
			.pc(pc),
			.instr(instr),
			.ivalid(ivalid),
			.ra_raddr(ra_raddr),
			.ra_rdata(ra_rdata),
			.rb_raddr(rb_raddr),
			.rb_rdata(rb_rdata),
			.rd_waddr(rd_waddr),
			.rd_wdata(rd_wdata),
			.rd_write(rd_write),
			.maddr(maddr),
			.mdata(mdata),
			.mstrb(mstrb),
			.mwrite(mwrite),
			.mvalid(mvalid)
		);

endmodule


