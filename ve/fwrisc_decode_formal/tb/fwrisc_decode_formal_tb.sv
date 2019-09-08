/****************************************************************************
 * fwrisc_decode_formal_tb.sv
 ****************************************************************************/


/**
 * Module: fwrisc_decode_formal_tb
 * 
 * TODO: Add module documentation
 */
module fwrisc_decode_formal_tb(input clock);

	reg[3:0]	reset_cnt = 0;
	reg 		reset = 1;
	
	always @(posedge clock) begin
		if (reset_cnt == 1) begin
			reset <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end

	// TODO: instance checker, test, and DUT
	wire 		fetch_valid;
	wire 		decode_complete;
	wire[31:0] 	instr;
	wire		instr_c;
	wire[5:0]	ra_raddr;
	reg[31:0]	ra_rdata;
	wire[5:0]	rb_raddr;
	reg[31:0]	rb_rdata;
	wire		decode_valid;
	reg			exec_complete;
	wire[31:0]	op_a;
	wire[31:0]	op_b;
	wire[31:0]	op_c;
	wire[5:0]	rd;
	wire[5:0]	rd_raddr;
	wire[4:0]	op_type;
	
	
	fwrisc_decode_formal_test u_test(
		.clock              (clock             ), 
		.reset              (reset             ), 
		.fetch_valid        (fetch_valid       ), 
		.decode_ready       (decode_complete   ), 
		.instr              (instr             ), 
		.instr_c            (instr_c           )
			);
	
	always @(posedge clock) begin
		ra_rdata <= ra_raddr;
		rb_rdata <= rb_raddr;
		exec_complete <= decode_valid;
	end

	fwrisc_decode #(
		.ENABLE_COMPRESSED  (0 )
		) u_dut (
		.clock              (clock             ), 
		.reset              (reset             ), 
		.fetch_valid        (fetch_valid       ), 
		.decode_complete    (decode_complete   ), 
		.instr_i            (instr             ), 
		.instr_c            (instr_c           ), 
		.ra_raddr           (ra_raddr          ), 
		.ra_rdata           (ra_rdata          ), 
		.rb_raddr           (rb_raddr          ), 
		.rb_rdata           (rb_rdata          ), 
		.decode_valid       (decode_valid      ), 
		.exec_complete      (exec_complete     ), 
		.op_a               (op_a              ), 
		.op_b               (op_b              ), 
		.op_c               (op_c              ), 
		.rd					(rd                ),
		.rd_raddr           (rd_raddr          ), 
		.op_type            (op_type           ));

	fwrisc_decode_formal_checker u_checker(
		.clock              (clock             ), 
		.reset              (reset             ), 
		.instr              (instr             ), 
		.instr_c            (instr_c           ), 
		.decode_valid       (decode_valid      ), 
		.op_a               (op_a              ), 
		.op_b               (op_b              ), 
		.op_c               (op_c              ), 
		.rd_raddr           (rd_raddr          ), 
		.op_type            (op_type           )
		);
			
endmodule

