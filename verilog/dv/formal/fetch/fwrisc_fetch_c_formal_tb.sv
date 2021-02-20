/****************************************************************************
 * fwrisc_fetch_formal_tb.sv
 ****************************************************************************/
 
// `include "fwrisc_fetch_formal_defines.svh"

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
module fwrisc_fetch_c_formal_tb(input clock);

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
	reg[31:0]				next_pc_r = {32{1'b0}};
	wire					next_pc_seq;
	reg						next_pc_seq_r = 1'b0;
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

	localparam N_OUT_INSTR = 1;
	localparam N_IN_DATA = (N_OUT_INSTR+1);
	// Track the sequence of input data to the fetch unit
	reg[32*N_IN_DATA-1:0]	idata_i;
	reg[N_IN_DATA-1:0]		idata_taken = {N_IN_DATA{1'b0}};
	reg[32*N_IN_DATA-1:0]	iaddr_i;
	
	always @(posedge clock) begin
		if (reset) begin
			idata_taken <= {N_IN_DATA{1'b0}};
		end else begin
			if (ivalid && iready) begin
				// Data just taken
				idata_taken <= {idata_taken[N_IN_DATA-2:0], 1'b1};
				idata_i <= {idata_i[32*(N_IN_DATA-1)-1:0], idata};
				iaddr_i <= {iaddr_i[32*(N_IN_DATA-1)-1:0], iaddr};
			end
		end
	end
	
	fwrisc_fetch #(
		.ENABLE_COMPRESSED  (1)
		) u_dut (
		.clock              (clock             ), 
		.reset              (reset             ), 
		.next_pc            (next_pc_r         ), 
		.next_pc_seq        (next_pc_seq_r     ), 
		.iaddr              (iaddr             ), 
		.idata              (idata             ), 
		.ivalid             (ivalid            ), 
		.iready             (iready            ), 
		.fetch_valid        (fetch_valid       ), 
		.decode_complete    (decode_complete   ), 
		.instr              (instr             ), 
		.instr_c            (instr_c           ));
	
	// Track the output sequence of instructions
	reg[32*N_OUT_INSTR-1:0]		instr_o;
	reg[N_OUT_INSTR-1:0]		instr_o_valid = {N_OUT_INSTR{1'b0}};
	

	integer instr_i;
	always @(posedge clock) begin
		if (reset) begin
			instr_out_valid <= {N_OUT_INSTR{1'b0}};
		end else begin
			if (fetch_valid) begin
				instr_o_valid <= {instr_o_valid[N_OUT_INSTR-2:1], 1'b1};
				instr_o <= {instr_o[32*(N_OUT_INSTR-1)-1:32], instr};
			
				// If the output instruction is compressed, we only need
				// to look at the most-recent input
				if (instr[1:0] != 2'b11) begin
					assert(instr_c == 1);
					/*
					 */
					assert(iaddr_i[31:0] == {next_pc_r[31:2], 2'b0});
					if (!next_pc_r[1]) begin
						assert(instr == idata_i[15:0]);
					end else begin
						assert(instr == idata_i[31:16]);
					end
					assert(instr[31:16] == {16{1'b0}});
				end else begin
					assert(instr_c == 0);
					/*
					 */
					// Not compressed
					if (!next_pc_r[1]) begin
						// Aligned fetch -- should be exactly equal
						assert(instr == idata_i[31:0]);
						assert(iaddr_i[31:0] == {next_pc_r[31:2], 2'b0});
					end else begin
						// Unaligned fetch -- will be a combination of the last two fetches
						assert(instr == {idata_i[15:0], idata_i[63:48]});
						// Two fetches must be sequential words
						assert(iaddr_i[63:32] == {next_pc_r[31:2], 2'b0});
						assert(iaddr_i[31:2] == iaddr_i[63:34]+1);
					end
				end
				next_pc_r <= {{8{1'b0}}, next_pc[23:1], 1'b0};
				next_pc_seq_r <= next_pc_seq;
				decode_complete <= 1'b1;
			end else begin
				decode_complete <= 1'b0;
			end
		end
	end
	
endmodule

