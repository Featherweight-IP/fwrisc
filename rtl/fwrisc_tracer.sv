/****************************************************************************
 * fwrisc_tracer.sv
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
 * Module: fwrisc_tracer
 * 
 * Dummy module that provides an attachment site for the
 * monitor BFM
 */
module fwrisc_tracer (
		input			clock,
		input			reset,
		input [31:0]		addr,
		input [31:0]		instr,
		input			ivalid,
		input [5:0]		raddr,
		input [31:0]		rdata,
		input			rwrite,
		input [31:0]		maddr,
		input [31:0]		mdata,
		input [3:0]		mstrb,
		input			mwrite,
		input 			mvalid
		);
	// Empty
	

endmodule


