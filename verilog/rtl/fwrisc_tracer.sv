/****************************************************************************
 * fwrisc_tracer.sv
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
 * Module: fwrisc_tracer
 * 
 * Dummy module that provides an attachment site for the
 * monitor BFM
 */
module fwrisc_tracer (
		input			clock,
		input			reset,
		input [31:0]	pc,
		input [31:0]	instr,
		// True during execute stage. 
		// Note that write-back will occur at the same time
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
		
		// memory access
		input [31:0]	maddr,
		input [31:0]	mdata,
		input [3:0]		mstrb,
		input			mwrite,
		input 			mvalid
		);

// Instance the implementation module if specified
`ifdef FWRISC_DBG_BFM_MODULE
`FWRISC_DBG_BFM_MODULE u_dbg (
			.clock(			clock),
			.reset(			reset),
			.pc(			pc),
			.instr(	        instr),
				// True during execute stage. 
				// Note that write-back will occur at the same time
			.ivalid(		ivalid),
				// ra, rb
			.ra_raddr(		ra_raddr),
			.ra_rdata(		ra_rdata),
			.rb_raddr(		rb_raddr),
			.rb_rdata(		rb_rdata),
				// rd
			.rd_waddr(		rd_waddr),
			.rd_wdata(		rd_wdata),
			.rd_write(		rd_write),
				// memory access
			.maddr(         maddr),
			.mdata(         mdata),
			.mstrb(         mstrb),
			.mwrite(		mwrite),
			.mvalid(		mvalid)
			);
`endif

endmodule


