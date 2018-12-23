/****************************************************************************
 * fwrisc_formal_arith_checker.sv
 ****************************************************************************/

`include "fwrisc_formal_opcode_defines.svh"
/**
 * Module: fwrisc_formal_jump_checker
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
	wire[31:0]			fwrisc_formal_drdata;
	
	genvar i;
	for (i=0; i<64; i++) begin
		always @(posedge clock) if (reset) out_regs_w[i] <= 0;
	end

	
	reg[31:0]		in_regs[63:0];
	reg[31:0]		out_regs[63:0];
	reg				out_regs_w[63:0];
	reg[5:0] 		ra_raddr_r, rb_raddr_r;
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
	
	reg 		ivalid_r;
	reg[1:0]	state = 0;
	reg[5:0] 	rd, rs1;
	reg[6:0]	opcode;
	reg[31:0]	imm_jal;
	reg[31:0]	imm_jalr;
	reg[31:0]	pc_curr;
	reg[31:0]	pc_target;
	always @(posedge clock) begin
		if (reset == 1) begin
			ivalid_r <= 0;
			state <= 0;
		end else begin
			ivalid_r <= ivalid;
			
			case (state)
				0: begin
					// Capture at the end of the first EXECUTE
					if (ivalid) begin
						rd <= `rd(instr);
						rs1 <= `rs1(instr);
						opcode <= `opcode(instr);
						imm_jal <= `imm_jtype(instr);
						imm_jalr  <= $signed(instr[31:20]);
						pc_curr <= pc;
					end
					
					if (ivalid_r) begin
						// Calculate the expected jump target
						case (`opcode(instr)) 
							7'b1101111: pc_target <= pc_curr + imm_jal;
							7'b1100111: pc_target <= in_regs[`rs1(instr)] + imm_jalr;
						endcase
						state <= 1;
					end
				end
			
				1: begin
					// End of the second EXECUTE
					if (ivalid) begin
						pc_curr <= pc;
						case (opcode)
							7'b1101111,7'b1100111: begin
								if (pc_target[1] == 0) begin
									assert(pc[31:1] == pc_target[31:1]);
									assert (rd == 0 || out_regs[rd] == (pc_curr+4));
									assert (rd == 0 || out_regs_w[rd] == 1);
								end else begin
									assert(pc == {in_regs['h25][31:2], 2'b0}); // MTVEC
									assert (out_regs['h29] == pc_curr); // MEPC
									assert (out_regs_w['h29] == 1); // MEPC
									assert (out_regs_w['h2A] == 1); // MCAUSE
									assert (out_regs_w[rd] == 0);
								end
							end
							
							// Unknown opcode
							default: begin
								assert(0);
							end
						endcase
						
						state <= 2;
					end
				end
				
				2: begin
					// Idle
				end
			endcase
		end
	end


endmodule


