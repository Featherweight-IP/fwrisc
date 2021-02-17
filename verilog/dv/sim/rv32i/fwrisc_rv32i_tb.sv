/****************************************************************************
 * fwrisc_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ns
`endif

/**
 * Module: fwrisc_rv32i_tb
 * 
 * Unit-level testbench for the FWRISC core
 */
module fwrisc_rv32i_tb(input clock);
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clk_r = 0;
	
	initial begin
		forever begin
`ifdef NEED_TIMESCALE
			#10;
`else
			#10ns;
`endif
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
                        $dumpvars(0, fwrisc_rv32i_tb);
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
	wire				irq;
	
	// RVFI interface signals
	wire[0:0] 	rvfi_valid;
	wire[63:0] 	rvfi_order;
	wire[31:0] 	rvfi_insn;
	wire[0:0]	rvfi_trap;
	wire[0:0] 	rvfi_halt;
	wire[0:0]	rvfi_intr;
	wire[1:0]	rvfi_mode;
	wire[1:0]	rvfi_ixl;
	wire[4:0]	rvfi_rs1_addr;
	wire[4:0]	rvfi_rs2_addr;
	wire[31:0]	rvfi_rs1_rdata;
	wire[31:0] 	rvfi_rs2_rdata;
	wire[4:0] 	rvfi_rd_addr;
	wire[31:0] 	rvfi_rd_wdata;
	wire[31:0]	rvfi_pc_rdata;
	wire[31:0]	rvfi_pc_wdata;
	wire[31:0]	rvfi_mem_addr;
	wire[3:0] 	rvfi_mem_rmask;
	wire[3:0]	rvfi_mem_wmask;
	wire[31:0]	rvfi_mem_rdata;
	wire[31:0]	rvfi_mem_wdata;
	
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
		.dready  (dready ),
		.irq     (irq    )
		/*
		,
		.rvfi_valid			(rvfi_valid        	),
		.rvfi_order			(rvfi_order			),
		.rvfi_insn			(rvfi_insn			),
		.rvfi_trap			(rvfi_trap			),
		.rvfi_halt			(rvfi_halt			),
		.rvfi_intr			(rvfi_intr			),
		.rvfi_mode			(rvfi_mode			),
		.rvfi_ixl			(rvfi_ixl			),
		.rvfi_rs1_addr		(rvfi_rs1_addr		),
		.rvfi_rs2_addr		(rvfi_rs2_addr		),
		.rvfi_rs1_rdata		(rvfi_rs1_rdata		),
		.rvfi_rs2_rdata		(rvfi_rs2_rdata		),
		.rvfi_rd_addr		(rvfi_rd_addr		),
		.rvfi_rd_wdata		(rvfi_rd_wdata		),
		.rvfi_pc_rdata		(rvfi_pc_rdata		),
		.rvfi_pc_wdata		(rvfi_pc_wdata		),
		.rvfi_mem_addr		(rvfi_mem_addr		),
		.rvfi_mem_rmask		(rvfi_mem_rmask		),
		.rvfi_mem_wmask		(rvfi_mem_wmask		),
		.rvfi_mem_rdata		(rvfi_mem_rdata		),
		.rvfi_mem_wdata		(rvfi_mem_wdata		)		
		 */
		);
	
	gpio_bfm #(
			.WIDTH(1)
		) u_irq_bfm (
			.clock			(clock			),
			.reset			(reset			),
			.gpio_in		(1'b0			),
			.gpio_out		(irq			)
		);
	
	assign dready = 1;
	assign iready = 1;

	generic_sram_byte_en_dualport_target_bfm #(
		.DAT_WIDTH        (32       ), 
		.ADR_WIDTH        (22       ) // 16M
		) u_sram (
		.clock				(clock            		), 
		.a_dat_w			(32'b0   				), 
		.a_we				(1'b0 					), 
		.a_adr				(iaddr[31:2]			), 
		.a_sel				(4'hf  					), 
		.a_dat_r			(idata    				), 
		.b_dat_w			(dwdata   				), 
		.b_we				((dvalid && dwrite) 	), 
		.b_adr				(daddr[31:2]			),
		.b_sel				(dwstb  				),
		.b_dat_r			(drdata					));

`ifdef UNDEFINED
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

	riscv_debug_bfm u_dbg_bfm (
			.clock				(clock				),
			.reset				(reset				),
			.valid				(tracer_ivalid        	),
			.instr				(tracer_instr			),
			/*
			.trap				(1'b0			),
			.halt				(1'b0			),
			 */
			.intr				(1'b0			),
//			.mode				(rvfi_mode			),
//			.ixl				(rvfi_ixl			),
			.rd_addr			(tracer_rd_waddr		),
			.rd_wdata			(tracer_rd_wdata		),
			.pc					(tracer_pc		),
			.mem_addr			(tracer_maddr		),
			.mem_wmask			((tracer_mwrite)?tracer_mstrb:{4{1'b0}}		),
			.mem_data			(tracer_mdata		)			
		);
`endif /* UNDEFINED */
//	fwrisc_tracer_bfm u_tracer(
//			.clock(clock),
//			.reset(reset),
//			.pc(tracer_pc),
//			.instr(tracer_instr),
//			.ivalid(tracer_ivalid),
//			.ra_raddr(tracer_ra_raddr),
//			.ra_rdata(tracer_ra_rdata),
//			.rb_raddr(tracer_rb_raddr),
//			.rb_rdata(tracer_rb_rdata),
//			.rd_waddr(tracer_rd_waddr),
//			.rd_wdata(tracer_rd_wdata),
//			.rd_write(tracer_rd_write),
//			.maddr(tracer_maddr),
//			.mdata(tracer_mdata),
//			.mstrb(tracer_mstrb),
//			.mwrite(tracer_mwrite),
//			.mvalid(tracer_mvalid)
//		);
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


