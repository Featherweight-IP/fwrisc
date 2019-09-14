
`include "fwrisc_mem_defines.svh"


module fwrisc_mem_test(
		input				clock,
		input				reset,
		output reg			req_valid,
		output reg[31:0]	req_addr,
		output reg[3:0]		req_op,
		output reg[31:0]	req_data,
		input				ack_valid,
		
		// Memory interface
		input				dvalid,
		output reg[31:0]	drdata,
		output reg			dready
		);
	
	`include "fwrisc_mem_op.svh"
	
	wire[31:0]				drdata_w;
	wire[3:0]				dwait_w;
	reg[3:0]				dwait;
	reg[1:0]				dstate;
	reg[3:0]				op_r;
	reg[1:0]				addr_low;
	
	// Manage the read state
	always @(posedge clock) begin
		if (reset) begin
			dstate <= 0;
			dready <= 0;
		end else begin
			case (dstate) 
				0: begin
					dready <= 0;
					if (dvalid) begin
						dwait <= dwait_w;
						dstate <= 1;
					end
				end
				1: begin
					if (dwait == 0) begin
						dready <= 1;
						dstate <= 2;
					end else begin
						dwait <= dwait - 1;
					end
				end
				2: begin
					dstate <= 0;
					dready <= 1;
				end
			endcase
		end
	end

	reg state = 0;
	always @(posedge clock) begin
		if (reset) begin
			state <= 0;
			req_valid <= 0;
			req_addr <= 0;
			req_op <= 0;
			req_data <= 0;
		end else begin
			case (state)
				0: begin
					req_valid <= 1;
					case (op_r % OP_NUM_MEM)
						OP_LB, OP_LBU, OP_SB: begin
							`cover(addr_low[1:0] == 0);
							`cover(addr_low[1:0] == 1);
							`cover(addr_low[1:0] == 2);
							`cover(addr_low[1:0] == 3);
							req_addr[1:0] <= addr_low;
						end
						OP_LH, OP_LHU, SH: begin
							`cover(addr_low[0] == 0);
							`cover(addr_low[0] == 1);
							req_addr[0] <= 0;
							req_addr[1] <= addr_low[0];
						end
						OP_LW, OP_SW: begin
							req_addr[1:0] <= 0;
						end
					endcase
					req_addr <= 0;
					req_op <= (op_r % OP_NUM_MEM);
					req_data <= 0;
					state <= 1;
				end
				
				1: begin
					if (ack_valid) begin
						`cover(req_op == OP_LB);
						`cover(req_op == OP_LH);
						`cover(req_op == OP_LBU);
						`cover(req_op == OP_LHU);
						`cover(req_op == OP_LW);
						`cover(req_op == OP_SB);
						`cover(req_op == OP_SH);
						`cover(req_op == OP_SW);
						req_valid <= 0;
						state <= 0;
					end
				end
					
			endcase
		end
	end
	

endmodule