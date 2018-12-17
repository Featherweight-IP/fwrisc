/****************************************************************************
 * fwrisc_formal_arith_checker.sv
 ****************************************************************************/

`include "fwrisc_formal_opcode_defines.svh"
/**
 * Module: fwrisc_formal_arith_checker
 * 
 * TODO: Add module documentation
 */
module fwrisc_tracer(
		input			clock,
		input			reset,
		// Current instruction
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
	reg[31:0]			in_regs[63:0];
	reg[31:0]			out_regs[63:0];
	reg					out_regs_w[63:0];
	
	genvar i;
	for (i=0; i<64; i++) begin
		always @(posedge clock) if (reset) out_regs_w[i] <= 0;
	end

	reg[5:0] 	rd, rs1, rs2;
	reg[6:0]	opcode;
	reg[2:0]	funct3;
	reg[6:0]	funct7;
	reg[31:12]	imm_31_12;
	reg[31:0]	imm_11_0;
	reg[31:0]	imm_11_0_u;
	reg[31:0]	pc_r;

	always @(posedge clock) begin
		// Capture at the end of EXECUTE
		if (ivalid) begin
			rd <= `rd(instr);
			rs1 <= `rs1(instr);
			rs2 <= `rs2(instr);
			opcode <= `opcode(instr);
			funct3 <= `funct3(instr);
			funct7 <= `funct7(instr);
			imm_31_12 <= instr[31:12];
			imm_11_0  <= $signed(instr[31:20]);
			imm_11_0_u  <= instr[31:20];
			pc_r <= pc;
		end
	end
	
	reg[5:0] ra_raddr_r, rb_raddr_r;
	
	always @(posedge clock) begin
		ra_raddr_r <= ra_raddr;
		rb_raddr_r <= rb_raddr;
		
		if (reset == 0) begin
			if (rd_write) begin
				out_regs_w[rd_waddr] <= 1;
				out_regs[rd_waddr] <= rd_wdata;
			end
			in_regs[ra_raddr_r] <= ra_rdata;
			in_regs[rb_raddr_r] <= rb_rdata;
		end
	end
	
	reg ivalid_r;
	always @(posedge clock) begin
		if (reset == 1) begin
			ivalid_r <= 0;
		end else begin
			ivalid_r <= ivalid;
		
			// Writing to $zero is never expected
			assert(out_regs_w[0] == 0);
			
			cover(ivalid_r == 1);
			
			if (ivalid_r) begin
				case (opcode)
					7'b0110011: begin // register
						case (funct3)
							3'b000: begin // add
								if (funct7 == 7'b0000000) begin
									assert(rd == 0 || out_regs[rd] == in_regs[rs1] + in_regs[rs2]);
								end else begin
									assert(rd == 0 || out_regs[rd] == in_regs[rs1] - in_regs[rs2]);
								end
							end
							3'b001: begin // sll
								assert(rd == 0 || out_regs[rd] == in_regs[rs1] << in_regs[rs2]);
							end
							3'b010: begin // slt
								assert(rd == 0 || out_regs[rd] == ($signed(in_regs[rs1]) < $signed(in_regs[rs2]))?1:0);
							end
							3'b011: begin // sltu
								assert(rd == 0 || out_regs[rd] == (in_regs[rs1] < in_regs[rs2])?1:0);
							end
							3'b100: begin // xor
								assert(rd == 0 || out_regs[rd] == (in_regs[rs1] ^ in_regs[rs2]));
							end
							3'b101: begin // srl/sra
								if (funct7 == 7'b0000000) begin
									assert(rd == 0 || out_regs[rd] == (in_regs[rs1] >> in_regs[rs2]));
								end else begin
									assert(rd == 0 || out_regs[rd] == (in_regs[rs1] >>> in_regs[rs2]));
								end
							end
							3'b110: begin // or
								assert(rd == 0 || out_regs[rd] == (in_regs[rs1] | in_regs[rs2]));
							end
							3'b111: begin // and
								assert(rd == 0 || out_regs[rd] == (in_regs[rs1] & in_regs[rs2]));
							end
						endcase
					end
					
					7'b0010011: begin // immediate
						case (funct3)
							3'b000: begin // addi
								assert(rd == 0 || out_regs[rd] == in_regs[rs1] + imm_11_0);
							end
							3'b001: begin // slli
								assert(rd == 0 || out_regs[rd] == in_regs[rs1] << rs2);
							end
							3'b010: begin // slti
								assert(rd == 0 || out_regs[rd] == ($signed(in_regs[rs1]) < $signed(imm_11_0))?1:0);
							end
							3'b011: begin // sltiu
								assert(rd == 0 || out_regs[rd] == (in_regs[rs1] < imm_11_0_u)?1:0);
							end
							3'b100: begin // xori
								assert(rd == 0 || out_regs[rd] == (in_regs[rs1] ^ imm_11_0_u));
							end
							3'b101: begin // srli
								if (funct7[5]) begin
									assert(rd == 0 || out_regs[rd] == in_regs[rs1] >>> rs2);
								end else begin
									assert(rd == 0 || out_regs[rd] == in_regs[rs1] >> rs2);
								end
							end
							3'b110: begin // ori
								assert(rd == 0 || out_regs[rd] == (in_regs[rs1] | imm_11_0_u));
							end
							3'b111: begin // andi
								assert(rd == 0 || out_regs[rd] == (in_regs[rs1] & imm_11_0_u));
							end
						endcase
					end
					
					7'b0010111: begin // auipc
						assert(rd == 0 || out_regs[rd] == (pc_r + $signed(imm_31_12)));
					end
						
					7'b0110111: begin // lui
						assert(rd == 0 || out_regs[rd] == {imm_31_12, 12'h000});
					end
				
					// Unknown opcode
					default: begin
						assert(0);
					end
				endcase
			end
		end
	end
	
	genvar chk_i;
	for (chk_i=1; chk_i<64; chk_i++) begin
		if (chk_i != 'h3f) begin
		always @(posedge clock) 
			// NOTE: ignore writes to the TEMP register
			if (reset == 0 && ivalid_r) begin
				assert(out_regs_w[chk_i] == (chk_i == rd));
				out_regs_w[chk_i] <= 0;
			end
		end
	end


endmodule


