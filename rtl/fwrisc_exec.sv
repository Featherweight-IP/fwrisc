/****************************************************************************
 * fwrisc_exec.sv
 ****************************************************************************/

/**
 * Module: fwrisc_exec
 * 
 * TODO: Add module documentation
 */
module fwrisc_exec #(
		parameter 			ENABLE_MUL_DIV=1
		)(
		input				clock,
		input				reset,
		input				decode_valid,
		output reg 			instr_complete,

		// Indicates whether the instruction is compressed
		input				instr_c,

		input[4:0]			op_type,
		
		input[31:0]			op_a,
		input[31:0]			op_b,
		input[5:0]			op,
		input[31:0]			op_c,
		input[5:0]			rd,
		
		output reg[5:0]		rd_waddr,
		output reg[31:0]	rd_wdata,
		output reg			rd_wen,
		
		output reg[31:0]	pc,
		// Indicates that the PC is sequential to the last PC
		output reg			pc_seq
		);
	
	`include "fwrisc_alu_op.svh"
	`include "fwrisc_op_type.svh"
	
	parameter [3:0] 
		STATE_EXECUTE = 4'd0,
		STATE_BRANCH_TAKEN = (STATE_EXECUTE + 4'd1),
		STATE_JUMP         = (STATE_BRANCH_TAKEN + 4'd1),
		STATE_MDS_COMPLETE = (STATE_JUMP + 4'd1)
		;

	reg [3:0]				exec_state;
	reg[31:0]				pc_next;
	reg						pc_seq_next;
	wire					mds_in_valid = (op_type == OP_TYPE_MDS && exec_state == STATE_EXECUTE);
	wire					mds_out_valid;
	wire[31:0]				mds_out;
	
	// Holds the next PC if execution is sequential
	reg[2:0]				next_pc_seq_incr;
	wire[31:0]				next_pc_seq = pc + next_pc_seq_incr;
	
	always @* begin
		if (exec_state == STATE_BRANCH_TAKEN) begin
			next_pc_seq_incr = 0;
		end else begin
			next_pc_seq_incr = (instr_c)?2:4;
		end
	end

	// Detect end-of-instruction
	wire branch_taken = ((op_type == OP_TYPE_BRANCH && alu_out[0]) || op_type == OP_TYPE_JUMP);
	wire instr_complete_w = (
			decode_valid &&
			(
				(exec_state == STATE_EXECUTE && (
						op_type == OP_TYPE_ARITH || !branch_taken))
				|| (exec_state == STATE_BRANCH_TAKEN)
				|| (exec_state == STATE_JUMP)
			)
		);
	
	always @* begin
		// TODO:
		if (exec_state == STATE_BRANCH_TAKEN || exec_state == STATE_JUMP) begin
			pc_next = alu_out;
			pc_seq_next = 0;
		end else begin
			pc_next = next_pc_seq;
			pc_seq_next = 1;
		end
	end
	
	always @(posedge clock) begin
		if (reset) begin
			exec_state <= STATE_EXECUTE;
			instr_complete <= 0;
			pc <= 'h8000_0000;
			pc_seq <= 1;
		end else begin
			instr_complete <= instr_complete_w;
			case (exec_state)
				STATE_EXECUTE: begin
					// Single-cycle execute state. For ALU instructions,
					// we're done at the end of this state
					if (decode_valid) begin
						// TODO: determine cases where we need multi-cycle
						case (op_type)
							/**
							 * STATE_EXECUTE: regs[rd] <= alu_out
							 */
							OP_TYPE_ARITH: begin
								pc <= pc_next;
								pc_seq <= pc_seq_next;
							end
							/**
							 * STATE_EXECUTE: alu_out = (op_a ? op_b)
							 * STATE_BRANCH_TAKEN: pc <= pc + jump_offset (op_c)
							 */
							OP_TYPE_BRANCH: begin
								if (alu_out[0]) begin
									// Taken branch
									exec_state <= STATE_BRANCH_TAKEN;
								end else begin
									// Still sequential
									pc <= pc_next;
									pc_seq <= pc_seq_next;
								end
							end
							OP_TYPE_LDST: begin
								// TODO:
							end
							OP_TYPE_MDS: begin
								exec_state <= STATE_MDS_COMPLETE;
							end
							/**
							 * STATE_EXECUTE: regs[rd] <= pc_seq_next
							 * STATE_JUMP: pc <= jump_base (op_a) + jump_offset (op_c)
							 */
							OP_TYPE_JUMP: begin
								exec_state <= STATE_JUMP;
							end
							OP_TYPE_CALL: begin
								// TODO:
							end
							default /*OP_TYPE_CSR*/: begin
							end
						endcase
					end
				end
				
				STATE_JUMP: begin
					pc <= alu_out;
					pc_seq <= pc_seq_next;
					exec_state <= STATE_EXECUTE;
				end
				
				STATE_BRANCH_TAKEN: begin
					pc <= alu_out;
					pc_seq <= pc_seq_next;
					exec_state <= STATE_EXECUTE;
				end
				STATE_MDS_COMPLETE: begin
					if (mds_out_valid) begin
						exec_state <= STATE_EXECUTE;
						pc <= pc_next;	
						pc_seq <= pc_seq_next;
					end
				end
			endcase
		end
	end

	// TODO: ALU input selector
	wire alu_op_a_sel_pc = (
			// Used to compute target address
			(exec_state == STATE_BRANCH_TAKEN)
			// PC+4 stored to RD
			|| (exec_state == STATE_EXECUTE && op_type == OP_TYPE_JUMP)
			);
	wire alu_op_b_sel_c = (
			(exec_state == STATE_BRANCH_TAKEN)
			|| (exec_state == STATE_JUMP)
			);
	wire alu_op_sel_add = (
			(exec_state == STATE_BRANCH_TAKEN)
			|| (exec_state == STATE_JUMP)
			);
	wire [31:0]	alu_op_a = (alu_op_a_sel_pc)?next_pc_seq:op_a;
	wire [31:0]	alu_op_b = (alu_op_b_sel_c)?op_c:op_b;
	
	wire [3:0]	alu_op = (alu_op_sel_add)?OP_ADD:op;
	
	wire [31:0]	alu_out;
	
	// TODO: rd_wen
	always @* begin
		rd_wen = (decode_valid && 
				((exec_state == STATE_EXECUTE) && 
					(op_type == OP_TYPE_ARITH || op_type == OP_TYPE_JUMP))
				);
	end

	// TODO: rd_wdata input selector
	always @* begin
		rd_wdata = alu_out;
		rd_waddr = rd;
	end

	fwrisc_alu u_alu (
		.clock  (clock     ), 
		.reset  (reset     ), 
		.op_a   (alu_op_a  ), 
		.op_b   (alu_op_b  ), 
		.op     (alu_op    ), 
		.out    (alu_out   )
		);
	
	fwrisc_mul_div_shift #(
		.ENABLE_MUL_DIV  (ENABLE_MUL_DIV )
		) u_mds (
		.clock           (clock          ), 
		.reset           (reset          ), 
		.in_a            (op_a           ), 
		.in_b            (op_b           ), 
		.op              (op             ), 
		.in_valid        (mds_in_valid   ), 
		.out             (mds_out        ), 
		.out_valid       (mds_out_valid  ));
	


endmodule


