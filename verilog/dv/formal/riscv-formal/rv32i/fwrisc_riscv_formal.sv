
`include "rvfi_macros.vh"
`include "rvfi_channel.sv"
`include "rvfi_testbench.sv"
`include "rvfi_insn_check.sv"
`ifdef RISCV_FORMAL_INSN_V
`include `RISCV_FORMAL_INSN_V
`endif

module rvfi_wrapper(
	input clock,
	input reset,
	`RVFI_OUTPUTS
);
	(* keep *)wire[31:0]		iaddr;
	(* keep *)rand reg[31:0]	idata;
	(* keep *)wire			ivalid;
	(* keep *)rand reg		iready;
	
	(* keep *)wire			dvalid;
	(* keep *)wire[31:0]		daddr;
	(* keep *)wire[31:0]		dwdata;
	(* keep *)wire[3:0]		dwstb;
	(* keep *)wire			dwrite;
	(* keep *)rand reg[31:0]	drdata;
	(* keep *)rand reg		dready;

	fwrisc #(
		.ENABLE_COMPRESSED(0),
		.ENABLE_MUL_DIV(0),
		.ENABLE_DEP(0),
		.ENABLE_COUNTERS(0)
	) u_dut (
		.clock(clock),
		.reset(reset),
		.iaddr(			iaddr),
		.idata(			idata),
		.ivalid(		ivalid),
		.iready(		iready),
		
		.dvalid(		dvalid),
		.daddr(			daddr),
		.dwdata(		dwdata),
		.dwstb(			dwstb),
		.dwrite(		dwrite),
		.drdata(		drdata),
		.dready(		dready),
		`RVFI_CONN
	);

	always @(posedge clock) begin
		if (reset) begin
			assume(!iready);
			assume(!dready);
		end
		if (!ivalid) begin
			assume(!iready);
		end
		if (!dvalid) begin
			assume(!dready);
		end
	end

endmodule

