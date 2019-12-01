
module fwrisc_tracer_bfm(
		input			clock,
		input			reset,
		input [31:0]	pc,
		input [31:0]	instr,
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
		
		input [31:0]	maddr,
		input [31:0]	mdata,
		input [3:0]		mstrb,
		input			mwrite,
		input 			mvalid
		);
	
	localparam N_HW_BP = 8;
	localparam N_MW_REGIONS = 4;

	reg[31:0]			regs[63:0];
	reg[31:0]			last_instr = 0;
	reg					reg_write_f[63:0];
	reg[31:0]			hw_bp_addr[N_HW_BP-1:0];
	reg					hw_bp_addr_valid[N_HW_BP-1:0];
	reg[31:0]			mw_addr_base[N_MW_REGIONS-1:0];
	reg[31:0]			mw_addr_limit[N_MW_REGIONS-1:0];
	reg					mw_addr_valid[N_MW_REGIONS-1:0];
	reg					trace_all_mem_write = 1;
	reg					trace_instr_all = 1;
	reg					trace_instr_jump = 1;
	reg					trace_instr_call = 1;
	reg					trace_reg_writes = 1;
	
	integer i;
	initial begin
		for (i=0; i<64; i++) begin
			regs[i] = 0;
			reg_write_f[i] = 0;
		end
		for (i=0; i<N_HW_BP; i++) begin
			hw_bp_addr_valid[i] = 0;
		end
		for (i=0; i<N_MW_REGIONS; i++) begin
			mw_addr_valid[i] = 0;
		end
	end
	
	task set_trace_all_memwrite(reg t);
		trace_all_mem_write = t;
	endtask
	
	task set_addr_region(reg[31:0] i, reg[31:0] base, reg[31:0] limit, reg[7:0] valid);
		mw_addr_base[i] = base;
		mw_addr_limit[i] = limit;
		mw_addr_valid[i] = valid;
	endtask

	task set_trace_instr(reg all, reg jumps, reg calls);
		trace_instr_all = all;
		trace_instr_jump = jumps;
		trace_instr_call = calls;
	endtask
	
	task set_trace_reg_writes(reg t);
		trace_reg_writes = t;
	endtask
	
	task get_reg_info_req(reg[5:0] raddr);
		get_reg_info_ack(
				regs[raddr],
				reg_write_f[raddr]
			);
	endtask
	
	always @(posedge clock) begin
		if (rd_write && rd_waddr != 0) begin
			if (trace_reg_writes) begin
				reg_write(rd_waddr, rd_wdata);
			end
			regs[rd_waddr] <= rd_wdata;
			reg_write_f[rd_waddr] <= 1;
		end
	end

	reg hw_breakpoint;
	always @(posedge clock) begin
		if (ivalid) begin
			last_instr <= instr;
			hw_breakpoint = 0;
			
			for (i=0; i<N_HW_BP; i++) begin
				if (instr == hw_bp_addr[i] && hw_bp_addr_valid[i]) begin
					hw_breakpoint = 1;
				end
			end

			if (trace_instr_all 
					|| (trace_instr_jump && (
						last_instr[6:0] == 7'b1101111 || // jal
						last_instr[6:0] == 7'b1100111))  // jalr
					|| (trace_instr_call && (
						last_instr[6:0] == 7'b1101111 ||
						last_instr[6:0] == 7'b1100111) && last_instr[11:7] != 5'b0)
					|| hw_breakpoint) begin
				instr_exec(pc, instr);
			end
		end
	end

	reg mw_region_hit;
	always @(posedge clock) begin
		if (mvalid && mwrite) begin
			mw_region_hit = 0;
			for (i=0; i<N_MW_REGIONS; i++) begin
				if (mw_addr_valid[i] && maddr >= mw_addr_base[i] && maddr <= mw_addr_limit[i]) begin
					mw_region_hit = 1;
				end
			end
			
			if (trace_all_mem_write || mw_region_hit) begin
				mem_write(maddr, mstrb, mdata);
			end
		end
	end
	
${cocotb_bfm_api_impl}
	
endmodule
