/****************************************************************************
 * fwrisc_formal_arith_checker.sv
 ****************************************************************************/

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

	reg[5:0] rd, rs1, rs2;

	always @(posedge clock) begin
		// Capture at the end of EXECUTE
		if (ivalid) begin
			rd <= instr[11:7];
			rs1 <= instr[19:15];
			rs2 <= instr[24:20];
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
				if (rd != 0) begin
					// TODO: decode instruction and perform appropriate checks
					assert(out_regs[rd] == in_regs[rs1] + in_regs[rs2]);
				end
			end
		end
	end
	
	genvar chk_i;
	for (chk_i=1; chk_i<64; chk_i++) begin
		always @(posedge clock) 
			if (reset == 0 && ivalid_r) begin
				assert(out_regs_w[chk_i] == (chk_i == rd));
				out_regs_w[chk_i] <= 0;
			end
	end


endmodule


