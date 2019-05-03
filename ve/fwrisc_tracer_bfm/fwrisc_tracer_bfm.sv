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
endmodule

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

`include "fwrisc_tracer_bfm_api.svh"

	always @(posedge clock) begin
		if (rd_write) begin
			regwrite(rd_waddr, rd_wdata);
		end
	end

	always @(posedge clock) begin
		if (ivalid) begin
			exec(pc, instr);
		end
	end

	always @(posedge clock) begin
		if (mvalid && mwrite) begin
			memwrite(maddr, mstrb, mdata);
		end
	end	

endinterface


