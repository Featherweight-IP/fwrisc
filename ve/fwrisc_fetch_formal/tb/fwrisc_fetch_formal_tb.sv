/****************************************************************************
 * fwrisc_fetch_formal_tb.sv
 ****************************************************************************/
 
`include "fwrisc_fetch_formal_tb_defines.svh"

`ifndef TEST_MODULE
	`define TEST_MODULE fwrisc_fetch_formal_smoke_test
`endif

`ifndef CHECKER_MODULE
	`define CHECKER_MODULE fwrisc_fetch_formal_smoke_checker
`endif

/**
 * Module: fwrisc_fetch_formal_tb
 * 
 * TODO: Add module documentation
 */
module fwrisc_fetch_formal_tb(input clock);

	reg[3:0]	reset_cnt = 0;
	(* keep *)
	reg 		reset = 1;
	
	always @(posedge clock) begin
		if (reset_cnt == 1) begin
			reset <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end

`ifndef FORMAL
	reg clk = 0;
	always #5 clk = ~clk;
	assign clock = clk;

	initial begin
		$dumpfile("simx.vcd");
		$dumpvars(0, fwrisc_fetch_formal_tb);
		#1000;
		$finish;
	end
`endif	
	

	wire[31:0]				next_pc;
	wire					next_pc_seq;
	wire[31:0]				iaddr;
	wire[31:0]				idata;
	wire					ivalid;
	wire					iready;
	wire					fetch_valid;
	wire					decode_complete;
	wire[31:0]				instr;
	wire					instr_c;
	
	reg[3:0]				instr_count = 0;
	reg[3:0]				fetch_count = 0;
	
	`TEST_MODULE u_test(
			.clock              (clock             ), 
			.reset              (reset             ), 
			.next_pc            (next_pc           ), 
			.next_pc_seq        (next_pc_seq       ), 
			.iaddr              (iaddr             ), 
			.idata              (idata             ), 
			.ivalid             (ivalid            ), 
			.iready             (iready            ), 
			.fetch_valid        (fetch_valid       ), 
			.decode_complete    (decode_complete   ), 
			.instr              (instr             ), 
			.instr_c            (instr_c           )
			);
	
	fwrisc_fetch #(
		.ENABLE_COMPRESSED  (1 )
		) u_dut (
		.clock              (clock             ), 
		.reset              (reset             ), 
		.next_pc            (next_pc           ), 
		.next_pc_seq        (next_pc_seq       ), 
		.iaddr              (iaddr             ), 
		.idata              (idata             ), 
		.ivalid             (ivalid            ), 
		.iready             (iready            ), 
		.fetch_valid        (fetch_valid       ), 
		.decode_complete    (decode_complete   ), 
		.instr              (instr             ), 
		.instr_c            (instr_c           ));
	

	`CHECKER_MODULE u_checker(
		.clock(clock),
		.reset(reset),
		.next_pc(next_pc),
		.next_pc_seq(next_pc_seq),
		.iaddr(iaddr),
		.idata(idata),
		.ivalid(ivalid),
		.iready(iready),
		.fetch_valid(fetch_valid),
		.decode_complete(decode_complete),
		.instr(instr),
		.instr_c(instr_c)
		);
			
endmodule

