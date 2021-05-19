/****************************************************************************
 * fwrisc_mem.sv
 *
 * Copyright 2018 Matthew Ballance
 * 
 * Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in
 * writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See
 * the License for the specific language governing
 * permissions and limitations under the License.
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
		input				req_amo, // req_op is coded as an atomic
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
	`include "fwrisc_atomic_op.svh"
	
	parameter[1:0]
		STATE_WAIT_REQ = 2'd0,
		STATE_WAIT_RSP = (STATE_WAIT_REQ + 2'd1)
		;

	reg[1:0]		mem_state;
	
	always @(posedge clock) begin
		if (reset) begin
			ack_valid <= 0;
			ack_data <= {32{1'b0}};
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
						daddr <= req_addr;
						mem_state <= STATE_WAIT_RSP;
						dwrite <= (req_op == OP_SB || req_op == OP_SH || req_op == OP_SW || req_amo);

						if (req_amo) begin
							dwdata <= req_data;
							dwstb <= 4'b1111;
						end else begin
							case (req_op) // synopsys parallel_case full_case
								OP_SB: begin
									case (req_addr[1:0]) // synopsys parallel_case full_case
										2'b00: dwstb <= 4'b0001;
										2'b01: dwstb <= 4'b0010;
										2'b10: dwstb <= 4'b0100;
										2'b11: dwstb <= 4'b1000;
									endcase
									dwdata <= {4{req_data[7:0]}};
								end
								OP_SH: begin
									if (req_addr[1]) begin
										dwstb <= 4'b1100;
									end else begin
										dwstb <= 4'b0011;
									end
									dwdata <= {2{req_data[15:0]}};
								end
								OP_SW: begin
									dwstb <= 4'b1111;
									dwdata <= req_data;
								end
							endcase
						end
					end
				end
				default /*STATE_WAIT_RSP*/: begin
					if (dready) begin
						ack_valid <= 1;
						dvalid <= 0;
						dwrite <= 0;
						dwstb <= 0;
						if (req_amo) begin
							ack_data <= drdata;
						end else begin
							case (req_op) // synopsys parallel_case full_case
								OP_LB: begin
									case (daddr[1:0])
										2'b00: ack_data <= $signed(drdata[7:0]);
										2'b01: ack_data <= $signed(drdata[15:8]);
										2'b10: ack_data <= $signed(drdata[23:16]);
										2'b11: ack_data <= $signed(drdata[31:24]);
									endcase
								end
								OP_LBU: begin
									case (daddr[1:0])
										2'b00: ack_data <= drdata[7:0];
										2'b01: ack_data <= drdata[15:8];
										2'b10: ack_data <= drdata[23:16];
										2'b11: ack_data <= drdata[31:24];
									endcase
								end
								OP_LH:  ack_data <= (daddr[1])?$signed(drdata[31:16]):$signed(drdata[15:0]);
								OP_LHU: ack_data <= (daddr[1])?drdata[31:16]:drdata[15:0];
								OP_LW:  ack_data <= drdata;
							endcase
						end
						mem_state <= STATE_WAIT_REQ;
					end
				end
			endcase
		end
	end
endmodule


