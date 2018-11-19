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
`include "fwrisc_defines.vh"


/**
 * Module: fwrisc
 * 
 * TODO: Add module documentation
 */
module fwrisc (
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

	reg[31:0]			instr;
	
	
	reg[3:0]			state;
	reg[31:2]			pc;
	reg[4:0]			shift_amt;
	wire[31:2]			pc_plus4;
	reg[31:2]			pc_next;
	
	assign pc_plus4 = (pc + 1'b1);

	assign iaddr = {pc, 2'b0};
	assign ivalid = (state == `FETCH && !reset);

	/****************************************************************
	 * Instruction and Cycle counters
	 ****************************************************************/
	reg [7:0]			cycle_counter;
	wire				cycle_counter_ovf = cycle_counter[7];
	reg [7:0]			instr_counter;
	always @(posedge clock) begin
		if (reset || state == `CYCLE_COUNT_UPDATE_1) begin
			cycle_counter <= 1;
		end else begin
			cycle_counter <= cycle_counter + 1;
		end
	end
	
	always @(posedge clock) begin
		if (reset || state == `INSTR_COUNT_UPDATE_1) begin
			instr_counter <= 0;
		end else if (state == `EXECUTE) begin
			instr_counter <= instr_counter + 1;
		end
	end
	
	// ALU signals
	reg[31:0]					alu_op_a;
	reg[31:0]					alu_op_b;
	reg[4:0]					alu_op;
	wire[31:0]					alu_out;
	wire						alu_carry;
	wire						alu_eqz;
	
	always @(posedge clock) begin
		if (reset) begin
			state <= `FETCH;
			instr <= 0;
			pc <= (32'h8000_0000 >> 2);
		end else begin
			if (ivalid && iready) begin
				instr <= idata;
			end
			
			case (state)
				`FETCH: begin
					if (ivalid && iready) begin
						state <= `DECODE;
						instr <= idata;
					end
				end
				
				`DECODE: begin
					// NOP: wait for decode to occur
					if (op_csr) begin
						state <= `CSR_1;
					end else if (op_shift) begin
						state <= `SHIFT_1;
					end else begin
						state <= `EXECUTE;
					end
				end
				
				`CSR_1: begin
					state <= `CSR_2;
				end
				
				`CSR_2: begin
					state <= `EXECUTE;
				end
				
				`EXECUTE: begin
					if (exception) begin
						// Exception Handling:
						// - Write the address to MTVAL in EXECUTE
						// - Write the cause to MTCAUSE in EXECEPTION_1
						// - Jump to FETCH to execute vector address
						state <= `EXCEPTION_1;
					end else if (op_ld) begin
						state <= `MEMR;
					end else if (op_st) begin
						state <= `MEMW;
					end else if (cycle_counter_ovf) begin
						pc <= pc_next;
						state <= `CYCLE_COUNT_UPDATE_1;
					end else begin
						pc <= pc_next;
						state <= `FETCH;
					end
				end
				
				`MEMW, `MEMR: begin
					if (dvalid && dready) begin
						pc <= pc_next;
						// Steal a few cycles to update the cycle counter
						if (cycle_counter[7]) begin
							state <= `CYCLE_COUNT_UPDATE_1;
						end else begin
							state <= `FETCH;
						end
					end
				end
			
				// Capture the fault address
				`EXCEPTION_1: begin
					state <= `EXCEPTION_2;
				end
			
				// Capture the EPC
				`EXCEPTION_2: begin
					// Contains MTVEC
					pc <= ra_rdata[31:2];
					state <= `FETCH;
				end
			
				// Latch the shift amount into the shift_amt register
				`SHIFT_1: begin
					if (op_shift_reg) begin
						shift_amt <= (rb_rdata[4:0] - 1'b1);
						if (|rb_rdata[4:0]) begin
							state <= `SHIFT_2;
						end else begin
							state <= `EXECUTE;
						end
					end else begin
						shift_amt <= (rs2 - 1'b1);
						if (|rs2) begin
							state <= `SHIFT_2;
						end else begin
							state <= `EXECUTE;
						end
					end
				end
				
				`SHIFT_2: begin
					// Shift 
					if (|shift_amt) begin
						shift_amt <= shift_amt - 1;
					end else begin
						state <= `EXECUTE;
					end
				end
			
				/**
				 * Write the cycle count to CSR_tmp. 
				 * Setup a read of CSR_tmp and the counter CSR
				 */
				`CYCLE_COUNT_UPDATE_1: begin
					state <= `CYCLE_COUNT_UPDATE_2;
				end
			
				/**
				 * Add CSR_tmp and the counter CSR
				 */
				`CYCLE_COUNT_UPDATE_2: begin
					state <= `INSTR_COUNT_UPDATE_1;
				end
				
				`INSTR_COUNT_UPDATE_1: begin
					state <= `FETCH;
				end
				
			endcase
		end
	end
	

	wire op_branch_ld_st_arith = (instr[3:0] == 4'b0011);
	wire op_fence     = (instr[3:0] == 4'b1111);
	wire op_ld        = (op_branch_ld_st_arith && instr[6:4] == 3'b000);
	wire op_arith_imm = (op_branch_ld_st_arith && instr[6:4] == 3'b001);
	wire op_shift_imm = (op_arith_imm && instr[13:12] == 2'b01);
	wire op_shift_reg = (op_arith_reg && instr[13:12] == 2'b01);
	wire op_shift     = (op_shift_imm || op_shift_reg);
	wire op_st        = (op_branch_ld_st_arith && instr[6:4] == 3'b010);
	wire op_ld_st     = (op_ld || op_st);
	wire op_arith_reg = (op_branch_ld_st_arith && instr[6:4] == 3'b011);
	wire op_branch    = (op_branch_ld_st_arith && instr[6:4] == 3'b110);
	wire op_jal       = (instr[6:0] == 7'b1101111);
	wire op_jalr      = (instr[6:0] == 7'b1100111);
	wire op_auipc     = (instr[6:0] == 7'b0010111);
	wire op_lui       = (instr[6:0] == 7'b0110111);
	wire op_sys       = (op_branch_ld_st_arith && instr[6:4] == 3'b111);
	wire op_sys_prv   = !(|instr[14:12]);
//	wire op_ecall     = (op_sys && op_sys_prv && instr[24:21] == 4'b0000);
	wire op_ecall     = (op_sys && op_sys_prv && !instr[28]);
	// Seems the compiler that Zephyr uses encodes eret as 0x10000073
//	wire op_eret      = (op_sys && op_sys_prv && instr[24:20] == 5'b00010);
	wire op_eret      = (op_sys && op_sys_prv && instr[28]);
	
	wire op_csr       = (op_sys && |instr[14:12]);
	wire op_csrr_cs   = (op_csr && instr[13]);
	wire op_csrrc     = (op_csr && instr[13:12] == 2'b11);
	wire op_csrrs     = (op_csr && instr[13:12] == 2'b10);
	wire [11:0]	csr   = instr[31:20];
	reg [5:0]	csr_addr;

	wire[5:0] CSR_MTVEC   = 6'h25;
	wire[5:0] CSR_MEPC    = 6'h29;
	wire[5:0] CSR_MCAUSE  = 6'h2A;
	wire[5:0] CSR_MTVAL   = 6'h2B;
	wire[5:0] CSR_MCYCLE  = 6'h36;
	wire[5:0] CSR_MINSTR  = 6'h37;
	wire[5:0] CSR_MCYCLEH = 6'h38;
	wire[5:0] CSR_MINSTRH = 6'h39;
	wire[5:0] CSR_tmp     = 6'h3F;
	// 0x300-0x306 => 0x20-0x26 (32-38)
	// 0x340-0x344 => 0x28-0x2C (40-44)
	// 0xF11-0xF14 => 0x31-0x34 (49-52)
	// 0xB00       => 0x36
	// 0xB02       => 0x37
	// 0xB80       => 0x38
	// 0xB82       => 0x39
	// CSR_tmp     => 0x3F (63)
	always @* begin
		case (csr[11:8])
			4'h3: begin
				if (csr[7:4] == 0) begin
					csr_addr = {2'b10, csr[3:0]};
				end else begin
					csr_addr = {3'b101, csr[2:0]};
				end
			end
			4'hb: begin // counters
				if (csr[7]) begin // 0xB8x
					csr_addr = {2'd3, 3'b100, csr[1]};
				end else begin
					csr_addr = {2'd3, 3'b011, csr[1]};
				end
			end
			default: begin // 4'hf
				csr_addr = {2'b11, csr[3:0]};
			end
		endcase
	end
	
	wire[31:0]      jal_off = (instr[31])?{{21{1'b1}}, instr[31], instr[19:12], instr[20], instr[30:21],1'b0}:
											{{21{1'b0}}, instr[31], instr[19:12], instr[20], instr[30:21],1'b0};
	wire[31:0]      auipc_imm_31_12 = {instr[31:12], {12{1'b0}}};
	wire[31:0]      imm_11_0 = (instr[31])?{{22{1'b1}}, instr[31:20]}:{{22{1'b0}}, instr[31:20]};
	wire[31:0]      st_imm_11_0 = (instr[31])?
		{{22{1'b1}}, instr[31:25], instr[11:7]}:
		{{22{1'b0}}, instr[31:25], instr[11:7]};
	
	wire[31:0]      imm_lui = {instr[31:12], 12'h000};
	wire[31:0]		imm_branch = (instr[31])?
		{{19{1'b1}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}:
		{{19{1'b0}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
	wire[31:0]		zero = 32'h00000000;
	
	// RS1, RS2, and RD are always in the same place
	wire[4:0]		rs1 = instr[19:15];
	wire[4:0]		rs2 = instr[24:20];
	wire[4:0]		rd  = instr[11:7];
	

	reg[5:0]		ra_raddr;
	reg[5:0]		rb_raddr;
	wire[31:0]		ra_rdata;
	wire[31:0]		rb_rdata;
	reg[5:0]		rd_waddr;
	reg[31:0]		rd_wdata;
	reg				rd_wen;
	
	
	// Comparator signals
	wire[31:0]					comp_op_a = ra_rdata;
	reg[31:0]					comp_op_b;
	reg[4:0]					comp_op;
	wire						comp_out;
	wire						branch_cond;
	
	// Exception signals
	reg							exception;
	reg 						misaligned_addr;
	
	fwrisc_comparator u_comp (
		.clock  (clock 		), 
		.reset  (reset 		), 
		.in_a   (comp_op_a  ), 
		.in_b   (comp_op_b  ), 
		.op     (comp_op    ), 
		.out    (comp_out   ));
	
	always @* begin
		if (op_arith_imm) begin
			comp_op_b = imm_11_0;
		end else begin
			comp_op_b = rb_rdata;
		end
		if (op_arith_imm || op_arith_reg) begin
			if (instr[14:12] == 3'b010) begin
				comp_op = `COMPARE_LT;  // SLT, SLTI
			end else begin
				comp_op = `COMPARE_LTU; // SLTU, SLTUI
			end
		end else begin
			case (instr[14:13]) 
				2'b00: comp_op = `COMPARE_EQ;  // BEQ, BNE
				2'b10: comp_op = `COMPARE_LT;  // BLT, BGE
				default: /*2'b11: */comp_op = `COMPARE_LTU; // BLTU BGEU
			endcase
		end
	end
	assign branch_cond = (instr[12])?!comp_out:comp_out;

	/****************************************************************
	 * Selection of ra_raddr, rb_raddr, and rd_waddr
	 ****************************************************************/
	always @* begin
		case (state)
			`DECODE: begin
				if (op_csr) begin
					ra_raddr = rs1;
					if (op_csrrc) begin
						rb_raddr = csr_addr;
					end else begin
						rb_raddr = zero;
					end
					rd_waddr = 0;
				end else if (op_eret) begin
					// ERET sets up 
					ra_raddr = CSR_MEPC;
					rb_raddr = zero;
					rd_waddr = zero;
				end else begin
					// Normal instructions setup read during DECODE
					ra_raddr = rs1;
					rb_raddr = rs2;
					rd_waddr = rd;					
				end
			end
				
			`CSR_1: begin
				ra_raddr = csr_addr; // CSR
				rb_raddr = zero;
				rd_waddr = CSR_tmp; // write RS1 to CSR_tmp
			end
				
			`CSR_2: begin
				ra_raddr = CSR_tmp;
				if (op_csrrc || op_csrrs) begin
					rb_raddr = csr_addr;
				end else begin
					rb_raddr = zero;
				end				
				rd_waddr = rd;
			end
			
			`EXCEPTION_1: begin
				ra_raddr = CSR_MTVEC;
				rb_raddr = zero;
				rd_waddr = CSR_MEPC;
			end
			
			`EXCEPTION_2: begin
				ra_raddr = zero;
				rb_raddr = zero;
				rd_waddr = CSR_MCAUSE; // Need to write the cause
			end
			
			`SHIFT_1, `SHIFT_2: begin
				// rs1 has been read as ra_rdata
				// write to CSR_tmp
				ra_raddr = CSR_tmp;
				rb_raddr = zero;
				rd_waddr = CSR_tmp;
			end
			
			`CYCLE_COUNT_UPDATE_1: begin
				ra_raddr = CSR_tmp;    // Read CSR_tmp in the next cycle
				rb_raddr = CSR_MCYCLE; // Read MCYCLE in the next cycle
				rd_waddr = CSR_tmp;    // Write the current count to CSR_tmp
			end
			
			`CYCLE_COUNT_UPDATE_2: begin
				ra_raddr = zero;  // Temp
				rb_raddr = CSR_MINSTR;  // Setup a read for the next cycle
				rd_waddr = CSR_MCYCLE; // Write back the new count
			end
			
			`INSTR_COUNT_UPDATE_1: begin
				ra_raddr = zero;  // Temp
				rb_raddr = zero;  // Temp
				rd_waddr = CSR_MINSTR; // Write back the new count
			end
			
			default: /* EXECUTE, MEMR, MEMW */
				if (exception) begin
					ra_raddr = 0; // Future: PC
					rb_raddr = 0; 
					if (op_ecall) begin
						rd_waddr = zero; // Don't save an exception address on ECALL
					end else begin
						rd_waddr = CSR_MTVAL; 
					end
				end else if (op_csr) begin
					ra_raddr = 0;
					rb_raddr = 0;
					if (op_csrr_cs && |rs1 == 0) begin
						// CSRRC and CSRRS don't modify the CSR is RS1==0
						rd_waddr = zero;
					end else begin
						rd_waddr = csr_addr;
					end
				end else if (op_shift) begin
					ra_raddr = CSR_tmp;
					rb_raddr = zero;
					rd_waddr = rd;
				end else begin
					ra_raddr = rs1; 
					rb_raddr = rs2; 
					rd_waddr = rd;
				end
		endcase
	end
	
	// Selection of rd_wdata
	always @* begin
		case (state)
			
			`EXCEPTION_1: 
				rd_wdata = {pc, 2'b0}; // Exception PC
				
			`EXCEPTION_2: begin
				// Write the cause
				if (op_ecall) begin
					// EBREAK, ECALL
					rd_wdata = (instr[20])?32'h0000_0003:32'h0000_000b;
				end else if (op_ld) begin
					rd_wdata = 32'h0000_0004; // misaligned load address
				end else if (op_st) begin
					rd_wdata = 32'h0000_0006; // misaligned store address
				end else begin
					rd_wdata = zero; // instruction address misaligned
				end				
			end
			
			`MEMR: begin
				case (instr[14:12]) 
					3'b000,3'b100: begin // LB, LBU
						case (alu_out[1:0]) 
							2'b00: rd_wdata = (!instr[14] && drdata[7])?{{24{1'b1}}, drdata[7:0]}:{{24{1'b0}}, drdata[7:0]};
							2'b01: rd_wdata = (!instr[14] && drdata[15])?{{24{1'b1}}, drdata[15:8]}:{{24{1'b0}}, drdata[15:8]};
							2'b10: rd_wdata = (!instr[14] && drdata[23])?{{24{1'b1}}, drdata[23:16]}:{{24{1'b0}}, drdata[23:16]};
							default: /*2'b11:*/ rd_wdata = (!instr[14] && drdata[31])?{{24{1'b1}}, drdata[31:24]}:{{24{1'b0}}, drdata[31:24]};
						endcase
					end
					3'b001, 3'b101: begin // LH, LHU
						if (alu_out[1]) begin
							rd_wdata = (!instr[14] & drdata[31])?{{16{1'b1}}, drdata[31:16]}:{{16{1'b0}}, drdata[31:16]};
						end else begin
							rd_wdata = (!instr[14] & drdata[15])?{{16{1'b1}}, drdata[15:0]}:{{16{1'b0}}, drdata[15:0]};
						end
					end
					// LW and default
					default: rd_wdata = drdata; 
				endcase				
			end
			
			`CYCLE_COUNT_UPDATE_1: begin
				rd_wdata = {24'b0, cycle_counter};
			end
			
			`CYCLE_COUNT_UPDATE_2: begin
				rd_wdata = alu_out;
			end
			
			`SHIFT_1: begin
				rd_wdata = ra_rdata;
			end
			
			default: /*EXECUTE: */ begin
				if (exception) begin
					if (op_jal || op_jalr || op_branch) begin
						rd_wdata = {alu_out[31:1], 1'b0}; 
					end else begin
						rd_wdata = alu_out[31:0]; 
					end
				end else if (op_jal || op_jalr) begin
					rd_wdata = {pc_plus4, 2'b0};
				end else if ((op_arith_imm || op_arith_reg) && instr[14:13] == 2'b01 /* 010,011 */) begin
					// SLT, SLTU, SLTI, SLTUI
					rd_wdata = {{31{1'b0}}, comp_out};
				end else begin
					rd_wdata = alu_out;
				end				
			end			
		endcase
	end

	/****************************************************************
	 * Selection of wd_wen
	 ****************************************************************/
	always @* begin
		case (state)
			`FETCH, `DECODE:
				rd_wen = 0; // TODO:
				
			`EXECUTE:
				rd_wen = ((!op_branch && !op_ld_st) || exception || op_shift) && |rd_waddr;
				
			`MEMR: 
				rd_wen = (|rd_waddr && dready);
				
			`MEMW:
				rd_wen = 0;
				
			default:
				rd_wen = |rd_waddr;
				
		endcase
	end
	
	fwrisc_regfile u_regfile (
		.clock     (clock    ), 
		.reset     (reset    ), 
		.ra_raddr  (ra_raddr ), 
		.ra_rdata  (ra_rdata ), 
		.rb_raddr  (rb_raddr ), 
		.rb_rdata  (rb_rdata ), 
		.rd_waddr  (rd_waddr ), 
		.rd_wdata  (rd_wdata ), 
		.rd_wen    (rd_wen   ));
	
	
	always @* begin
//		if (op_lui) begin
//			alu_op_a = imm_lui;
//		end else if (op_auipc) begin
//			alu_op_a = auipc_imm_31_12;
//		end else if (op_jal) begin
//			alu_op_a = jal_off;
//		end else if (op_branch) begin
//			alu_op_a = imm_branch;
//		end else if (op_csr && instr[14] && (state == CSR_1)) begin // CSR immediate
//			alu_op_a = rs1; // zimm is the same field as rs1
//		end else begin
//			alu_op_a = ra_rdata;
//		end
//		
//		if (op_auipc || op_jal || op_branch) begin
//			alu_op_b = {pc, 2'b0};
//		end else if (op_jalr || op_ld || op_arith_imm) begin
//			alu_op_b = imm_11_0;
//		end else if (op_st) begin
//			alu_op_b = st_imm_11_0; // sign-extended immediate
//		end else if (op_lui || op_shift) begin
//			alu_op_b = zero;
//		end else begin
//			alu_op_b = rb_rdata;
//		end
	
		case (state) 
			`CSR_1: begin
				if (instr[14]) begin
					alu_op_a = rs1;
				end else begin
					alu_op_a = ra_rdata;
				end
			end
			
			`CYCLE_COUNT_UPDATE_2: alu_op_a = ra_rdata;
			
			`INSTR_COUNT_UPDATE_1: alu_op_a = {24'b0, instr_counter};
				
			default: begin
				if (op_lui) begin
					alu_op_a = imm_lui;
				end else if (op_auipc) begin
					alu_op_a = auipc_imm_31_12;
				end else if (op_jal) begin
					alu_op_a = jal_off;
				end else if (op_branch) begin
					alu_op_a = imm_branch;
				end else begin
					alu_op_a = ra_rdata;
				end
			end
		endcase
		
		case (state)
			/* TODO:
			`CYCLE_COUNT_UPDATE_1: begin
				alu_op_b = {24'b0, cycle_counter};
			end
			 */
			
			`CYCLE_COUNT_UPDATE_2, `INSTR_COUNT_UPDATE_1: begin
				alu_op_b = rb_rdata;
			end
			
			default: begin
				if (op_lui) begin
					alu_op_b = zero;
				end else if (op_auipc || op_jal || op_branch) begin
					alu_op_b = {pc, 2'b0};
				end else if (op_jalr || op_ld || (op_arith_imm && !op_shift)) begin
					alu_op_b = imm_11_0;
				end else if (op_st) begin
					alu_op_b = st_imm_11_0;
				end else begin
					alu_op_b = rb_rdata;
				end
			end
		endcase
		
//		if (op_lui) begin
//			alu_op_a = imm_lui;
//			alu_op_b = zero;
//		end else if (op_auipc) begin
//			alu_op_a = auipc_imm_31_12;
//			alu_op_b = {pc, 2'b0};
//		end else if (op_jal) begin
//			alu_op_a = jal_off;
//			alu_op_b = {pc, 2'b0};
//		end else if (op_jalr) begin
//			alu_op_a = ra_rdata;
//			alu_op_b = imm_11_0;
//		end else if (op_shift) begin
//			alu_op_a = ra_rdata;
//			alu_op_b = zero;
//		end else if (op_ld || op_arith_imm) begin
//			alu_op_a = ra_rdata; // rs1
//			alu_op_b = imm_11_0; // sign-extended immediate
//		end else if (op_st) begin
//			alu_op_a = ra_rdata; // rs1
//			alu_op_b = st_imm_11_0; // sign-extended immediate
//		end else if (op_arith_reg) begin
//			alu_op_a = ra_rdata; // rs2
//			alu_op_b = rb_rdata; // rs1
//		end else if (op_branch) begin
//			// For branches, we use branch_immediate
//			alu_op_a = imm_branch;
//			alu_op_b = {pc, 2'b0};
//		end else if (op_csr) begin
//			if (instr[14] && (state == `CSR_1)) begin // CSR immediate
//				alu_op_a = rs1; // zimm is the same field as rs1
//			end else begin
//				alu_op_a = ra_rdata;
//			end
//			alu_op_b = rb_rdata;
//		end else begin
//			alu_op_a = zero;
//			alu_op_b = zero;
//		end
		
		case (state)
			`EXECUTE: begin
				if (op_arith_imm || op_arith_reg) begin
					case (instr[14:12]) 
						3'b000: begin // ADDI, ADD, SUB
							if (op_arith_reg) begin
								alu_op = (instr[30])?`OP_SUB:`OP_ADD;
							end else begin
								alu_op = `OP_ADD;
							end
						end
						3'b100: begin // XOR
							alu_op = `OP_XOR;
						end
						3'b001, 3'b101, 3'b110: begin // SLL, SRA, SRL, OR
							alu_op = `OP_OR;
						end
						default: /*3'b111: */begin // AND
							alu_op = `OP_AND;
						end
					endcase
				end else if (op_csrrc) begin
					alu_op = `OP_XOR;
				end else if (op_sys) begin
					alu_op = `OP_OR;
				end else begin
					alu_op = `OP_ADD;
				end
			end
			
			`CYCLE_COUNT_UPDATE_2, `INSTR_COUNT_UPDATE_1: 
				alu_op = `OP_ADD;
			
			`SHIFT_2:
				alu_op = (instr[14])?
					(instr[30])?`OP_SRA:`OP_SRL:
					`OP_SLL;
			
			`CSR_1: begin
				if (op_csrrc) begin
					alu_op = `OP_AND;
				end else begin
					alu_op = `OP_OR;
				end
			end
			
			`MEMR, `MEMW: alu_op = `OP_ADD;
			
			default: /* DECODE */
				alu_op = `OP_OR;
		endcase
	end
	
	fwrisc_alu u_alu (
		.clock  (clock     ), 
		.reset  (reset     ), 
		.op_a   (alu_op_a  ), 
		.op_b   (alu_op_b  ), 
		.op     (alu_op    ), 
		.out    (alu_out   ),
		.carry	(alu_carry ),
		.eqz	(alu_eqz   ));

	/****************************************************************
	 * pc_next selection
	 ****************************************************************/
	always @* begin : pc_next_sel
//		case ({
//			(op_jal || op_jalr || (op_branch && branch_cond)),
//			(op_eret || exception)})
//			2'b10: pc_next = alu_out[31:2];
//			2'b01: pc_next = ra_rdata[31:2];
//			default: pc_next = pc_plus4;
//		endcase
		
		if (op_jal || op_jalr || (op_branch && branch_cond)) begin
			pc_next = alu_out[31:2];
		end else if (op_eret || exception) begin
			pc_next = ra_rdata[31:2];
		end else begin
			pc_next = pc_plus4;
		end
	end
	
	// Handle data-access control signals
	fwrisc_dbus_if u_dbus_if (
		.clock     (clock    ), 
		.instr     (instr    ),
		.rb_rdata  (rb_rdata ), 
		.alu_out   (alu_out  ), 
		.state     (state    ), 
		.daddr     (daddr    ), 
		.dvalid    (dvalid   ), 
		.dwrite    (dwrite   ), 
		.dwdata    (dwdata   ), 
		.dstrb     (dstrb    ), 
		.dready    (dready   ));
	
//	assign dvalid = (state == MEMR || state == MEMW);
//	assign dwrite = (state == MEMW);
//	assign daddr = {alu_out[31:2], 2'b0}; // Always use the ALU for address
	
	always @* begin
//		case (instr[13:12]) 
//			2'b00: begin // SB
//				dstrb = (1'b1 << alu_out[1:0]);
//				dwdata = {rb_rdata[7:0], rb_rdata[7:0], rb_rdata[7:0], rb_rdata[7:0]};
//			end
//			2'b01: begin // SH
//				dstrb = (2'b11 << {alu_out[1], 1'b0});
//				dwdata = {rb_rdata[15:0], rb_rdata[15:0]};
//			end
//			// SW and default
//			default: begin
//				dstrb = 4'hf;
//				dwdata = rb_rdata; // Write data is always @ rs2
//			end
//		endcase		
	
//		misaligned_addr = (
//				// Check address alignment for loads and stores
//				(op_ld_st && (
//						(instr[13:12] == 2'b01 && alu_out[0]) || (instr[13:12] == 2'b10 && |alu_out[1:0]))) ||
//				// Check address alignment for jumps and branches
//				((op_jal || op_jalr || (op_branch && branch_cond)) && alu_out[1])
//			);
		if (op_st || op_ld) begin
			case (instr[13:12]) 
				2'b00: begin // SB
					misaligned_addr = 0;
				end
				2'b01: begin // SH
					misaligned_addr = op_ld_st && alu_out[0];
				end
				// SW and default
				default: begin
					misaligned_addr = op_ld_st && |alu_out[1:0];
				end
			endcase		
		end else if (op_jal || op_jalr || (op_branch && branch_cond)) begin
			misaligned_addr = alu_out[1]; // the low-bit is always cleared on jump
		end else begin
			misaligned_addr = 0;
		end
	end

	assign exception = (state == `EXECUTE && (op_ecall || misaligned_addr));

	/**
	 * The tracer is used during simulation to inspect operation of the core
	 */
	fwrisc_tracer u_tracer (
		.clock   (clock  			), 
		.reset   (reset  			), 
		.addr    ({pc, 2'b0}		), 
		.instr   (instr  			), 
		.ivalid  ((state == `EXECUTE)), 
		.raddr   (rd_waddr			), 
		.rdata   (rd_wdata			), 
		.rwrite  (rd_wen 			),
		.maddr   (daddr				),
		.mdata   ((dwrite)?dwdata:drdata),
		.mstrb   (dstrb				),
		.mwrite  (dwrite			),
		.mvalid  ((dvalid && dready))
		);
	
endmodule

