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
		output	 			instr_complete,

		// Indicates whether the instruction is compressed
		input				instr_c,

		input[4:0]			op_type,
		
		input[31:0]			op_a,
		input[31:0]			op_b,
		input[5:0]			op,
		input[31:0]			op_c,
		
		output reg[5:0]		rd_waddr,
		output reg[31:0]	rd_wdata,
		output reg			rd_wen,
		
		output reg[31:1]	pc,
		// Indicates that the PC is sequential to the last PC
		output reg			pc_seq
		);
	
	`include "fwrisc_alu_op.svh"
	`include "fwrisc_op_type.svh"
	
	parameter [3:0] 
		STATE_EXECUTE = 4'd0,
		STATE_BRANCH_TAKEN = (STATE_EXECUTE + 4'd1)
		;

	reg [3:0]				exec_state;
	reg[31:1]				pc_next;
	
	// Holds the next PC if execution is sequential
	wire[31:1]				next_pc_seq = (instr_c)?pc+32'd1:pc+32'd2;
	
	assign instr_complete = (
			decode_valid &&
			((exec_state == STATE_EXECUTE && op_type == OP_TYPE_ARITH))
		);
	
	always @* begin
		// TODO:
		pc_next = next_pc_seq;
		pc_seq = 1;
	end
	
	always @(posedge clock) begin
		if (reset) begin
			exec_state <= STATE_EXECUTE;
			pc <= ('h8000_0000 >> 1);
		end else begin
			case (exec_state)
				STATE_EXECUTE: begin
					// Single-cycle execute state. For ALU instructions,
					// we're done at the end of this state
					if (decode_valid) begin
						// TODO: determine cases where we need multi-cycle
						case (op_type)
							OP_TYPE_ARITH: begin
								pc <= pc_next;
							end
							OP_TYPE_BRANCH: begin
								if (alu_out[0]) begin
									// Taken branch
									exec_state <= STATE_BRANCH_TAKEN;
								end
							end
						endcase
					end
				end
			endcase
		end
	end

	// TODO: ALU input selector
	wire [31:0]	alu_op_a = op_a;
	wire [31:0]	alu_op_b = op_b;
	wire [3:0]	alu_op = op;
	wire [31:0]	alu_out;
	
	// TODO: rd_wen
	always @* begin
		rd_wen = (decode_valid && (exec_state == STATE_EXECUTE) && op_type == OP_TYPE_ARITH);
	end

	// TODO: rd_wdata input selector
	always @* begin
		rd_wdata = alu_out;
		rd_waddr = 0;
	end

	fwrisc_alu u_alu (
		.clock  (clock     ), 
		.reset  (reset     ), 
		.op_a   (alu_op_a  ), 
		.op_b   (alu_op_b  ), 
		.op     (alu_op    ), 
		.out    (alu_out   )
		);
	
//	fwrisc_mul_div_shift #(
//		.ENABLE_MUL_DIV  (ENABLE_MUL_DIV )
//		) u_mds (
//		.clock           (clock          ), 
//		.reset           (reset          ), 
//		.in_a            (in_a           ), 
//		.in_b            (in_b           ), 
//		.op              (op             ), 
//		.in_valid        (in_valid       ), 
//		.out             (out            ), 
//		.out_valid       (out_valid      ));
	


endmodule


