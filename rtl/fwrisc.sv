/****************************************************************************
 * fwrisc.sv
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
 * Module: fwrisc
 * 
 * Featherweight RISC-V implementation
 */
module fwrisc #(
		parameter ENABLE_COMPRESSED=1,
		parameter ENABLE_MUL=1,
		parameter ENABLE_DEP=1,
		parameter ENABLE_COUNTERS=1
		) (
		input			clock,
		input			reset,
		
		output[31:0]	iaddr,
		input[31:0]		idata,
		output			ivalid,
		input			iready,
		
		output[31:0]	daddr,
		output[31:0]	dwdata,
		input[31:0]		drdata,
		output[3:0]		dstrb,
		output			dwrite,
		output			dvalid,
		input			dready
		);
	
	fwrisc_fetch #(
		.ENABLE_COMPRESSED  (ENABLE_COMPRESSED )
		) u_fetch (
		.clock              (clock             ), 
		.reset              (reset             ), 
		.next_pc            (next_pc           ), 
		.next_pc_seq        (next_pc_seq       ), 
		.iaddr              (iaddr             ), 
		.idata              (idata             ), 
		.ivalid             (ivalid            ), 
		.iready             (iready            ), 
		.fetch_valid        (fetch_valid       ), 
		.decode_ready       (decode_ready      ), 
		.instr              (instr             ), 
		.instr_c            (instr_c           ));
	
	fwrisc_regfile #(
		.ENABLE_COUNTERS  (ENABLE_COUNTERS )
		) u_regfile (
		.clock            (clock           ), 
		.reset            (reset           ), 
		.instr_complete   (instr_complete  ), 
		.ra_raddr         (ra_raddr        ), 
		.ra_rdata         (ra_rdata        ), 
		.rb_raddr         (rb_raddr        ), 
		.rb_rdata         (rb_rdata        ), 
		.rd_waddr         (rd_waddr        ), 
		.rd_wdata         (rd_wdata        ), 
		.rd_wen           (rd_wen          ));
	
	fwrisc_decode #(
		.ENABLE_COMPRESSED  (ENABLE_COMPRESSED )
		) u_decode (
		.clock              (clock             ), 
		.reset              (reset             ), 
		.fetch_valid        (fetch_valid       ), 
		.decode_ready       (decode_ready      ), 
		.instr              (instr             ), 
		.instr_c            (instr_c           ), 
		.ra_raddr           (ra_raddr          ), 
		.ra_rdata           (ra_rdata          ), 
		.rb_raddr           (rb_raddr          ), 
		.rb_rdata           (rb_rdata          ), 
		.decode_valid       (decode_valid      ), 
		.exec_ready         (exec_ready        ), 
		.op_a               (op_a              ), 
		.op_b               (op_b              ), 
		.rd_raddr           (rd_raddr          ), 
		.op_imm             (op_imm            ), 
		.op_ld              (op_ld             ), 
		.op_st              (op_st             ));
	
	fwrisc_exec u_exec (
		.clock         (clock        ), 
		.reset         (reset        ), 
		.decode_valid  (decode_valid ), 
		.exec_ready    (exec_ready   ), 
		.op_a          (op_a         ), 
		.op_b          (op_b         ), 
		.op_c          (op_c         ), 
		.rd_waddr      (rd_waddr     ), 
		.rd_wdata      (rd_wdata     ), 
		.rd_wen        (rd_wen       ));


endmodule


