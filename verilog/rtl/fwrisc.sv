/****************************************************************************
 * fwrisc.sv
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
 * Module: fwrisc
 * 
 * Featherweight RISC-V implementation
 */
module fwrisc #(
		parameter ENABLE_COMPRESSED=1,
		parameter ENABLE_MUL_DIV=1,
		parameter ENABLE_DEP=1,
		parameter ENABLE_COUNTERS=1,
		parameter ENABLE_FULL_GPR=1, // 0 -> RV32E
		parameter CSR_VENDORID=32'h00000000,
		parameter CSR_HARTID=32'h00000000
		) (
		input			clock,
		input			reset,
		
		output[31:0]	iaddr,
		input[31:0]		idata,
		output			ivalid,
		input			iready,
		
		output			dvalid,
		output[31:0]	daddr,
		output[31:0]	dwdata,
		output[3:0]		dwstb,
		output			dwrite,
		input[31:0]		drdata,
		input			dready,
		input			irq,
		
		// RVFI interface signals
		output reg[0:0] 	rvfi_valid,
		output reg[63:0] 	rvfi_order = {64{1'b0}},
		output reg[31:0] 	rvfi_insn,
		output reg[0:0]		rvfi_trap,
		output reg[0:0] 	rvfi_halt,
		output reg[0:0]		rvfi_intr,
		output reg[1:0]		rvfi_mode,
		output reg[1:0]		rvfi_ixl,
		output reg[4:0]		rvfi_rs1_addr,
		output reg[4:0]		rvfi_rs2_addr,
		output reg[31:0]	rvfi_rs1_rdata,
		output reg[31:0] 	rvfi_rs2_rdata,
		output reg[4:0] 	rvfi_rd_addr,
		output reg[31:0] 	rvfi_rd_wdata,
		output reg[31:0]	rvfi_pc_rdata,
		output reg[31:0]	rvfi_pc_wdata,
		output reg[31:0]	rvfi_mem_addr,
		output reg[3:0] 	rvfi_mem_rmask,
		output reg[3:0]		rvfi_mem_wmask,
		output reg[31:0]	rvfi_mem_rdata,
		output reg[31:0]	rvfi_mem_wdata
		);
	
	wire[31:0]				pc;
	wire[31:0]				pc_seq;
	wire					fetch_valid;
	wire					instr_complete;
	wire					trap;
	wire					tret;
	wire[31:0]				instr;
	wire					instr_c;
	wire					int_reset;
	wire					soft_reset_req;
	reg[4:0]				soft_reset_count;
	wire[31:0]				mtvec;
	reg[31:0]				tracer_pc;
	reg[31:0]				tracer_instr;
	wire[31:0]				dep_lo;
	wire[31:0]				dep_hi;

	
	assign int_reset = (reset | soft_reset_count != 0);
	
	always @(posedge clock) begin
		if (reset) begin
			soft_reset_count <= 0;
		end else begin
			if (soft_reset_req) begin
				soft_reset_count <= 5'h1f;
			end else if (soft_reset_count != 0) begin
				soft_reset_count <= soft_reset_count - 1;
			end
		end
	end
	
	wire					decode_complete;

	fwrisc_fetch #(
		.ENABLE_COMPRESSED  (ENABLE_COMPRESSED )
		) u_fetch (
		.clock              (clock             ), 
		.reset              (int_reset         ), 
		.next_pc            (pc                ), 
		.next_pc_seq        (pc_seq            ), 
		.iaddr              (iaddr             ), 
		.idata              (idata             ), 
		.ivalid             (ivalid            ), 
		.iready             (iready            ), 
		.fetch_valid        (fetch_valid       ), 
		.decode_complete    (decode_complete   ), 
		.instr              (instr             ), 
		.instr_c            (instr_c           ));

	wire[31:0]				ra_raddr;
	wire[31:0]				ra_rdata;
	wire[31:0]				rb_raddr;
	wire[31:0]				rb_rdata;
	wire					decode_valid;
	wire[31:0]				op_a;
	wire[31:0]				op_b;
	wire[31:0]				op_c;
	wire[3:0]				op;
	wire[5:0]				rd_raddr;
	wire[4:0]				op_type;
	fwrisc_decode #(
		.ENABLE_COMPRESSED  (ENABLE_COMPRESSED )
		) u_decode (
		.clock              (clock             ), 
		.reset              (int_reset         ), 
		.fetch_valid        (fetch_valid       ), 
		.decode_complete    (decode_complete   ), 
		.instr_i            (instr             ), 
		.instr_c            (instr_c           ), 
		.pc                 (pc                ), 
		.ra_raddr           (ra_raddr          ), 
		.ra_rdata           (ra_rdata          ), 
		.rb_raddr           (rb_raddr          ), 
		.rb_rdata           (rb_rdata          ), 
		.decode_valid       (decode_valid      ), 
		.exec_complete      (instr_complete    ), 
		.op_a               (op_a              ), 
		.op_b               (op_b              ), 
		.op_c               (op_c              ), 
		.op                 (op                ), 
		.rd_raddr           (rd_raddr          ), 
		.op_type            (op_type           ));
	
	always @(posedge clock) begin
		if (reset) begin
			tracer_pc <= 0;
			tracer_instr <= 0;
		end else begin
			if (decode_valid) begin
				tracer_pc <= pc;
				tracer_instr <= instr;
			end
		end
	end

	wire[5:0]				rd_waddr;
	wire[31:0]				rd_wdata;
	wire					rd_wen;
	wire					meie;
	wire					mie;
	fwrisc_exec #(
		.ENABLE_COMPRESSED  (ENABLE_COMPRESSED ),
		.ENABLE_MUL_DIV  (ENABLE_MUL_DIV )
		) u_exec (
		.clock           (clock          ), 
		.reset           (int_reset      ), 
		.decode_valid    (decode_valid   ),
		.instr_complete  (instr_complete ), 
		.trap            (trap           ),
		.tret            (tret           ),
		.instr_c         (instr_c        ), 
		.op_type         (op_type        ), 
		.op_a            (op_a           ), 
		.op_b            (op_b           ), 
		.op              (op             ), 
		.op_c            (op_c           ), 
		.rd              (rd_raddr       ), 
		.rd_waddr        (rd_waddr       ), 
		.rd_wdata        (rd_wdata       ), 
		.rd_wen          (rd_wen         ), 
		.pc              (pc             ), 
		.pc_seq          (pc_seq         ),
		.mtvec           (mtvec          ),
		.dep_lo          (dep_lo         ),
		.dep_hi          (dep_hi         ),
		.dvalid          (dvalid         ),
		.daddr           (daddr          ),
		.dwrite          (dwrite         ),
		.dwdata          (dwdata         ),
		.dwstb           (dwstb          ),
		.drdata          (drdata         ),
		.dready          (dready         ),
		.irq             (irq            ),
		.meie            (meie           ),
		.mie             (mie            )
		);
	
	fwrisc_regfile #(
		.ENABLE_COUNTERS  (ENABLE_COUNTERS ),
		.ENABLE_DEP       (ENABLE_DEP      )
		) u_regfile (
		.clock            (clock              ), 
		.reset            (int_reset          ), 
		.soft_reset_req   (soft_reset_req     ),
		.instr_complete   (instr_complete     ),
		.trap             (trap               ),
		.tret             (tret               ),
		.irq              (irq                ),
		.ra_raddr         (ra_raddr           ), 
		.ra_rdata         (ra_rdata           ), 
		.rb_raddr         (rb_raddr           ), 
		.rb_rdata         (rb_rdata           ), 
		.rd_waddr         (rd_waddr           ), 
		.rd_wdata         (rd_wdata           ), 
		.rd_wen           (rd_wen             ),
		.dep_lo           (dep_lo             ),
		.dep_hi           (dep_hi             ),
		.mtvec            (mtvec              ),
		.meie             (meie               ),
		.mie              (mie                )
		);
	
	fwrisc_tracer u_tracer (
		.clock     (clock                     ), 
		.reset     (reset                     ), 
		.pc        (tracer_pc                 ), 
		.instr     (tracer_instr              ), 
		.ivalid    (instr_complete            ), 
		.ra_raddr  (ra_raddr                  ), 
		.ra_rdata  (ra_rdata                  ), 
		.rb_raddr  (rb_raddr                  ), 
		.rb_rdata  (rb_rdata                  ), 
		.rd_waddr  (rd_waddr                  ), 
		.rd_wdata  (rd_wdata                  ), 
		.rd_write  (rd_wen                    ), 
		.maddr     (daddr                     ), 
		.mdata     ((dwrite)?dwdata:drdata    ), 
		.mstrb     (dwstb                     ), 
		.mwrite    (dwrite                    ), 
		.mvalid    ((dready && dvalid)        ));

	always @(posedge clock) begin
		if (rvfi_valid) begin
			rvfi_order <= rvfi_order + 1;
		end
	end

	// Track whether a non-zero register was written
	reg[31:0] rd_wdata_r;
	always @(posedge clock) begin
		if (reset) begin
			rd_wdata_r <= {32{1'b0}};
		end else begin
			if (instr_complete) begin
				rd_wdata_r <= {32{1'b0}};
			end else begin
				if (rd_wen) begin
					if (|rd_waddr) begin
						rd_wdata_r <= rd_wdata;
					end else begin
						rd_wdata_r <= {32{1'b0}};
					end
				end
			end
		end
	end

	// RVFI connection
	always @(negedge clock) begin
		rvfi_valid <= instr_complete;
		if (instr_complete) begin
			rvfi_insn  <= tracer_instr;
			rvfi_trap  <= 0;
			rvfi_halt  <= 0;
			rvfi_intr  <= 0;
			rvfi_mode  <= 0;
			rvfi_ixl   <= 0;
			rvfi_rs1_addr  <= ra_raddr;
			rvfi_rs2_addr  <= rb_raddr;
			rvfi_rs1_rdata <= ra_rdata;
			rvfi_rs2_rdata <= rb_rdata;
			rvfi_rd_addr   <= rd_waddr;
			rvfi_rd_wdata  <= rd_wdata_r;
			rvfi_pc_rdata  <= tracer_pc;
			rvfi_pc_wdata  <= pc;
			rvfi_mem_addr  <= daddr;
			rvfi_mem_rmask <= 0;
			rvfi_mem_wmask <= 0;
			rvfi_mem_rdata <= drdata;
			rvfi_mem_wdata <= dwdata;
		end
	end
`ifdef FWRISC_FORMAL
`endif /* FWRISC_FORMAL */

endmodule


