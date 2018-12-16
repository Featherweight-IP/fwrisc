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
	
	int unsigned			m_id;
	
	import "DPI-C" context function int unsigned fwrisc_tracer_bfm_register(string path);
	
	initial begin
		$display("fwrisc_tracer_bfm: %m");
		m_id = fwrisc_tracer_bfm_register($sformatf("%m"));
	end

	import "DPI-C" context task fwrisc_tracer_bfm_regwrite(
			int unsigned	id,
			int unsigned	raddr,
			int unsigned	rdata);
	
	always @(posedge clock) begin
		if (rd_write) begin
			fwrisc_tracer_bfm_regwrite(m_id, rd_waddr, rd_wdata);
		end
	end

	import "DPI-C" context task fwrisc_tracer_bfm_exec(
			int unsigned	id,
			int unsigned	addr,
			int unsigned	instr);
			
	always @(posedge clock) begin
		if (ivalid) begin
			fwrisc_tracer_bfm_exec(m_id, pc, instr);
		end
	end
	
	import "DPI-C" context task fwrisc_tracer_bfm_memwrite(
			int unsigned	id,
			int unsigned	addr,
			byte unsigned	mask,
			int unsigned	data);
	always @(posedge clock) begin
		if (mvalid && mwrite) begin
			fwrisc_tracer_bfm_memwrite(m_id, maddr, mstrb, mdata);
		end
	end	

endmodule


