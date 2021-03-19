
/****************************************************************************
 * fwrisc_dbg_bfm.v
 ****************************************************************************/

  
/**
 * Module: fwrisc_dbg_bfm
 * 
 * TODO: Add module documentation
 */
module fwrisc_dbg_bfm(
		input			clock,
		input			reset,
		input [31:0]	pc,
		input [31:0]	instr,
		// True during execute stage. 
		// Note that write-back will occur at the same time
		input			ivalid,
		// ra, rb
		input [4:0]		ra_raddr,
		input [31:0]	ra_rdata,
		input [4:0]		rb_raddr,
		input [31:0]	rb_rdata,
		// rd
		input [4:0]		rd_waddr,
		input [31:0]	rd_wdata,
		input			rd_write,
		// CSR
		input [11:0]	csr_waddr,
		input [31:0]	csr_wdata,
		input			csr_write,
		
		// memory access
		input [31:0]	maddr,
		input [31:0]	mdata,
		input [3:0]		mstrb,
		input			mwrite,
		input 			mvalid		
		);
	
	wire 				rv_dbg_valid     = ivalid;
	wire[31:0] 			rv_dbg_instr     = instr;
	wire				rv_dbg_trap      = 0; // U_CORE_PATH .trap;
	reg[4:0] 			rv_dbg_rd_addr   = 0; 
	reg[31:0] 			rv_dbg_rd_wdata  = 0;
	wire[31:0]			rv_dbg_pc        = pc;
	reg[31:0]			rv_dbg_mem_addr  = {32{1'b0}};
	reg[3:0]			rv_dbg_mem_wmask = {4{1'b0}};
	reg[3:0]			rv_dbg_mem_rmask = {4{1'b0}};
	reg[31:0]			rv_dbg_mem_data  = {32{1'b0}};
	
	always @(posedge clock) begin
		if (rv_dbg_valid) begin
			rv_dbg_mem_wmask <= {4{1'b0}};
			rv_dbg_mem_rmask <= {4{1'b0}};
			rv_dbg_mem_addr  <= {32{1'b0}};
			rv_dbg_mem_data <= {32{1'b0}};
			rv_dbg_rd_addr <= 0;
			rv_dbg_rd_wdata <= 0;
		end else begin
			if (mvalid) begin
				rv_dbg_mem_addr  <= maddr;
				if (mwrite) begin
					rv_dbg_mem_wmask <= mstrb;
					rv_dbg_mem_data <= mdata;
				end else begin
					rv_dbg_mem_rmask <= 'hf; // TMP
					rv_dbg_mem_data <= mdata;
				end
			end
			if (rd_write) begin
				rv_dbg_rd_addr <= rd_waddr;
				rv_dbg_rd_wdata <= rd_wdata;
			end
		end
	end	

	riscv_debug_bfm u_dbg (
			.clock(				clock),
			.reset(				reset),
			.valid( 			rv_dbg_valid),
			.instr( 			rv_dbg_instr),
			.intr(				rv_dbg_trap),
			.rd_addr( 			rv_dbg_rd_addr),
			.rd_wdata( 			rv_dbg_rd_wdata),
			.pc(				rv_dbg_pc),
			.mem_addr(			rv_dbg_mem_addr),
			.mem_rmask(			rv_dbg_mem_rmask),
			.mem_wmask(			rv_dbg_mem_wmask),
			.mem_data(			rv_dbg_mem_data)
		);	

endmodule


