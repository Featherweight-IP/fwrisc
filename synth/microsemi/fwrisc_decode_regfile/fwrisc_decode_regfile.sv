/****************************************************************************
 * fwrisc_decode_regfile.sv
 ****************************************************************************/

/**
 * Module: fwrisc_decode_regfile
 * 
 * TODO: Add module documentation
 */
module fwrisc_decode_regfile(
		input				clock,
		input				reset,
		
		input				fetch_valid, // valid/accept signals back to fetch
		output				decode_ready, // signals that instr has been accepted
		input[31:0]			instr,
		input				instr_c,
		input[31:0]			pc,
	
	
		// Output to Exec phase
		output				decode_valid,
		input				exec_ready,
		output reg[31:0]	op_a, 		// operand a (immediate or register)
		output reg[31:0]	op_b, 		// operand b (immediate or register)
		output reg[31:0]	op_c,		// Immediate operand (S-type, B-type)
		output reg[5:0]		rd_raddr, 	// Destination register address
		output reg[4:0]     op_type,
		
		// Stub regfile signals
		input				instr_complete,
		input[5:0]			rd_waddr,
		input[31:0]			rd_wdata,
		input				rd_wen
		);		

		// Register file interface
		wire[5:0]			ra_raddr;
		wire[31:0]			ra_rdata;
		wire[5:0]			rb_raddr;
		wire[31:0]			rb_rdata;
		
		fwrisc_decode #(
			.ENABLE_COMPRESSED  (1 )
			) u_decode (
			.clock              (clock             ), 
			.reset              (reset             ), 
			.fetch_valid        (fetch_valid       ), 
			.decode_ready       (decode_ready      ), 
			.instr_i            (instr             ), 
			.instr_c            (instr_c           ), 
			.pc                 (pc                ), 
			.ra_raddr           (ra_raddr          ), 
			.ra_rdata           (ra_rdata          ), 
			.rb_raddr           (rb_raddr          ), 
			.rb_rdata           (rb_rdata          ), 
			.decode_valid       (decode_valid      ), 
			.exec_ready         (exec_ready        ), 
			.op_a               (op_a              ), 
			.op_b               (op_b              ), 
			.op_c               (op_c              ),
			.rd_raddr           (rd_raddr          ),
			.op_type			(op_type           )
			);
		
		fwrisc_regfile #(
			.ENABLE_COUNTERS  (1 )
			) u_regfile (
			.clock            (clock           ), 
			.reset            (reset           ), 
			.instr_complete   (instr_complete  ), 
			.ra_raddr         (ra_raddr        ), 
			.ra_rdata         (ra_rdata        ), 
			.rb_raddr         (rb_raddr        ), 
			.rb_rdata         (rb_rdata        ), 
			.rd_waddr         (rd_waddr        ), 
			.rd_wdata         (rd_wdata        ), 
			.rd_wen           (rd_wen          ));

endmodule

