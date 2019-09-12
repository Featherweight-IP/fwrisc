/****************************************************************************
 * fwrisc_mem.sv
 ****************************************************************************/

/**
 * Module: fwrisc_mem
 * 
 * TODO: Add module documentation
 */
module fwrisc_mem (
		input			clock,
		input			reset,
		/**
		 * Internal bus
		 */
		input				req_valid,
		input[31:0]			req_addr,
		input[3:0]			req_op,
		input[31:0]			req_data,
		output reg			ack_valid,
		output reg[31:0]	ack_data,

		/**
		 * External bus
		 */
		output reg			dvalid,
		output reg[31:0]	daddr,
		output reg[31:0]	dwdata,
		output reg[3:0]		dwstb,
		output reg			dwrite,
		input[31:0]			drdata,
		input				dready
		);
	
	`include "fwrisc_mem_op.svh"
	
	parameter[1:0]
		STATE_WAIT_REQ = 2'd0,
		STATE_WAIT_RSP = (STATE_WAIT_REQ + 2'd1)
		;

	reg[1:0]		mem_state;
	
	always @(posedge clock) begin
		if (reset) begin
			ack_valid <= 0;
			mem_state <= 0;
		end else begin
			case (mem_state)
				STATE_WAIT_REQ: begin
					ack_valid <= 0;
					if (req_valid && !ack_valid) begin
						dvalid <= 1;
						mem_state <= STATE_WAIT_RSP;
						case (req_op)
							OP_SB: begin
								
							end
							OP_SH: begin
								
							end
							OP_SW: begin
							end
							default: dwstb <= 4'b0000;
						endcase
					end
				end
				STATE_WAIT_RSP: begin
					if (dready) begin
						ack_valid <= 1;
						dvalid <= 0;
						mem_state <= STATE_WAIT_REQ;
					end
				end
			endcase
		end
	end


endmodule


