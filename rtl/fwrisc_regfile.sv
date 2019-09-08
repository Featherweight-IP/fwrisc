/****************************************************************************
 * fwrisc_regfile.sv
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
 * Module: fwrisc_regfile
 * 
 * TODO: Add module documentation
 */
module fwrisc_regfile #(
		parameter ENABLE_COUNTERS = 1,
		// Enable Data Execution Protection
		parameter ENABLE_DEP = 1
		) (
		input				clock,
		input				reset,
		input				instr_complete,
		// TODO: 
		input[5:0]			ra_raddr,
		output reg[31:0]	ra_rdata,
		input[5:0]			rb_raddr,
		output reg[31:0]	rb_rdata,
		input[5:0]			rd_waddr,
		input[31:0]			rd_wdata,
		input				rd_wen
		);
	// CSRs
	reg[63:0]			cycle_count;
	reg[63:0]			instr_count;
	reg[31:0]			dep_low_r;
	reg[31:0]			dep_high_r;

	reg[5:0]			ra_raddr_r;
	reg[5:0]			rb_raddr_r;
	reg[31:0]			regs['h3f:0];

`ifdef FORMAL
	initial regs[0] = 0;
`else
	initial begin
		$readmemh("regs.hex", regs);
	end
`endif
	
	always @(posedge clock) begin
		// TODO: determine when cycle_count is being written
		if (0) begin
		end else begin
			cycle_count <= cycle_count + 1;
		end
	end
	
	always @(posedge clock) begin
		// TODO: determine when instr_count is being written
		if (0) begin
		end else if (instr_complete) begin
			instr_count <= instr_count + 1;
		end
	end

	always @(posedge clock) begin
//		ra_raddr_r <= ra_raddr;
//		rb_raddr_r <= rb_raddr;
		// Gate off writing to r0
		if (rd_wen && |rd_waddr) begin
			regs[rd_waddr] <= rd_wdata;
		end
		ra_rdata <= regs[ra_raddr];
		rb_rdata <= regs[rb_raddr];
	end

endmodule


