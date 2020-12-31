/****************************************************************************
 * fwrisc_tb.sv
 ****************************************************************************/
`ifdef IVERILOG
`timescale 1ns/1ns
`endif

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

`ifdef IVERILOG
	// Icarus requires help with timeout 
	// and wave capture
        reg[31:0]               timeout;
        initial begin
                if ($test$plusargs("dumpvars")) begin
                        $dumpfile("simx.vcd");
                        $dumpvars(0, fwrisc_rv32i_tb_hdl);
                end
                if (!$value$plusargs("timeout=%d", timeout)) begin
                        timeout=1000;
                end
                $display("--> Wait for timeout");
                # timeout;
                $display("<-- Wait for timeout");
                $finish();
        end
`endif

	
	reg reset /*verilator public*/ = 1;
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
	
	fwrisc_rv32i u_dut(
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

	/*
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
	*/
	

	// Connect the tracer BFM to 
	wire [31:0]		tracer_pc = u_dut.u_core.u_tracer.pc;
	wire [31:0]		tracer_instr = u_dut.u_core.u_tracer.instr;
	wire			tracer_ivalid = u_dut.u_core.u_tracer.ivalid;
	// ra, rb
	wire [5:0]		tracer_ra_raddr = u_dut.u_core.u_tracer.ra_raddr;
	wire [31:0]		tracer_ra_rdata = u_dut.u_core.u_tracer.ra_rdata;
	wire [5:0]		tracer_rb_raddr = u_dut.u_core.u_tracer.rb_raddr;
	wire [31:0]		tracer_rb_rdata = u_dut.u_core.u_tracer.rb_rdata;
	// rd
	wire [5:0]		tracer_rd_waddr = u_dut.u_core.u_tracer.rd_waddr;
	wire [31:0]		tracer_rd_wdata = u_dut.u_core.u_tracer.rd_wdata;
	wire			tracer_rd_write = u_dut.u_core.u_tracer.rd_write;
	
	wire [31:0]		tracer_maddr = u_dut.u_core.u_tracer.maddr;
	wire [31:0]		tracer_mdata = u_dut.u_core.u_tracer.mdata;
	wire [3:0]		tracer_mstrb = u_dut.u_core.u_tracer.mstrb;
	wire			tracer_mwrite = u_dut.u_core.u_tracer.mwrite;
	wire 			tracer_mvalid = u_dut.u_core.u_tracer.mvalid;

/*
	fwrisc_tracer_bfm u_tracer(
			.clock(clock),
			.reset(reset),
			.pc(tracer_pc),
			.instr(tracer_instr),
			.ivalid(tracer_ivalid),
			.ra_raddr(tracer_ra_raddr),
			.ra_rdata(tracer_ra_rdata),
			.rb_raddr(tracer_rb_raddr),
			.rb_rdata(tracer_rb_rdata),
			.rd_waddr(tracer_rd_waddr),
			.rd_wdata(tracer_rd_wdata),
			.rd_write(tracer_rd_write),
			.maddr(tracer_maddr),
			.mdata(tracer_mdata),
			.mstrb(tracer_mstrb),
			.mwrite(tracer_mwrite),
			.mvalid(tracer_mvalid)
		);
 */
/*
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
 */

endmodule


