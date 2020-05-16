/****************************************************************************
 * fwrisc_callstack_cache.sv
 ****************************************************************************/

/**
 * Module: fwrisc_callstack_cache
 * 
 * Implements a checker for callstack stomping
 */
module fwrisc_callstack_cache(
		input 			clock,
		input			reset,
		input			decode_valid,
		input[4:0]		op_type,
		input[5:0]		op,
		// Destination-register address
		input[5:0]		rs2,
		input[5:0]		rd,
		output[31:0]	exp_data,
		output			exp_data_valid
		);
	
	`include "fwrisc_op_type.svh"
	`include "fwrisc_mem_op.svh"

	// Indiciates that a call has occurred, and we're
	// waiting for RA to be stored on the stack
	reg armed_for_stack_store;
	reg[4:0] link;
	
	always @(posedge clock) begin
		if (reset) begin
			armed_for_stack_store <= 0;
			link <= 0;
		end else begin
			if (decode_valid) begin
				case (op_type)
					OP_TYPE_JUMP: begin
						if (rd == 1 || rd == 5) begin
							// JAL/JALR with rd==link
							// EXpect store of link
							armed_for_stack_store <= 1;
							link <= rd;
							$display("Call");
						end
					end
					OP_TYPE_LDST: begin
						// We've identified the expected link store
						case (op)
							OP_SW: begin
								if (armed_for_stack_store && rs2 == link) begin
									armed_for_stack_store <= 0;
									$display("Store");
								end
							end
							OP_LW: begin
								if (rd == 1 || rd == 5) begin
									// Valid
									$display("Load LR");
								end
							end
						endcase
					end
				endcase
			end
		end
	end
	
	// Store return address any time we make a jump
	// - First store to SP after a call is the LR
	// - 
	// - Detect when data-read value doesn't match
	//   cached value
	// 
	// - Cache write value on instruction after a call
	


endmodule


