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
	reg[3:0]					alu_op;
	wire[31:0]					alu_out;
	reg[31:0]					alu_out_r;
	wire						alu_carry;
	wire						alu_eqz;
	
	reg[31:0]					mds_op_a;
	reg[31:0]					mds_op_b;
	reg[3:0]					mds_op;
	reg							mds_in_valid;
	wire[31:0]					mds_out;
	wire						mds_out_valid;

	// Note: Added to improve timing
	always @(posedge clock) begin
		if (reset) begin
			alu_out_r <= alu_out;
		end else begin
			if (state == `EXECUTE) begin
				alu_out_r <= alu_out;
			end
		end
	end

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
	wire op_jal       = (instr[6:2] == 7'b11011);
	wire op_jalr      = (instr[6:2] == 7'b11001);
	wire op_auipc     = (instr[6:2] == 7'b00101);
	wire op_lui       = (instr[6:2] == 7'b01101);
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
			
			case (state) // synthesis parallel_case
				default /*`FETCH*/: begin
					if (ivalid && iready) begin
						state <= `DECODE;
						instr <= idata;
					end
				end
				
				`DECODE: begin
					// NOP: wait for decode to occur
					case ({op_csr, op_shift})
						2'b10: state <= `CSR_1;
						2'b01: state <= `MDS_WAIT;
						default: state <= `EXECUTE;
					endcase
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
					end else begin
						case ({op_ld, op_st})
							2'b10: state <= `MEMR;
							2'b01: state <= `MEMW;
							default: begin
								pc <= pc_next;
								if (cycle_counter_ovf) begin
									state <= `CYCLE_COUNT_UPDATE_1;
								end else begin
									state <= `FETCH;
								end
							end
						endcase
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
				`MDS_WAIT: begin
					if (mds_out_valid) begin
						state <= `EXECUTE;
					end
				end
//				`SHIFT_1: begin
//					if (op_shift_reg) begin
//						shift_amt <= (rb_rdata[4:0] - 1'b1);
//						if (|rb_rdata[4:0]) begin
//							state <= `SHIFT_2;
//						end else begin
//							state <= `EXECUTE;
//						end
//					end else begin
//						shift_amt <= (rs2 - 1'b1);
//						if (|rs2) begin
//							state <= `SHIFT_2;
//						end else begin
//							state <= `EXECUTE;
//						end
//					end
//				end
//				
//				`SHIFT_2: begin
//					// Shift 
//					if (|shift_amt) begin
//						shift_amt <= shift_amt - 1;
//					end else begin
//						state <= `EXECUTE;
//					end
//				end
			
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
	// 0xB00-0xB01 => 0x36 (MCYCLE)
	// 0xB02       => 0x37
	// 0xB80-0xB81 => 0x38 (MCYCLEH)
	// 0xB82       => 0x39 
	// 0xF11-0xF14 => 0x31-0x34 (49-52)
	// 0x7C0-0x7C1 => 0x3A-0x3B (53-54) (DEP low/high)
	// CSR_tmp     => 0x3F (63)
	always @* begin
		csr_addr[5] = 1'b1;    // Always in the upper range of the register bank
//		csr_addr[4] = csr[11];
//		csr_addr[3] = csr[3]
		case (csr[11:8]) // synthesis parallel_case
			4'h3: begin
				if (csr[7:4] == 3'b0) begin
					csr_addr[4:0] = {1'b0, csr[3:0]};
				end else begin
					csr_addr[4:0] = {2'b01, csr[2:0]};
				end
			end
			4'h7: begin // DEP shadow registers
				csr_addr[4:0] = {4'b1_110, csr[1], csr[0]};
			end
			4'hb: begin // counters
				if (csr[7]) begin // 0xB8x
					// MCYCLEH, TIMEH, INSTRETH
					csr_addr[4:0] = {1'b1, 3'b100, csr[1]};
				end else begin
					// MCYCLE, TIME, INSTRET
					csr_addr[4:0] = {1'b1, 3'b011, csr[1]};
				end
			end
			default: begin // 4'hf
				csr_addr[4:0] = {1'b1, csr[3:0]};
			end
		endcase		
	end

	// Registers for data execution protection
	wire dep_exception;
	generate 
		if (ENABLE_DEP) begin
			reg[31:0]				dep_low_r;
			reg[31:0]				dep_high_r;
		
			always @(posedge clock) begin
				if (reset) begin
					dep_low_r <= 32'h0;
					dep_high_r <= 32'h0;
				end else begin
					if (rd_waddr == 'h35 && rd_wen) begin
						$display("Write dep_low_r='h%08h csr_addr='h%08h", rd_wdata, csr[11:0]);
						dep_low_r <= rd_wdata;
					end
					if (rd_waddr == 'h36 && rd_wen) begin
						$display("Write dep_high_r='h%08h csr_addr='h%08h", rd_wdata, csr[11:0]);
						dep_high_r <= rd_wdata;
					end
					
				end
			end
			assign dep_exception = (
					dep_low_r[0] && dep_high_r[0] &&
					!(alu_out_r[31:4] >= dep_low_r[31:4] && alu_out_r[31:4] <= dep_high_r[31:4])
					);
		end else begin
			assign dep_exception = 0;
		end
	endgenerate
	
	wire[31:0]      jal_off = $signed({instr[31], instr[19:12], instr[20], instr[30:21],1'b0});
	wire[31:0]      auipc_imm_31_12 = {instr[31:12], {12{1'b0}}};
	wire[31:0]      imm_11_0 = $signed({instr[31:20]});
	wire[31:0]      st_imm_11_0 = $signed({instr[31:25], instr[11:7]});
	
	wire[31:0]      imm_lui = {instr[31:12], 12'h000};
	wire[31:0]		imm_branch = $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});
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
			case (instr[14:13]) // synthesis parallel_case
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
				case ({op_csr,op_eret})
					2'b10: begin
						ra_raddr = rs1;
						if (op_csrrc) begin
							rb_raddr = csr_addr;
						end else begin
							rb_raddr = zero;
						end
						rd_waddr = 0;
					end 
					
					2'b01: begin
						// ERET sets up 
						ra_raddr = CSR_MEPC;
						rb_raddr = zero;
						rd_waddr = zero;
					end 
					
					default: begin
						// Normal instructions setup read during DECODE
						ra_raddr = rs1;
						rb_raddr = rs2;
						rd_waddr = rd;					
					end
				endcase
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

//			`SHIFT_1, `SHIFT_2: begin
//				// rs1 has been read as ra_rdata
//				// write to CSR_tmp
//				ra_raddr = CSR_tmp;
//				rb_raddr = zero;
//				rd_waddr = CSR_tmp;
//			end
			
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
				end else begin
					case({op_csr, op_shift})
						2'b10: begin
							ra_raddr = 0;
							rb_raddr = 0;
							if (op_csrr_cs && |rs1 == 0) begin
								// CSRRC and CSRRS don't modify the CSR is RS1==0
								rd_waddr = zero;
							end else begin
								rd_waddr = csr_addr;
							end
						end
						
						2'b01: begin
							ra_raddr = CSR_tmp;
							rb_raddr = zero;
							rd_waddr = rd;
						end
						
						default: begin
							ra_raddr = rs1; 
							rb_raddr = rs2; 
							rd_waddr = rd;
						end
					endcase
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
		exc_code[3] = (op_ecall && !instr[20]);
		exc_code[2] = op_ld_st;
		exc_code[1] = (op_ecall || op_st);
		exc_code[0] = op_ecall;
//		case ({op_ecall, op_ld, op_st})
//			3'b100: exc_code = (instr[20])?4'h3:4'hb;
//			3'b010: exc_code = 4'h4;
//			3'b001:	exc_code = 4'h6;
//			default: exc_code = 5'h0;
//		endcase
//		if (op_ecall) begin
//			exc_code = (instr[20])?4'h3:4'hb;
//		end else if (op_ld) begin
//			exc_code = 4'h4;
//		end else if (op_st) begin
//			exc_code = 4'h6;
//		end else begin
//			exc_code = 4'h0;
//		end
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
			end
			
			`MEMR: begin
				rd_wdata = read_data_wb;
			end
			
			`CYCLE_COUNT_UPDATE_1: begin
				rd_wdata = {24'b0, cycle_counter};
			end
			
			`CYCLE_COUNT_UPDATE_2: begin
				rd_wdata = alu_out;
			end
			
//			`SHIFT_1: begin
//				rd_wdata = ra_rdata;
//			end
			
			default: /*EXECUTE: */ begin
				if (exception) begin
					// Write badaddr
					if (instr[6:5] == 3'b11 /*op_jal || op_jalr || op_branch*/) begin
						rd_wdata = {alu_out[31:1], 1'b0}; 
					end else begin
						rd_wdata = alu_out; 
					end
				end else begin
					case ({(op_jal || op_jalr), ((op_arith_imm || op_arith_reg) && instr[14:13] == 2'b01)})
						2'b10: rd_wdata = {pc_plus4, 2'b0};
						// SLT, SLTU, SLTI, SLTUI
						2'b01: rd_wdata = {{31{1'b0}}, comp_out}; 
						default: rd_wdata = alu_out;
					endcase
				end				
			end			
		endcase
	end

	/****************************************************************
	 * Selection of rd_wen
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
	
		case (state) 
			`CSR_1: begin
				alu_op_a = (instr[14])?rs1:ra_rdata;
			end
			
			`CYCLE_COUNT_UPDATE_2: alu_op_a = ra_rdata;
			
			`INSTR_COUNT_UPDATE_1: alu_op_a = {24'b0, instr_counter};
				
			default: begin
				case ({op_lui, op_auipc, op_jal, op_branch}) 
					4'b1000: alu_op_a = imm_lui;
					4'b0100: alu_op_a = auipc_imm_31_12;
					4'b0010: alu_op_a = jal_off;
					4'b0001: alu_op_a = imm_branch;
					default: alu_op_a = ra_rdata;
				endcase
			end
		endcase
		
		case (state)
			`CYCLE_COUNT_UPDATE_2, `INSTR_COUNT_UPDATE_1: begin
				alu_op_b = rb_rdata;
			end
			
			default: begin
				case ({op_lui, (op_auipc || op_jal || op_branch), (op_jalr || op_ld || (op_arith_imm && !op_shift)), op_st})
					4'b1000: alu_op_b = zero; // op_lui
					4'b0100: alu_op_b = {pc, 2'b0};
					4'b0010: alu_op_b = imm_11_0;
					4'b0001: alu_op_b = st_imm_11_0; // op_st
					default: alu_op_b = rb_rdata;
				endcase
			end
		endcase
		
		case (state)
			`EXECUTE: begin
				case ({(op_arith_imm || op_arith_reg), op_csrrc, op_sys}) // synthesis parallel_case
					3'b100: begin
						case (instr[14:12]) 
							3'b000: alu_op = (op_arith_reg && instr[30])?`OP_SUB:`OP_ADD; // ADDI, ADD, SUB
							3'b100: alu_op = `OP_XOR;
							3'b001, 3'b101, 3'b110: alu_op = `OP_OR; // SLL, SRA, SRL, OR
							default: alu_op = `OP_AND;
						endcase
					end
					3'b010: alu_op = `OP_XOR; // op_csrrc
					3'b001: alu_op = `OP_OR; // op_sys
					default: alu_op = `OP_ADD;
				endcase
			end
			
			`CYCLE_COUNT_UPDATE_2, `INSTR_COUNT_UPDATE_1: 
				alu_op = `OP_ADD;
			
//			`SHIFT_2:
//				alu_op = (instr[14])?
//					(instr[30])?`OP_SRA:`OP_SRL:
//					`OP_SLL;
			
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
	
	fwrisc_mul_div_shift #(
		.ENABLE_MUL  (ENABLE_MUL )
		) u_mds (
		.clock       (clock          ),
		.reset       (reset      	 ),
		.in_a        (alu_op_a       ),
		.in_b        (alu_op_b       ),
		.op          (mds_op         ),
		.in_valid    (mds_in_valid   ),
		.out         (mds_out        ),
		.out_valid   (mds_out_valid  ));
	
	always @(posedge clock) begin
		if (reset) begin
			mds_in_valid <= 0;
		end else begin
			case (state) 
				`DECODE: begin
				end
			endcase
		end
	end

	/****************************************************************
	 * pc_next selection
	 ****************************************************************/
	wire jal_jalr_branch = (op_jal || op_jalr || (op_branch && branch_cond));
	wire eret_exception = (op_eret || exception);
	wire op_st_ld = (op_st || op_ld);
	always @* begin : pc_next_sel
		case ({jal_jalr_branch, eret_exception}) // synthesis parallel_case
			2'b10: pc_next = alu_out[31:2];
			2'b01: pc_next = ra_rdata[31:2];
			default: pc_next = pc_plus4;
		endcase		
//		case ({jal_jalr_branch, eret_exception}) 
//			2'b10: pc_next = alu_out[31:2];
//			2'b01: pc_next = ra_rdata[31:2];
//			2'b00: pc_next = pc_plus4;
//		endcase
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
		// Hmm... The case statement seems a bit unstable, but the explicit
		// logic requires more resources for lattice. 
		misaligned_addr = (
				(jal_jalr_branch & (alu_out[1] || dep_exception)) |
				(op_st_ld & ((instr[12] & alu_out[0]) | (instr[13] & |alu_out[1:0])))
				);
//		case ({op_st_ld, jal_jalr_branch}) // synthesis parallel_case
//			2'b10: begin
//				case (instr[13:12])  // synthesis parallel_case
//					2'b00: begin // SB
//						misaligned_addr = 0;
//					end
//					2'b01: begin // SH
//						misaligned_addr = op_ld_st && alu_out[0];
//					end
//					// SW and default
//					default: begin
//						misaligned_addr = op_ld_st && |alu_out[1:0];
//					end
//				endcase		
//			end
//			2'b01:
//				misaligned_addr = (
//					alu_out[1] /* ||
//					!(alu_out >= 'h80000000 && alu_out <= 'h80005a4c)*/); // the low-bit is always cleared on jump
//			
//			default: misaligned_addr = 0;
//		endcase
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

