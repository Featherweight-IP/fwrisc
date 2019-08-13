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
	reg [7:0]			cycle_counter = 1;
	wire				cycle_counter_ovf = cycle_counter[7];
	reg [7:0]			instr_counter = 0;
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
	reg[2:0]					alu_op;
	wire[31:0]					alu_out;
	wire						alu_carry;
	wire						alu_eqz;

	wire op_branch_ld_st_arith = (instr[3:0] == 4'b0011);
	wire op_fence     = (instr[3:0] == 4'b1111);
	wire op_ld        = (op_branch_ld_st_arith && instr[6:4] == 3'b000);
	wire op_arith_imm = (op_branch_ld_st_arith && instr[6:4] == 3'b001);
	wire op_arith_reg = (op_branch_ld_st_arith && instr[6:4] == 3'b011);
	wire op_shift_imm = (op_arith_imm && instr[13:12] == 2'b01);
	wire op_shift_reg = (op_arith_reg && instr[13:12] == 2'b01);
	wire op_shift     = (op_shift_imm || op_shift_reg);
	wire op_st        = (op_branch_ld_st_arith && instr[6:4] == 3'b010);
	wire op_ld_st     = (op_ld || op_st);
	wire op_branch    = (op_branch_ld_st_arith && instr[6:4] == 3'b110);
	wire op_jal       = (instr[6:0] == 7'b1101111);
	wire op_jalr      = (instr[6:0] == 7'b1100111);
	wire op_auipc     = (instr[6:0] == 7'b0010111);
	wire op_lui       = (instr[6:0] == 7'b0110111);
	wire op_sys       = (op_branch_ld_st_arith && instr[6:4] == 3'b111);
	wire op_sys_prv   = !(|instr[14:12]);
	wire op_ecall     = (op_sys && op_sys_prv && !instr[28]);
	// Seems the compiler that Zephyr uses encodes eret as 0x10000073
	wire op_eret      = (op_sys && op_sys_prv && instr[28]);
	
	wire op_csr       = (op_sys && |instr[14:12]);
	wire op_csrr_cs   = (op_csr && instr[13]);
	wire op_csrrc     = (op_csr && instr[13:12] == 2'b11);
	wire op_csrrs     = (op_csr && instr[13:12] == 2'b10);

	// Exception signals
	wire						exception;
	reg 						misaligned_addr;

	reg[5:0]		ra_raddr;
	reg[5:0]		rb_raddr;
	wire[31:0]		ra_rdata;
	wire[31:0]		rb_rdata;
	reg[5:0]		rd_waddr;
	reg[31:0]		rd_wdata;
	reg				rd_wen;
	
	// RS1, RS2, and RD are always in the same place
	wire[4:0]		rs1 = instr[19:15];
	wire[4:0]		rs2 = instr[24:20];
	wire[4:0]		rd  = instr[11:7];
	
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
				default /*`FETCH*/: begin
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
	// 0xB00-0xB01 => 0x36 (MCYCLE)
	// 0xB02       => 0x37
	// 0xB80-0xB81 => 0x38 (MCYCLEH)
	// 0xB82       => 0x39 
	// CSR_tmp     => 0x3F (63)
	always @* begin
		case (csr[11:8])
			4'h3: begin
				if (csr[7:4] == 3'b0) begin
					csr_addr = {2'b10, csr[3:0]};
				end else begin
					csr_addr = {3'b101, csr[2:0]};
				end
			end
			4'hb: begin // counters
				if (csr[7]) begin // 0xB8x
					// MCYCLEH, TIMEH, INSTRETH
					csr_addr = {2'd3, 3'b100, csr[1]};
				end else begin
					// MCYCLE, TIME, INSTRET
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
	
	

	
	
	// Comparator signals
	wire[31:0]					comp_op_a = ra_rdata;
	reg[31:0]					comp_op_b;
	reg[1:0]					comp_op;
	wire						comp_out;
	wire						branch_cond;
	
	
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

	reg[31:0]			read_data_wb;
	always @* begin
	case (instr[13:12]) 
		2'b00: begin // LB, LBU
			case (alu_out[1:0]) 
				2'b00: begin
					if (!instr[14] && drdata[7]) begin
						read_data_wb = {{24{1'b1}}, drdata[7:0]};
					end else begin
						read_data_wb = {{24{1'b0}}, drdata[7:0]};
					end
				end
				2'b01: begin
					if (!instr[14] && drdata[15]) begin
						read_data_wb = {{24{1'b1}}, drdata[15:8]};
					end else begin
						read_data_wb = {{24{1'b0}}, drdata[15:8]};
					end
				end 
				2'b10: begin
					if (!instr[14] && drdata[23]) begin
						read_data_wb = {{24{1'b1}}, drdata[23:16]};
					end else begin
						read_data_wb = {{24{1'b0}}, drdata[23:16]};
					end
				end 
				default: /*2'b11*/ begin
					if (!instr[14] && drdata[31]) begin
						read_data_wb = {{24{1'b1}}, drdata[31:24]};
					end else begin
						read_data_wb = {{24{1'b0}}, drdata[31:24]};
					end
				end 
			endcase
		end
		2'b01: begin // LH, LHU
			if (alu_out[1]) begin
				if (!instr[14] && drdata[31]) begin
					read_data_wb = {{16{1'b1}}, drdata[31:16]};
				end else begin
					read_data_wb = {{16{1'b0}}, drdata[31:16]};
				end
			end else begin
				if (!instr[14] && drdata[15]) begin
					read_data_wb = {{16{1'b1}}, drdata[15:0]};
				end else begin
					read_data_wb = {{16{1'b0}}, drdata[15:0]};
				end
			end
		end
		// LW and default
		default: read_data_wb = drdata; 
	endcase	
	end

	reg[3:0] exc_code;
	always @* begin
		if (op_ecall) begin
			exc_code = (instr[20])?4'h3:4'hb;
		end else if (op_ld) begin
			exc_code = 4'h4;
		end else if (op_st) begin
			exc_code = 4'h6;
		end else begin
			exc_code = 4'h0;
		end
			
	end
	
	// Selection of rd_wdata
	// 1+4+7+1+1+1+5 => 20 taps
	// {pc, 2'b0} (EXCEPTION_1)
	// MCAUSE (EXCEPTION_2)
	// 
	always @* begin
		case (state)
			
			`EXCEPTION_1: 
				rd_wdata = {pc, 2'b0}; // Exception PC
				
			`EXCEPTION_2: begin
				// Write the cause
				rd_wdata = {{24{1'b0}}, exc_code};
//				if (op_ecall) begin
//					// EBREAK, ECALL
//					rd_wdata = (instr[20])?32'h0000_0003:32'h0000_000b;
//				end else if (op_ld) begin
//					rd_wdata = 32'h0000_0004; // misaligned load address
//				end else if (op_st) begin
//					rd_wdata = 32'h0000_0006; // misaligned store address
//				end else begin
//					rd_wdata = zero; // instruction address misaligned
//				end				
			end
			
			`MEMR: begin
				rd_wdata = read_data_wb;
//				case (instr[14:12]) 
//					3'b000,3'b100: begin // LB, LBU
//						case (alu_out[1:0]) 
//							2'b00: rd_wdata = (!instr[14] && drdata[7])?{{24{1'b1}}, drdata[7:0]}:{{24{1'b0}}, drdata[7:0]};
//							2'b01: rd_wdata = (!instr[14] && drdata[15])?{{24{1'b1}}, drdata[15:8]}:{{24{1'b0}}, drdata[15:8]};
//							2'b10: rd_wdata = (!instr[14] && drdata[23])?{{24{1'b1}}, drdata[23:16]}:{{24{1'b0}}, drdata[23:16]};
//							default: /*2'b11:*/ rd_wdata = (!instr[14] && drdata[31])?{{24{1'b1}}, drdata[31:24]}:{{24{1'b0}}, drdata[31:24]};
//						endcase
//					end
//					3'b001, 3'b101: begin // LH, LHU
//						if (alu_out[1]) begin
//							rd_wdata = (!instr[14] & drdata[31])?{{16{1'b1}}, drdata[31:16]}:{{16{1'b0}}, drdata[31:16]};
//						end else begin
//							rd_wdata = (!instr[14] & drdata[15])?{{16{1'b1}}, drdata[15:0]}:{{16{1'b0}}, drdata[15:0]};
//						end
//					end
//					// LW and default
//					default: rd_wdata = drdata; 
//				endcase				
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
					// Write badaddr
					if (instr[6:5] == 3'b11 /*op_jal || op_jalr || op_branch*/) begin
						rd_wdata = {alu_out[31:1], 1'b0}; 
					end else begin
						rd_wdata = alu_out; 
					end
				end else if (op_jal || op_jalr) begin
					rd_wdata = {pc_plus4, 2'b0};
				end else if ((op_arith_imm || op_arith_reg) && instr[14:13] == 2'b01) begin
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
	
//	reg[31:0]		imm;
//	always @* begin
//		if (op_ui) begin
//			imm_a = imm_lui;
//		end else if (op_auipc) begin
//			imm_a = auipc_imm_31_12;
//		end else if (op_branch) begin
//			
//	end
//	
	
	always @* begin
	
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
		
		case (state)
			`EXECUTE: begin
				if (op_arith_imm || op_arith_reg) begin
					case (instr[14:12]) 
						3'b000: begin // ADDI, ADD, SUB
							if (op_arith_reg) begin
								alu_op = (instr[30])?`OP_SUB:`OP_ADD;
//								alu_op = (instr[30] || rs1==4)?`OP_SUB:`OP_ADD;
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
	
	
	always @* begin
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
			misaligned_addr = (
					alu_out[1] ||
					!(alu_out >= 'h80000000 && alu_out <= 'h80005a4c)); // the low-bit is always cleared on jump
		end else begin
			misaligned_addr = 0;
		end
	end

	assign exception = (state == `EXECUTE && (op_ecall || misaligned_addr));
	
	wire exec_state = (state == `EXECUTE);
	
	/**
	 * The tracer is used during simulation to inspect operation of the core
	 */
	fwrisc_tracer u_tracer (
		.clock   (clock  			), 
		.reset   (reset  			), 
		.pc      ({pc, 2'b0}		), 
		.instr   (instr  			), 
		.ivalid  (exec_state		), 
		.ra_raddr(ra_raddr			),
		.ra_rdata(ra_rdata			),
		.rb_raddr(rb_raddr			),
		.rb_rdata(rb_rdata			),
		.rd_waddr(rd_waddr			), 
		.rd_wdata(rd_wdata			), 
		.rd_write(rd_wen 			),
		.maddr   (daddr				),
		.mdata   ((dwrite)?dwdata:drdata),
		.mstrb   (dstrb				),
		.mwrite  (dwrite			),
		.mvalid  ((dvalid && dready))
		);
	
endmodule

