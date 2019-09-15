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
		output reg			pc_seq,
		
		// Exception Vector
		input[31:0]			mtvec,
	
		// Data interface
		output[31:0]		daddr,
		output				dvalid,
		output				dwrite,
		output[31:0]		dwdata,
		output[3:0]			dwstb,
		input[31:0]			drdata,
		input				dready
		);
	
	`include "fwrisc_alu_op.svh"
	`include "fwrisc_mem_op.svh"
	`include "fwrisc_op_type.svh"
	`include "fwrisc_csr_addr.svh"
	`include "fwrisc_system_op.svh"
	
	parameter [3:0] 
		STATE_EXECUTE = 4'd0,
		STATE_BRANCH_TAKEN = (STATE_EXECUTE + 4'd1),
		STATE_JUMP         = (STATE_BRANCH_TAKEN + 4'd1),
		STATE_CSR          = (STATE_JUMP + 4'd1),
		STATE_MDS_COMPLETE = (STATE_CSR + 4'd1),
		STATE_LDST_COMPLETE = (STATE_MDS_COMPLETE + 4'd1),
		// Store the PC to EPC
		STATE_EXCEPTION_1   = (STATE_LDST_COMPLETE + 4'd1),
		STATE_EXCEPTION_2   = (STATE_EXCEPTION_1 + 4'd1),
		STATE_EXCEPTION_3   = (STATE_EXCEPTION_2 + 4'd1)
		;

	reg [3:0]				exec_state;
	reg[31:0]				pc_next;
	reg						pc_seq_next;
	wire					mds_in_valid = (
			(op_type == OP_TYPE_MDS && exec_state == STATE_EXECUTE)
			&& decode_valid
			);
	wire					mds_out_valid;
	wire[31:0]				mds_out;

	wire					mem_req_valid;
	wire[31:0]				mem_req_addr;
	wire					mem_ack_valid;
	wire[31:0]				mem_ack_data;
	
	// Holds the next PC if execution is sequential
	reg[2:0]				next_pc_seq_incr;
	reg[3:0]				mcause;
	wire[31:0]				next_pc_seq = pc + next_pc_seq_incr;
	
	always @* begin
		if (exec_state == STATE_BRANCH_TAKEN || exec_state == STATE_JUMP) begin
			next_pc_seq_incr = 0;
		end else begin
			next_pc_seq_incr = (instr_c)?2:4;
		end
	end

	// Detect end-of-instruction
	wire branch_taken = ((op_type == OP_TYPE_BRANCH && alu_out[0]) || op_type == OP_TYPE_JUMP);
//	wire instr_complete_w = (
//			decode_valid &&
//			(
//				(exec_state == STATE_EXECUTE && (
//						op_type == OP_TYPE_ARITH || 
//						(op_type == OP_TYPE_BRANCH && !branch_taken)))
//				|| (exec_state == STATE_BRANCH_TAKEN)
//				|| (exec_state == STATE_JUMP)
//				|| (exec_state == STATE_CSR)
//			)
//		);
//	
	always @* begin
		// TODO:
		if (exec_state == STATE_BRANCH_TAKEN || exec_state == STATE_JUMP) begin
			pc_next = {alu_out[31:1], 1'b0};
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
			mcause <= 0;
		end else begin
//			instr_complete <= instr_complete_w;
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
								instr_complete <= 1;
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
									instr_complete <= 1;
								end
							end
							OP_TYPE_LDST: begin
								// alu_out holds the data address
								// TODO: handle misaligne accesses
								exec_state <= STATE_LDST_COMPLETE;
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
							OP_TYPE_SYSTEM: begin
								if (op == OP_TYPE_ERET) begin
									instr_complete <= 1;
									pc <= op_a; 
									pc_seq <= 0;
									exec_state <= STATE_EXECUTE;
								end else begin
									mcause <= (op == OP_TYPE_EBREAK)?3:11; // MCALL/MBREAK
									exec_state <= STATE_EXCEPTION_1;
								end
							end
							/**
							 * STATE_EXECUTE: regs[csr] <= op_a [op] op_b
							 * STATE_CSR: regs[rd] <= op_b (regs[csr])
							 */
							default /*OP_TYPE_CSR*/: begin
								exec_state <= STATE_CSR;
							end
						endcase
					end else begin
						instr_complete <= 0;
					end
				end
				
				STATE_CSR: begin
					pc <= pc_next;
					pc_seq <= pc_seq_next;
					exec_state <= STATE_EXECUTE;
					instr_complete <= 1;
				end
				
				STATE_JUMP: begin
					// Jumps automatically filter out byte-aligned addresses
					pc <= {alu_out[31:1], 1'b0};
					pc_seq <= pc_seq_next;
					exec_state <= STATE_EXECUTE;
					instr_complete <= 1;
				end
				
				STATE_BRANCH_TAKEN: begin
					pc <= alu_out;
					pc_seq <= pc_seq_next;
					exec_state <= STATE_EXECUTE;
					instr_complete <= 1;
				end
				STATE_MDS_COMPLETE: begin
					if (mds_out_valid) begin
						exec_state <= STATE_EXECUTE;
						pc <= pc_next;	
						pc_seq <= pc_seq_next;
						instr_complete <= 1;
					end
				end
				STATE_LDST_COMPLETE: begin
					if (mem_ack_valid) begin
						exec_state <= STATE_EXECUTE;
						pc <= pc_next;	
						pc_seq <= pc_seq_next;
						instr_complete <= 1;
					end
				end
				STATE_EXCEPTION_1: begin
					// Write MEPC
					exec_state <= STATE_EXCEPTION_2;
				end
				STATE_EXCEPTION_2: begin
					// Write MTVAL
					exec_state <= STATE_EXCEPTION_3;
				end
				STATE_EXCEPTION_3: begin
					// Write MCAUSE
					// TODO: change pc to exception base
					pc <= mtvec;
					pc_seq <= 0;
					instr_complete <= 1;
					exec_state <= STATE_EXECUTE;
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
			|| (exec_state == STATE_EXECUTE && op_type == OP_TYPE_LDST)
			);
	wire alu_op_sel_add = (
			(exec_state == STATE_EXECUTE && op_type == OP_TYPE_LDST)
			|| (exec_state == STATE_BRANCH_TAKEN)
			|| (exec_state == STATE_JUMP)
			);
	wire alu_op_sel_opb = (
			(exec_state == STATE_CSR)
			);
	wire alu_op_sel_opa = (
			(exec_state == STATE_EXECUTE && op_type == OP_TYPE_JUMP)
			|| (exec_state == STATE_JUMP)
		);
	wire [31:0]	alu_op_a = (alu_op_a_sel_pc)?next_pc_seq:op_a;
	wire [31:0]	alu_op_b = (alu_op_b_sel_c)?op_c:op_b;
	reg [3:0]   alu_op;
	
	always @* begin
		case ({alu_op_sel_add,alu_op_sel_opb,alu_op_sel_opa})
			3'b100: alu_op = OP_ADD;
			3'b010: alu_op = OP_OPB;
			3'b001: alu_op = OP_OPA;
			default: alu_op = op;
		endcase
	end
	
	wire [31:0]	alu_out;
	
	// TODO: rd_wen
	always @* begin
		rd_wen = (decode_valid && !instr_complete &&
				(
					(exec_state == STATE_EXECUTE) && 
						(op_type == OP_TYPE_ARITH || op_type == OP_TYPE_JUMP 
							|| op_type == OP_TYPE_CSR)
					|| (exec_state == STATE_CSR)
					|| (exec_state == STATE_LDST_COMPLETE 
						&& (op == OP_LB || op == OP_LH || op == OP_LW
							|| op == OP_LBU || op == OP_LHU) && mem_ack_valid)
					|| (exec_state == STATE_MDS_COMPLETE && mds_out_valid)
					|| (exec_state == STATE_EXCEPTION_1 || exec_state == STATE_EXCEPTION_2 || exec_state == STATE_EXCEPTION_3)
				)
				
		);
	end

	// TODO: rd_wdata input selector
	always @* begin
		case (exec_state)
			STATE_EXCEPTION_1: rd_wdata = pc;
			// STATE_EXCEPTION_2: rd_wdata = alu_out;
			STATE_EXCEPTION_3: rd_wdata = {28'd0, mcause};
			STATE_MDS_COMPLETE: rd_wdata = mds_out;
			STATE_LDST_COMPLETE: rd_wdata = mem_ack_data;
			default: rd_wdata = alu_out;
		endcase
		case (exec_state)
			STATE_EXECUTE: rd_waddr = (op_type == OP_TYPE_CSR)?op_c[5:0]:rd;
			STATE_EXCEPTION_1: rd_waddr = CSR_MEPC;
			STATE_EXCEPTION_2: rd_waddr = CSR_MTVAL;
			STATE_EXCEPTION_3: rd_waddr = CSR_MCAUSE;
			default: rd_waddr = rd;
		endcase
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
		.op              (op[3:0]        ), 
		.in_valid        (mds_in_valid   ), 
		.out             (mds_out        ), 
		.out_valid       (mds_out_valid  ));

	assign mem_req_addr = alu_out;
	assign mem_req_valid = (
			exec_state == STATE_EXECUTE 
			&& op_type == OP_TYPE_LDST
			&& decode_valid);
	fwrisc_mem u_mem (
		.clock      (clock         ), 
		.reset      (reset         ), 
		.req_valid  (mem_req_valid ), 
		.req_addr   (mem_req_addr  ), 
		.req_op     (op[3:0]       ), 
		.req_data   (op_b          ), 
		.ack_valid  (mem_ack_valid ), 
		.ack_data   (mem_ack_data  ), 
		.dvalid     (dvalid        ), 
		.daddr      (daddr         ), 
		.dwdata     (dwdata        ), 
		.dwstb      (dwstb         ), 
		.dwrite     (dwrite        ), 
		.drdata     (drdata        ), 
		.dready     (dready        ));


endmodule


