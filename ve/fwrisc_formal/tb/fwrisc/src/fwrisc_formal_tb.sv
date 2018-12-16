/****************************************************************************
 * fwrisc_formal_tb.sv
 ****************************************************************************/
 
`include "fwrisc_formal_opcode_defines.svh"

/**
 * Module: fwrisc_formal_tb
 * 
 * TODO: Add module documentation
 */
module fwrisc_formal_tb(input clock);

	reg[3:0]	reset_cnt = 0;
	reg 		reset = 1;
	
	always @(posedge clock) begin
		if (reset_cnt == 1) begin
			reset <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	wire[31:0]			iaddr, idata;
	
// `include "fwrisc_formal_instr.svh"
	
	`define rtype(target, funct7, rs2, rs1, funct3, rd, opcode) \
	assign target[31:25] = funct7; \
	assign target[24:20] = rs2; \
	assign target[19:15] = rs1; \
	assign target[14:12] = funct3; \
	assign target[11:7] = rd; \
	assign target[6:0] = opcode
	
	`define rtype_add(target, rs2, rs1, rd) \
		`rtype(target, 7'h0, rs2, rs1, 3'h0, rd, 7'b0110011)
	
	`rtype_add(idata, $anyconst, $anyconst, $anyconst);
	
	wire				iready = ivalid;
	wire[31:0]			daddr;
	wire[31:0]          drdata = $anyconst;
	wire[31:0]          dwdata;
	wire[3:0]			dstrb;
	wire				dvalid;
	wire				dready = dvalid;

	fwrisc u_dut (
		.clock   (clock  ), 
		.reset   (reset  ), 
		.iaddr   (iaddr  ), 
		.idata   (idata  ), 
		.ivalid  (ivalid ), 
		.iready  (iready ), 
		.daddr   (daddr  ), 
		.dwdata  (dwdata ), 
		.drdata  (drdata ), 
		.dstrb   (dstrb  ), 
		.dwrite  (dwrite ), 
		.dvalid  (dvalid ), 
		.dready  (dready ),
		);

//	bind fwrisc_tracer fwrisc_forma_arith_checker u_checker(
//			.clock(clock),
//			.reset(reset),
//			.pc(pc),
//			.instr(instr),
//			.ivalid(ivalid),
//			.ra_raddr(ra_addr),
//			.ra_rdata(ra_rdata),
//			.rb_raddr(rb_addr),
//			.rb_rdata(rb_rdata),
//			.rd_waddr(rd_addr),
//			.rd_wdata(rd_wdata),
//			.rd_write(rd_write),
//			.maddr(maddr),
//			.mdata(mdata),
//			.mstrb(mstrb),
//			.mwrite(mwrite),
//			.mvalid(mvalid)
//		);	
endmodule


