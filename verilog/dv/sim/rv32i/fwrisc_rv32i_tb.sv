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
		);
	
	reg[15:0]				irq_trigger_count = 0;
	reg                     irq_r = 0;
	assign irq = irq_r;
	
	always @(posedge clock) begin
		if (reset) begin
			irq_trigger_count <= 0;
			irq_r <= 0;
		end else begin
			if (dvalid && {daddr[31:2], 2'b0} == 32'h40000000) begin
				irq_trigger_count <= dwdata;
			end else if (dvalid && {daddr[31:2], 2'b0} == 32'h40000004) begin
				irq_r <= 0;
			end else begin
				if (irq_trigger_count == 1) begin
					irq_r <= 1;
				end
				if (irq_trigger_count) begin
					irq_trigger_count <= irq_trigger_count - 1;
				end
			end
		end
	end
	
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
		.b_we				((dvalid && dwrite && daddr[31:28] == 4'h8)), 
		.b_adr				(daddr[31:2]			),
		.b_sel				(dwstb  				),
		.b_dat_r			(drdata					));

endmodule


