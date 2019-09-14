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
			dvalid <= 0;
			daddr <= 0;
			dwdata <= 0;
			dwstb <= 0;
			dwrite <= 0;
		end else begin
			case (mem_state)
				STATE_WAIT_REQ: begin
					ack_valid <= 0;
					if (req_valid && !ack_valid) begin
						dvalid <= 1;
						mem_state <= STATE_WAIT_RSP;
						dwrite <= (req_op == OP_SB || req_op == OP_SH || req_op == OP_SW);
						
						case (req_op)
							OP_SB: begin
								dwstb <= (1 << req_addr[1:0]);
								dwdata <= {4{req_data[7:0]}};
							end
							OP_SH: begin
								dwstb <= (3 << req_addr[1:0]);
								dwdata <= {2{req_data[15:0]}};
							end
							OP_SW: begin
								dwstb <= 4'b1111;
								dwdata <= req_data[15:0];
							end
							default: begin
								dwstb <= 4'b0000;
								dwdata <= 32'b0;
							end
						endcase
					end
				end
				STATE_WAIT_RSP: begin
					if (dready) begin
						ack_valid <= 1;
						dvalid <= 0;
						case (req_op)
							OP_LB: begin
								ack_data <= $signed(drdata[7:0]);
							end
							OP_LBU: begin
								ack_data <= drdata[7:0];
							end
							OP_LH: begin
								ack_data <= $signed(drdata[15:0]);
							end
							OP_LHU: begin
								ack_data <= drdata[15:0];
							end
							default /*OP_LW*/: begin
								ack_data <= drdata;
							end
						endcase
						mem_state <= STATE_WAIT_REQ;
					end
				end
			endcase
		end
	end


endmodule


