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
		output[31:0]	drdata,
		output[3:0]		dstrb,
		output			dwrite,
		output			dvalid,
		input			dready
		);

	reg[31:0]			instr;
	
	typedef enum bit[3:0] {
		FETCH, // 
		DECODE,
		EXECUTE,
		CSR_1,
		CSR_2,
		MEMW,
		MEMR,
		EXCEPTION_1
	} state_e;
	
	state_e				state;
	reg[31:2]			pc;
	wire[31:2]			pc_plus4;
	wire[31:2]			pc_next;
	
	assign pc_plus4 = (pc + 1'b1);

	assign iaddr = {pc, 2'b0};
	assign ivalid = (state == FETCH && !reset);
	
	// ALU signals
	wire[31:0]					alu_op_a;
	wire[31:0]					alu_op_b;
	wire [4:0]					alu_op;
	wire[32:0]					alu_out;
	wire						alu_out_valid;
	
	
	always @(posedge clock) begin
		if (reset) begin
			state <= FETCH;
			instr <= 0;
		end else begin
			if (ivalid && iready) begin
				instr <= idata;
			end
			
			case (state)
				FETCH: begin
					if (ivalid && iready) begin
						state <= DECODE;
						instr <= idata;
					end
				end
				
				DECODE: begin
					// NOP: wait for decode to occur
					if (op_csr) begin
						state <= CSR_1;
					end else begin
						state <= EXECUTE;
					end
				end
				
				// CSR operation is:
				// - Read CSR and write it to a temp register
				// - Read temp register, perform operation, and write back to CSR
				// - Read temp register and write to rd (if !0)
				//
				// CSRRW
				// 1.) rs2==$zero, rs1=<CSR>, op=OR, rd=<CSR_temp> (CSR_1)
				// 2.) rs2=$zero, rs1=<rs1>, op=OR, rd=<CSR>       (CSR_2)
				// 3.) rs2=$zero, rs1=<CSR_temp>, op=OR, rd=rd     (EXECUTE)
				//
				// CSRRS
				// 1.) rs2=$zero, rs1=<CSR>, op=OR, rd=<CSR_temp>  (CSR_1)
				// 2.) rs2=<CSR_temp>, rs1=rs1, op=OR, rd=<CSR>    (CSR_2)
				// 3.) rs2=$zero, rs1=<CSR_temp>, op=OR, rd=rd     (EXECUTE)
				//
				// CSRRC
				// 1.) rs2=$zero, rs1=<CSR>, op=OR, rd=<CSR_temp>  (CSR_1)
				// 2.) rs2=<CSR_temp>, rs1=rs1, op=CLR, rd=<CSR>   (CSR_2)
				// 3.) rs2=$zero, rs1=<CSR_temp>, op=OR, rd=rd     (EXECUTE)
				
			
				// CSR phase 1 -- Read the target CSR and write it to TMP
				CSR_1: begin
					if (op_csrrc) begin
						state <= CSR_2;
					end else begin
						state <= EXECUTE;
					end
				end
				
				CSR_2: begin
					state <= EXECUTE;
				end
				
				EXECUTE: begin
					if (exception) begin
						// Exception Handling:
						// - Write the address to MTVAL in EXECUTE
						// - Write the cause to MTCAUSE in EXECEPTION_1
						// - Jump to FETCH to execute vector address
						state <= EXCEPTION_1;
					end else if (op_ld) begin
						state <= MEMR;
					end else if (op_st) begin
						state <= MEMW;
					end else begin
						pc <= pc_next;
						state <= FETCH;
					end
				end
				
				MEMW, MEMR: begin
					if (dvalid && dready) begin
						pc <= pc_next;
						state <= FETCH;
					end
				end
			
				// Capture ALU output 
				EXCEPTION_1: begin
					pc <= pc_next;
					state <= FETCH;
				end
			endcase
		end
	end
	
	

	wire op_branch_ld_st_arith = (instr[3:0] == 4'b0011);
	wire op_ld        = (op_branch_ld_st_arith && instr[6:4] == 3'b000);
	wire op_arith_imm = (op_branch_ld_st_arith && instr[6:4] == 3'b001);
	wire op_shift_imm = (op_arith_imm && instr[13:12] == 2'b01);
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
	wire op_ecall     = (op_sys && op_sys_prv && instr[24:20] == 5'b00000);
	wire op_eret      = (op_sys && op_sys_prv && instr[24:20] == 5'b00010);
	
	wire op_csr       = (op_sys && |instr[14:12]);
	wire op_csrr_cs   = (op_csr && instr[13]);
	wire op_csrrc     = (op_csr && instr[13:12] == 2'b11);
	wire [11:0]	csr   = instr[31:20];
	wire [5:0]	csr_addr;

	wire[5:0] CSR_MTVEC  = 6'h25;
	wire[5:0] CSR_MEPC   = 6'h29;
	wire[5:0] CSR_MCAUSE = 6'h2A;
	// 0x300-0x306 => 0x20-0x26 (+0x20)
	// 0x340-0x344 => 0x28-0x2C 
	// 0xF11-0xF14 => 0x31-0x34 (49-52)
	// CSR_tmp = 63
	always @* begin
		case (csr[11:8])
			4'h3: begin
				if (csr[7:4] == 0) begin
					csr_addr = {2'b10, csr[3:0]};
				end else begin
					csr_addr = {3'b101, csr[2:0]};
				end
			end
			default: begin
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
	
	parameter reg[5:0]		CSR_tmp = 63;

	wire[5:0]		ra_raddr;
	wire[5:0]		rb_raddr;
	wire[31:0]		ra_rdata;
	wire[31:0]		rb_rdata;
	wire[31:0]		rb_rdata_neg;
	wire[5:0]		rd_waddr;
	wire[31:0]		rd_wdata;
	wire			rd_wen;
	
	
	// Comparator signals
	wire[31:0]					comp_op_a = ra_rdata;
	wire[31:0]					comp_op_b;
	wire[4:0]					comp_op;
	wire						comp_out;
	wire						branch_cond;
	
	// Exception signals
	wire						exception;
	
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
				comp_op = COMPARE_LT;  // SLT, SLTI
			end else begin
				comp_op = COMPARE_LTU; // SLTU, SLTUI
			end
		end else begin
			case (instr[14:13]) 
				2'b00: comp_op = COMPARE_EQ;  // BEQ, BNE
				2'b10: comp_op = COMPARE_LT;  // BLT, BGE
				default: /*2'b11: */comp_op = COMPARE_LTU; // BLTU BGEU
			endcase
		end
	end
	assign branch_cond = (instr[12])?!comp_out:comp_out;
	
	always @* begin
		if (op_csr) begin
			if (state == CSR_2 || (state == CSR_1 && op_csrr_cs)) begin
				rb_raddr = csr_addr;
			end else begin
				rb_raddr = 0;
			end
			if (state == DECODE) begin // During decode, setup read of 
				ra_raddr = csr_addr;
//				rd_waddr = CSR_tmp;
				rd_waddr = 0; // TODO
			end else if (state == CSR_1) begin 
				ra_raddr = rs1; // RS1
				rd_waddr = rd;
			end else if (state == CSR_2) begin
				ra_raddr = CSR_tmp;
				rd_waddr = CSR_tmp;
			end else begin
				// EXECUTE
				ra_raddr = 0; // Should really be PC
				rd_waddr = csr_addr;
			end
		end else if (op_eret) begin
			ra_raddr = CSR_MEPC;
			rb_raddr = zero;
			rd_waddr = zero;
		end else if (exception) begin
			ra_raddr = CSR_MTVEC;
			rb_raddr = zero;
			rd_waddr = zero; // TODO:
		end else begin
			ra_raddr = rs1;
			rb_raddr = rs2;
			rd_waddr = rd;
		end
	end
	
	always @* begin
		if (op_jal || op_jalr) begin
			rd_wdata = {pc_plus4, 2'b0};
		end else if (op_ld) begin
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
		end else begin
			if ((op_arith_imm || op_arith_reg) && instr[14:13] == 2'b01 /* 010,011 */) begin
				// SLT, SLTU, SLTI, SLTUI
				rd_wdata = {{31{1'b0}}, comp_out};
			end else begin
				rd_wdata = alu_out;
			end
		end
	end
	

	// Write at the end of the execute state 
	// when the destination isn't $zero
	//
	// For load instructions, 
	always @* begin
		if (op_ld || op_st) begin
			rd_wen = (state == MEMR && |rd && dready);
		end else if (op_csr) begin
			// TODO:
			if (op_csrr_cs) begin
				rd_wen = ((state == CSR_1 && |rd_waddr) || ((state == EXECUTE || state == CSR_2) && |rs1));
			end else begin
				rd_wen = ((state == EXECUTE || state == CSR_1 || state == CSR_2) && |rd_waddr);
			end
		end else begin
			rd_wen = (state == EXECUTE && !op_branch && |rd); // TODO: deal with exception
		end
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
	
	reg [7:0]			cycle_counter;
	reg [7:0]			instr_counter;
	always @(posedge clock) begin
		if (reset) begin
			cycle_counter <= 0;
		end else begin
			cycle_counter <= cycle_counter + 1;
		end
	end
	
	always @(posedge clock) begin
		if (reset) begin
			instr_counter <= 0;
		end else if (state == EXECUTE) begin
			instr_counter <= instr_counter + 1;
		end
	end
	

	always @* begin
		if (op_lui) begin
			alu_op_a = imm_lui;
			alu_op_b = zero;
		end else if (op_auipc) begin
			alu_op_a = auipc_imm_31_12;
			alu_op_b = {pc, 2'b0};
		end else if (op_jal) begin
			alu_op_a = jal_off;
			alu_op_b = {pc, 2'b0};
		end else if (op_jalr) begin
			alu_op_a = ra_rdata;
			alu_op_b = imm_11_0;
		end else if (op_ld || op_arith_imm) begin
			if (op_shift_imm) begin
				alu_op_a = imm_11_0[4:0]; // Shift immediate
			end else begin
				alu_op_a = imm_11_0; // sign-extended immediate
			end
			alu_op_b = ra_rdata; // rs1
		end else if (op_st) begin
			alu_op_a = st_imm_11_0; // sign-extended immediate
			alu_op_b = ra_rdata; // rs1
		end else if (op_arith_reg) begin
			if (instr[14:12] == 3'b000 && instr[30]) begin // SUB
				alu_op_a = -$signed(rb_rdata); // rb_rdata_neg;
			end else begin
				alu_op_a = rb_rdata; // rs2
			end
			alu_op_b = ra_rdata; // rs1
		end else if (op_branch) begin
			// For branches, we use branch_immediate
			alu_op_a = imm_branch;
			alu_op_b = {pc, 2'b0};
		end else if (op_csr) begin
			alu_op_a = ra_rdata;
			alu_op_b = rb_rdata;
		end else begin
			alu_op_a = zero;
			/* TMP
			alu_op_a = {cycle_counter, instr_counter};
			 */
			alu_op_b = zero;
		end
		
		if (op_lui || op_auipc || op_jal || op_jalr || op_ld || op_st || op_branch) begin
			alu_op = OP_ADD;
		end else if (op_arith_imm || op_arith_reg) begin
			case (instr[14:12]) 
				3'b000: begin // ADDI, ADD, SUB
					// TODO: handle register subtract
					alu_op = OP_ADD;
				end
				3'b001: begin // SLL, SLLI
					alu_op = OP_SLL;
				end
				/* We don't need an op for these instructions
				3'b010: begin // SLT
				end
				3'b011: begin // SLTU
				end
				 */
				3'b100: begin // XOR
					alu_op = OP_XOR;
				end
				3'b101: begin // SRA, SRAI, SRL, SRLI
					alu_op = (instr[30])?OP_SRA:OP_SRL;
				end
				3'b110: begin // OR
					alu_op = OP_OR;
				end
				default: /*3'b111: */begin // AND
					alu_op = OP_AND;
				end
			endcase
		end else if (op_sys) begin
			alu_op = OP_OR; // TODO: except CSRRC && CSR_2
		end else begin
			alu_op = OP_ADD;
		end
	end
	
	fwrisc_alu u_alu (
		.clock  	(clock 			), 
		.reset  	(reset 			), 
		.op_a   	(alu_op_a  		), 
		.op_b   	(alu_op_b  		), 
		.op     	(alu_op    		), 
		.out    	(alu_out   		),
		.out_valid 	(alu_out_valid	));
	
	
	always @* begin
		if (op_jal || op_jalr || (op_branch && branch_cond)) begin
			pc_next = alu_out[31:2];
		end else if (op_eret || exception) begin
			pc_next = ra_rdata[31:2];
		end else begin
			pc_next = pc_plus4;
		end
	end
	
	// Handle data-access control signals
	assign dvalid = (state == MEMR || state == MEMW);
	assign dwrite = (state == MEMW);
	assign daddr = {alu_out[31:2], 2'b0}; // Always use the ALU for address
	wire misaligned_addr;
	
	always @* begin
		case (instr[13:12]) 
			2'b00: begin // SB
				dstrb = (1'b1 << alu_out[1:0]);
				dwdata = {rb_rdata[7:0], rb_rdata[7:0], rb_rdata[7:0], rb_rdata[7:0]};
				misaligned_addr = 0;
			end
			2'b01: begin // SH
				dstrb = (2'b11 << {alu_out[1], 1'b0});
				dwdata = {rb_rdata[15:0], rb_rdata[15:0]};
				misaligned_addr = op_ld_st && alu_out[0];
			end
			// SW and default
			default: begin
				dstrb = 4'hf;
				dwdata = rb_rdata; // Write data is always @ rs2
				misaligned_addr = op_ld_st && |alu_out[1:0];
			end
		endcase		
	end
	
	always @* begin
		if (state == EXECUTE || state == EXCEPTION_1) begin
			if (op_ecall) begin // ECALL||EBREAK
				exception = 1;
			end else if ((op_ld || op_st) && misaligned_addr) begin
				exception = 1;
			end else begin
				exception = 0;
			end
		end else begin
			exception = 0;
		end
	end

	fwrisc_tracer u_tracer (
		.clock   (clock  			), 
		.reset   (reset  			), 
		.addr    ({pc, 2'b0}		), 
		.instr   (instr  			), 
		.ivalid  ((state == EXECUTE)), 
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


