/****************************************************************************
 * fwrisc_exec_formal_tb.sv
 ****************************************************************************/

`include "fwrisc_exec_formal_tb_defines.svh"

`ifndef TEST_MODULE
`define TEST_MODULE fwrisc_exec_formal_smoke_test
`endif

`ifndef CHECKER_MODULE
`define CHECKER_MODULE fwrisc_exec_formal_smoke_checker
`endif

/**
 * Module: fwrisc_exec_formal_tb
 * 
 * TODO: Add module documentation
 */
module fwrisc_exec_formal_tb(input clock);

	reg[3:0]	reset_cnt = 0;
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
		$dumpvars(0, fwrisc_exec_formal_tb);
		#1000;
		$finish;
	end
`endif
	
	wire				decode_valid;
	wire				instr_complete;
	wire				instr_c;
	wire[4:0]			op_type;
	wire[31:0]			op_a;
	wire[31:0]			op_b;
	wire[5:0]			op;
	wire[31:0]			op_c;
	wire[5:0]			rd;
	wire[5:0]			rd_waddr;
	wire[31:0]			rd_wdata;
	wire				rd_wen;
	wire[31:0]			pc;
	wire				pc_seq;

	// TODO: instance checker, test, and DUT
	
	`TEST_MODULE u_test(
			.clock           (clock          ), 
			.reset           (reset          ), 
			.decode_valid    (decode_valid   ), 
			.instr_complete  (instr_complete ), 
			.pc              (pc             ),
			.instr_c         (instr_c        ), 
			.op_type         (op_type        ), 
			.op_a            (op_a           ), 
			.op_b            (op_b           ), 
			.op              (op             ), 
			.op_c            (op_c           ),
			.rd              (rd             )
			);
	
	
	fwrisc_exec #(
		.ENABLE_MUL_DIV  (1 )
		) u_dut (
		.clock           (clock          ), 
		.reset           (reset          ), 
		.decode_valid    (decode_valid   ), 
		.instr_complete  (instr_complete ), 
		.instr_c         (instr_c        ), 
		.op_type         (op_type        ), 
		.op_a            (op_a           ), 
		.op_b            (op_b           ), 
		.op              (op             ), 
		.op_c            (op_c           ),
		.rd              (rd             ),
		.rd_waddr        (rd_waddr       ), 
		.rd_wdata        (rd_wdata       ), 
		.rd_wen          (rd_wen         ), 
		.pc              (pc             ), 
		.pc_seq          (pc_seq         ));

	// TODO: instance DUT
	
	`CHECKER_MODULE u_checker(
			.clock           (clock          ), 
			.reset           (reset          ), 
			.decode_valid    (decode_valid   ), 
			.instr_complete  (instr_complete ), 
			.instr_c         (instr_c        ), 
			.op_type         (op_type        ), 
			.op_a            (op_a           ), 
			.op_b            (op_b           ), 
			.op              (op             ), 
			.op_c            (op_c           ), 
			.rd              (rd             ),
			.rd_waddr        (rd_waddr       ), 
			.rd_wdata        (rd_wdata       ), 
			.rd_wen          (rd_wen         ), 
			.pc              (pc             ), 
			.pc_seq          (pc_seq         )
		);
			
endmodule

