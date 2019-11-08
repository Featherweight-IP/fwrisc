
`include "fwrisc_mem_defines.svh"


module fwrisc_mem_checker(
		input			clock,
		input			reset,
		/**
		 * Internal bus
		 */
		input				req_valid,
		input[31:0]			req_addr,
		input[3:0]			req_op,
		input[31:0]			req_data,
		input				ack_valid,
		input[31:0]			ack_data,

		/**
		 * External bus
		 */
		input				dvalid,
		input[31:0]			daddr,
		input[31:0]			dwdata,
		input[3:0]			dwstb,
		input				dwrite,
		input[31:0]			drdata,
		input				dready
		);
	
	`include "fwrisc_mem_op.svh"
	
	reg[31:0]				req_addr_r;
	reg[3:0]				req_op_r;
	reg[31:0]				req_data_r;
	reg[1:0]				req_state;
	
	reg[31:0]				daddr_r;
	reg[31:0]				dwdata_r;
	reg[3:0]				dwstb_r;
	reg[31:0]				drdata_r;
	reg[1:0]				drw_state;
	
	always @(posedge clock) begin
		if (reset) begin
			drw_state <= 0;
		end else begin
			case (drw_state) 
				0: begin
					if (dvalid) begin
						daddr_r <= daddr;
						dwdata_r <= dwdata;
						dwstb_r <= dwstb;
						dwrite_r <= dwrite;
						drw_state <= 1;
					end
				end
				1: begin
					if (dready) begin
						drw_state <= 0;
						// Capture the 
						drdata_r <= drdata;
					end
				end
			endcase
		end
	end
	
	always @(posedge clock) begin
		if (reset) begin
			req_addr_r <= 0;
			req_op_r <= 0;
			req_state <= 0;
		end else begin
			case (req_state)
				0: begin
					if (req_valid) begin
						req_addr_r <= req_addr;
						req_op_r <= req_op;
						req_state <= 1;
					end
				end
				
				1: begin
					if (ack_valid) begin
						// Time for checks
						`cover(req_op_r == OP_LB);
						`cover(req_op_r == OP_LBU);
						`cover(req_op_r == OP_LHU);
						`cover(req_op_r == OP_LH);
						`cover(req_op_r == OP_LW);
						`cover(req_op_r == OP_SB);
						`cover(req_op_r == OP_SH);
						`cover(req_op_r == OP_SW);

						// Confirm that we actually performed the right operation
						case (req_op_r)
							OP_LB, OP_LBU, OP_LHU, OP_LH, OP_LW: begin
								`assert(dwrite_r == 0);
							end
							OP_SB, OP_SH, OP_SW: begin
								`assert(dwrite_r == 1);
							end
						endcase
						
						// Check address alignment
						case (req_op_r) 
							OP_LH, OP_LHU, OP_SH: begin
								`assert(daddr_r[0] == 0);
							end
							OP_LW, OP_SW: begin
								`assert(daddr_r[1:0] == 0);
							end
						endcase
					
						if (dwrite_r) begin
							// Check the write strobe
							case (req_op_r) 
								OP_SB: begin
									`assert(dwstb_r == (1 << daddr_r[1:0]));
									`assert(dwdata_r == {4{req_data[7:0]}});
								end
								OP_SH: begin
									`assert(dwstb_r == (3 << daddr_r[1:0]));
									`assert(dwdata_r == {2{req_data[15:0]}});
								end
								OP_SW: begin
									`assert(dwstb_r == 'hF);
									`assert(dwdata_r == req_data);
								end 
							endcase
						end else begin // read
							case (req_op_r)
								OP_LB: begin
									`assert(ack_data == $signed(drdata_r[7:0]));
								end
								OP_LBU: begin
									`assert(ack_data == drdata_r[7:0]);
								end
								OP_LH: begin
									`assert(ack_data == $signed(drdata_r[15:0]));
								end
								OP_LHU: begin
									`assert(ack_data == drdata_r[15:0]);
								end
								OP_LW: begin
									`assert(ack_data == drdata_r);
								end
								default: begin
									`assert(0);
								end
							endcase
						end
						req_state <= 0;
					end
				end
			endcase
		end
	end
	
endmodule
		