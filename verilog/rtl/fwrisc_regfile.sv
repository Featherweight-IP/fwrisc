/****************************************************************************
 * fwrisc_regfile.sv
 * 
 * Copyright 2018-2019 Matthew Ballance
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
 * Module: fwrisc_regfile
 * 
 * TODO: Add module documentation
 */
module fwrisc_regfile #(
		parameter ENABLE_COUNTERS=1,
		// Enable Data Execution Protection
		parameter ENABLE_DEP=1
		) (
		input				clock,
		input				reset,
		output				soft_reset_req,
		input				instr_complete,

		input[5:0]			ra_raddr,
		output reg[31:0]		ra_rdata,
		input[5:0]			rb_raddr,
		output reg[31:0]		rb_rdata,
		input[5:0]			rd_waddr,
		input[31:0]			rd_wdata,
		input				rd_wen,
		
		output[31:0]			dep_lo,
		output[31:0]			dep_hi,
		output[31:0]			mtvec
		);
	
	`include "fwrisc_csr_addr.svh"
	
	// CSRs
	reg[32:0]			cycle_count_lo;
	reg[31:0]			cycle_count_hi;
	reg[32:0]			instr_count_lo;
	reg[31:0]			instr_count_hi;
	reg[31:0]			dep_lo_r;
	reg[31:0]			dep_hi_r;
	// In case we need a writable mtvec
	reg[31:0]			mtvec_r;

	reg[5:0]			ra_raddr_r;
	reg[5:0]			rb_raddr_r;
	reg[31:0]			regs['h1f:0];

	if (ENABLE_DEP) begin
		assign dep_lo = dep_lo_r;
		assign dep_hi = dep_hi_r;
	end else begin
		assign dep_lo = 0;
		assign dep_hi = 0;
	end
	assign mtvec  = mtvec_r;
	
`ifdef FORMAL
	initial regs[0] = 0;
`else
	`ifdef FWRISC_SOFT_CORE
	initial begin
		$readmemh("regs.hex", regs);
	end
	`endif
`endif
	
	// Assert the soft-reset request
	assign soft_reset_req = (rd_wen && rd_waddr == CSR_SOFT_RESET);

	integer reg_i;
`ifdef FW_RESET_ASYNC
	always @(posedge clock or posedge reset) begin
`else
	always @(posedge clock) begin
`endif
		if (reset) begin
			cycle_count_lo <= {33{1'b0}};
			cycle_count_hi <= {32{1'b0}};
			instr_count_lo <= {33{1'b0}};
			instr_count_hi <= {32{1'b0}};
			dep_lo_r <= 0;
			dep_hi_r <= 0;
			mtvec_r <= {32{1'b0}};
			`ifndef FWRISC_SOFT_CORE
			for (reg_i=0; reg_i<'h20; reg_i=reg_i+1) begin
				regs[reg_i] <= {32{1'b0}};
			end
			`endif
		end else begin
			case ({rd_wen, rd_waddr})
				{1'b1, CSR_MCYCLE}: cycle_count_lo <= rd_wdata;
				{1'b1, CSR_MCYCLEH}: cycle_count_hi <= rd_wdata;
				default: begin
					cycle_count_lo <= cycle_count_lo + 1;
					if (cycle_count_lo+1 == 0) begin
						cycle_count_hi <= cycle_count_hi + 1;
					end
				end
			endcase
		
			case ({rd_wen, rd_waddr})
				{1'b1, CSR_MINSTRET}: instr_count_lo <= rd_wdata;
				{1'b1, CSR_MINSTRETH}: instr_count_hi <= rd_wdata;
				default: begin
					if (instr_complete) begin
						instr_count_lo <= instr_count_lo+1;
						if (instr_count_lo+1 == 0) begin
							instr_count_hi <= instr_count_hi + 1;
						end
					end
				end
			endcase
	
			// Once the DEP registers have been written and enabled,
			// they are locked out until the next reset
			if (rd_wen && rd_waddr == CSR_DEP_LO && !dep_lo_r[1]) begin
				dep_lo_r <= rd_wdata;
			end
			if (rd_wen && rd_waddr == CSR_DEP_HI && !dep_hi_r[1]) begin
				dep_hi_r <= rd_wdata;
			end
			if (rd_wen && rd_waddr == CSR_MTVEC) begin
				mtvec_r <= rd_wdata;
			end
		end
	end

	always @(posedge clock) begin
		// Gate off writing to r0 and read-only CSRs
		if (rd_wen) begin
			if (|rd_waddr && rd_waddr[5:3] != 3'b100) begin
				regs[rd_waddr] <= rd_wdata;
			end else begin
				if (rd_waddr != 0) begin
					$display("Warning: skipping write to %0d", rd_waddr);
				end
			end
		end
	end

	always @* begin
		ra_rdata = regs[ra_raddr];
		
		// Only RB is used to access CSRs
		case (rb_raddr)
			CSR_MCYCLE:    rb_rdata = cycle_count_lo[31:0];
			CSR_MCYCLEH:   rb_rdata = cycle_count_hi[63:32];
			CSR_MINSTRET:  rb_rdata = instr_count_lo[31:0];
			CSR_MINSTRETH: rb_rdata = instr_count_hi[63:32];
			// TODO: DEP (?)
			CSR_MTVEC:     rb_rdata = mtvec_r;
			default:       rb_rdata = regs[rb_raddr];
		endcase
	end

endmodule


