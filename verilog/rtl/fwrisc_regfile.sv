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
		parameter 		ENABLE_COUNTERS=1,
		// Enable Data Execution Protection
		parameter 		ENABLE_DEP=0,
		parameter               RV32E=0,
		parameter[31:0]		VENDORID=0,
		parameter[31:0]		ARCHID=0,
		parameter[31:0]		IMPID=0,
		parameter[31:0]		HARTID=0,
		parameter[31:0]		ISA=0
		) (
		input					clock,
		input					reset,
		output					soft_reset_req,
		input					instr_complete,
		input					trap,
		input					tret,
		input					irq,

		input[5:0]				ra_raddr,
		output reg[31:0]		ra_rdata,
		input[5:0]				rb_raddr,
		output reg[31:0]		rb_rdata,
		input[5:0]				rd_waddr,
		input[31:0]				rd_wdata,
		input					rd_wen,
		
		output[31:0]			dep_lo,
		output[31:0]			dep_hi,
		output[31:0]			mtvec,
		output reg				meie,
		output reg				mie
		);
	
	`include "fwrisc_csr_addr.svh"
	
	// CSRs
	reg[63:0]			cycle_count;
	reg[63:0]			instr_count;
	reg[31:0]			dep_lo_r;
	reg[31:0]			dep_hi_r;
	// In case we need a writable mtvec
	reg[31:0]			mtvec_r;
	reg[31:0]			mscratch;
	reg[31:0]			mepc;
	reg[3:0]			mcause_r;
	reg					mcause_int_r;

	localparam N_REGS  = (RV32E)?15:31;
	localparam RA_BITS = (RV32E)?4:5;

	reg[31:0]			regs[N_REGS-1:0];

	generate
	if (ENABLE_DEP) begin
		assign dep_lo = dep_lo_r;
		assign dep_hi = dep_hi_r;
	end else begin
		assign dep_lo = 0;
		assign dep_hi = 0;
	end
	endgenerate
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
	
	reg mpie;
	
	// Assert the soft-reset request
	assign soft_reset_req = (rd_wen && rd_waddr == CSR_SOFT_RESET);

	integer reg_i;
	always @(posedge clock) begin
		if (reset) begin
			cycle_count <= 0;
			instr_count <= 0;
			dep_lo_r <= 0;
			dep_hi_r <= 0;
			mscratch <= {32{1'b0}};
			mepc <= {32{1'b0}};
			mtvec_r <= {32{1'b0}};
			meie <= 1'b0; // TODO: Should be default 0?
			mie <= 1'b1; 
			mpie <= 1'b0;
			mcause_r <= {4{1'b0}};
			mcause_int_r <= 1'b0;
			// TODO: this doesn't synthesize
			`ifndef FWRISC_SOFT_CORE
			/*
			for (reg_i=0; reg_i<N_REGS; reg_i=reg_i+1) begin
				regs[reg_i] <= {32{1'b0}};
			end
			 */
			`endif
		end else begin
			if (ENABLE_COUNTERS) begin		
			case ({rd_wen, rd_waddr})
				{1'b1, CSR_MCYCLE}: cycle_count <= {cycle_count[63:32], rd_wdata};
				{1'b1, CSR_MCYCLEH}: cycle_count <= {rd_wdata, cycle_count[31:0]};
				default: cycle_count <= cycle_count + 1;
			endcase
			end

			if (ENABLE_COUNTERS) begin		
			case ({rd_wen, rd_waddr})
				{1'b1, CSR_MINSTRET}: instr_count <= {instr_count[63:32], rd_wdata};
				{1'b1, CSR_MINSTRETH}: instr_count <= {rd_wdata, instr_count[31:0]};
				default: instr_count <= (instr_complete)?(instr_count + 1):instr_count;
			endcase
			end
		
			if (trap) begin
				mpie <= mie;
				mie <= 1'b0;
			end
			if (tret) begin
				mie <= mpie;
				mpie <= 1'b0;
			end
				
	
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
			if (rd_wen && rd_waddr == CSR_MIE) begin
				meie <= rd_wdata[11];
			end
			if (rd_wen && rd_waddr == CSR_MSTATUS) begin
				mie <= rd_wdata[3];
				mpie <= rd_wdata[7];
			end
			if (rd_wen && rd_waddr == CSR_MSCRATCH) begin
				mscratch <= rd_wdata;
			end
			if (rd_wen && rd_waddr == CSR_MEPC) begin
				mepc <= rd_wdata;
			end
		end
	end

	always @(posedge clock) begin
		// Gate off writing to r0 and read-only CSRs
		if (rd_wen) begin
			if (|rd_waddr /*&& rd_waddr[5:4] == 2'b00*/) begin
				if (rd_waddr[5] == 0) begin
					regs[~rd_waddr[RA_BITS-1:0]] <= rd_wdata;
				end
			end else begin
				if (rd_waddr != 0) begin
					$display("Warning: skipping write to %0d", rd_waddr);
				end
			end
		end

		case (ra_raddr) 
			6'b0:          ra_rdata <= {32{1'b0}};
			CSR_MVENDORID: ra_rdata <= VENDORID;
			CSR_MARCHID:   ra_rdata <= ARCHID;
			CSR_MIMPID:    ra_rdata <= IMPID;
			CSR_MHARTID:   ra_rdata <= HARTID;
			CSR_MISA:      ra_rdata <= {2'b01, ISA[29:0]};
			CSR_MIE:       ra_rdata <= {20'b0, meie, 11'b0};
			CSR_MCYCLE:    ra_rdata <= (ENABLE_COUNTERS)?cycle_count[31:0]:{32{1'b0}};
			CSR_MCYCLEH:   ra_rdata <= (ENABLE_COUNTERS)?cycle_count[63:32]:{32{1'b0}};
			CSR_MINSTRET:  ra_rdata <= (ENABLE_COUNTERS)?instr_count[31:0]:{32{1'b0}};
			CSR_MINSTRETH: ra_rdata <= (ENABLE_COUNTERS)?instr_count[63:32]:{32{1'b0}};
			// TODO: DEP (?)
			CSR_MTVEC:     ra_rdata <= mtvec_r;
			CSR_MSCRATCH:  ra_rdata <= mscratch;
			CSR_MEPC:      ra_rdata <= mepc;
			CSR_MIP:       ra_rdata <= {20'b0, irq, 11'b0};
			default:       ra_rdata <= regs[~ra_raddr[RA_BITS-1:0]];
		endcase
		
		// Only RB is used to access CSRs
		case (rb_raddr)
			0:             rb_rdata <= {32{1'b0}};
			CSR_MVENDORID: rb_rdata <= VENDORID;
			CSR_MARCHID:   rb_rdata <= ARCHID;
			CSR_MIMPID:    rb_rdata <= IMPID;
			CSR_MHARTID:   rb_rdata <= HARTID;
			CSR_MISA:      rb_rdata <= {2'b01, ISA[29:0]};
			CSR_MIE:       rb_rdata <= {20'b0, meie, 11'b0};
			CSR_MSTATUS:   rb_rdata <= {{24{1'b0}}, mpie, {3{1'b0}}, mie, {3{1'b0}}};
			CSR_MCYCLE:    rb_rdata <= (ENABLE_COUNTERS)?cycle_count[31:0]:{32{1'b0}};
			CSR_MCYCLEH:   rb_rdata <= (ENABLE_COUNTERS)?cycle_count[63:32]:{32{1'b0}};
			CSR_MINSTRET:  rb_rdata <= (ENABLE_COUNTERS)?instr_count[31:0]:{32{1'b0}};
			CSR_MINSTRETH: rb_rdata <= (ENABLE_COUNTERS)?instr_count[63:32]:{32{1'b0}};
			// TODO: DEP (?)
			CSR_MTVEC:     rb_rdata <= mtvec_r;
			CSR_MSCRATCH:  rb_rdata <= mscratch;
			CSR_MEPC:      rb_rdata <= mepc;
			CSR_MCAUSE:    rb_rdata <= {mcause_int_r, {27{1'b0}}, mcause_r};
			CSR_MIP:       rb_rdata <= {20'b0, irq, 11'b0};
			default:       rb_rdata <= regs[~rb_raddr[RA_BITS-1:0]];
		endcase
	end

endmodule


