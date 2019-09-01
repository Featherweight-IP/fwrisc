/****************************************************************************
 * fwrisc_exec.sv
 ****************************************************************************/

/**
 * Module: fwrisc_exec
 * 
 * TODO: Add module documentation
 */
module fwrisc_exec #(
		parameter int		ENABLE_MUL_DIV=1
		)(
		input				clock,
		input				reset,
		input				decode_valid,
		output reg			exec_ready,

		input[1:0]			op_type,
		
		input[31:0]			op_a,
		input[31:0]			op_b,
		input[5:0]			op,
		input[31:0]			op_c,
		
		output reg[5:0]		rd_waddr,
		output reg[31:0]	rd_wdata,
		output reg			rd_wen
		
		);
	
	parameter [3:0] 
		STATE_EXECUTE = 4'd0
		;
	
	reg [3:0]				exec_state;
	
	always @(posedge clock) begin
		if (reset) begin
			exec_state <= STATE_WAIT_DECODE;
		end else begin
			case (exec_state)
				
				STATE_EXECUTE: begin
					// Single-cycle execute state. For ALU instructions,
					// we're done at the end of this state
					if (decode_valid) begin
						// TODO: determine cases where we need multi-cycle
					end
					exec_state <= STATE_WAIT_DECODE;
				end
			endcase
		end
	end
	
	wire [2:0]	op;

	always @* begin
		case ({op_atype, op_btype
	end
	assign op = u_alu.OP_ADD;
	
	fwrisc_alu u_alu (
		.clock  (clock ), 
		.reset  (reset ), 
		.op_a   (op_a  ), 
		.op_b   (op_b  ), 
		.op     (op    ), 
		.out    (out   ), 
		.carry  (carry ), 
		.eqz    (eqz   ));
	
	fwrisc_mul_div_shift #(
		.ENABLE_MUL_DIV  (ENABLE_MUL_DIV )
		) u_mds (
		.clock           (clock          ), 
		.reset           (reset          ), 
		.in_a            (in_a           ), 
		.in_b            (in_b           ), 
		.op              (op             ), 
		.in_valid        (in_valid       ), 
		.out             (out            ), 
		.out_valid       (out_valid      ));
	


endmodule


