/****************************************************************************
 * fwrisc_tracer_bfm.sv
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
 * 
 * 
 ****************************************************************************/

/**
 * Module: fwrisc_tracer_bfm
 * 
 * TODO: Add interface documentation
 */
module fwrisc_tracer_bfm(
		input			clock,
		input			reset,
		input [31:0]	pc,
		input [31:0]	instr,
		input			ivalid,
		// ra, rb
		input [5:0]		ra_raddr,
		input [31:0]	ra_rdata,
		input [5:0]		rb_raddr,
		input [31:0]	rb_rdata,
		// rd
		input [5:0]		rd_waddr,
		input [31:0]	rd_wdata,
		input			rd_write,
		
		input [31:0]	maddr,
		input [31:0]	mdata,
		input [3:0]		mstrb,
		input			mwrite,
		input 			mvalid		
		);
`ifdef UNDEFINED
`ifdef HAVE_UVM
		import uvm_pkg::*;
`endif

	fwrisc_tracer_core u_core(
		.clock(clock), 
		.reset(reset));

	assign u_core.pc = pc;
	assign u_core.instr = instr;
	assign u_core.ivalid = ivalid;
	assign u_core.ra_raddr = ra_raddr;
	assign u_core.ra_rdata = ra_rdata;
	assign u_core.rb_raddr = rb_raddr;
	assign u_core.rb_rdata = rb_rdata;
	assign u_core.rd_waddr = rd_waddr;
	assign u_core.rd_wdata = rd_wdata;
	assign u_core.rd_write = rd_write;
	assign u_core.maddr = maddr;
	assign u_core.mdata = mdata;
	assign u_core.mstrb = mstrb;
	assign u_core.mwrite = mwrite;
	assign u_core.mvalid = mvalid;

`ifdef HAVE_UVM
	initial begin
		uvm_config_db #(virtual fwrisc_tracer_core)::set(
				uvm_top, "", "tracer", u_core);
	end
`endif
`endif
endmodule

`ifdef UNDEFINED
interface fwrisc_tracer_core(
	input		clock,
	input		reset);

wire [31:0]		pc;
wire [31:0]		instr;
wire			ivalid;
// ra, rb
wire [5:0]		ra_raddr;
wire [31:0]		ra_rdata;
wire [5:0]		rb_raddr;
wire [31:0]		rb_rdata;
// rd
wire [5:0]		rd_waddr;
wire [31:0]		rd_wdata;
wire			rd_write;

wire [31:0]		maddr;
wire [31:0]		mdata;
wire [3:0]		mstrb;
wire			mwrite;
wire 			mvalid;
// 
bit[31:0]		regs[63:0];
bit			reg_write[63:0];
bit[31:0]		last_instr;

// By default, just trace the target of jump/call instructions
`ifdef MINIMIZE_COMM
bit				trace_all_instr = 0;
`else
bit				trace_all_instr = 1;
`endif

// By default, register accesses are queried
`ifdef MINIMIZE_COMM
bit				trace_reg_writes = 0;
`else
bit				trace_reg_writes = 1;
`endif

	task fwrisc_tracer_bfm_dumpregs();
		$display("dumpregs");
		foreach (reg_write[i]) begin
			$display("   reg_write[%0d]=%0d", i, reg_write[i]);
			if (reg_write[i]) begin
				regwrite(i, regs[i]);
			end
		end
	endtask

`include "fwrisc_tracer_bfm_api.svh"

initial begin
	foreach (reg_write[i]) begin
		reg_write[i] = 0;
	end
end

	always @(posedge clock) begin
		if (rd_write) begin
			$display("regwrite %d <= 'h%08h", rd_waddr, rd_wdata);
			if (trace_reg_writes) begin
				regwrite(rd_waddr, rd_wdata);
			end
			regs[rd_waddr] <= rd_wdata;
			reg_write[rd_waddr] <= 1;
		end
	end

	always @(posedge clock) begin
		if (ivalid) begin
			last_instr <= instr;
			
			if (trace_all_instr ||
					last_instr[6:0] == 7'b1101111 || // jal
					last_instr[6:0] == 7'b1100111    // jalr
					) begin
				exec(pc, instr);
			end
		end
	end

	always @(posedge clock) begin
		if (mvalid && mwrite) begin
			memwrite(maddr, mstrb, mdata);
		end
	end	

endinterface
`endif


