/****************************************************************************
 * fwrisc_rv32i.sv
 ****************************************************************************/

/**
 * Module: fwrisc_rv32i
 * 
 * FWRISC RV32I configuration
 */
module fwrisc_rv32i(
		input			clock,
		input			reset,
		
		output[31:0]	iaddr,
		input[31:0]		idata,
		output			ivalid,
		input			iready,
		
		output			dvalid,
		output[31:0]	daddr,
		output[31:0]	dwdata,
		output[3:0]		dwstb,
		output			dwrite,
		input[31:0]		drdata,
		input			dready,
		input			irq,
		// RVFI interface signals
		output[0:0] 	rvfi_valid,
		output[63:0] 	rvfi_order,
		output[31:0] 	rvfi_insn,
		output[0:0]		rvfi_trap,
		output[0:0] 	rvfi_halt,
		output[0:0]		rvfi_intr,
		output[1:0]		rvfi_mode,
		output[1:0]		rvfi_ixl,
		output[4:0]		rvfi_rs1_addr,
		output[4:0]		rvfi_rs2_addr,
		output[31:0]	rvfi_rs1_rdata,
		output[31:0] 	rvfi_rs2_rdata,
		output[4:0] 	rvfi_rd_addr,
		output[31:0] 	rvfi_rd_wdata,
		output[31:0]	rvfi_pc_rdata,
		output[31:0]	rvfi_pc_wdata,
		output[31:0]	rvfi_mem_addr,
		output[3:0] 	rvfi_mem_rmask,
		output[3:0]		rvfi_mem_wmask,
		output[31:0]	rvfi_mem_rdata,
		output[31:0]	rvfi_mem_wdata		
		);
	
	fwrisc #(
		.ENABLE_COMPRESSED  (0), 
		.ENABLE_MUL_DIV     (0), 
		.ENABLE_DEP         (0), 
		.ENABLE_COUNTERS    (1)
		) u_core (
		.clock              (clock             ), 
		.reset              (reset             ), 
		.iaddr              (iaddr             ), 
		.idata              (idata             ), 
		.ivalid             (ivalid            ), 
		.iready             (iready            ), 
		.dvalid             (dvalid            ), 
		.daddr              (daddr             ), 
		.dwdata             (dwdata            ), 
		.dwstb              (dwstb             ), 
		.dwrite             (dwrite            ), 
		.drdata             (drdata            ), 
		.dready             (dready            ),
		.irq				(irq               ),
		.rvfi_valid			(rvfi_valid        ),
		.rvfi_order			(rvfi_order			),
		.rvfi_insn			(rvfi_insn			),
		.rvfi_trap			(rvfi_trap			),
		.rvfi_halt			(rvfi_halt			),
		.rvfi_intr			(rvfi_intr			),
		.rvfi_mode			(rvfi_mode			),
		.rvfi_ixl			(rvfi_ixl			),
		.rvfi_rs1_addr		(rvfi_rs1_addr		),
		.rvfi_rs2_addr		(rvfi_rs2_addr		),
		.rvfi_rs1_rdata		(rvfi_rs1_rdata		),
		.rvfi_rs2_rdata		(rvfi_rs2_rdata		),
		.rvfi_rd_addr		(rvfi_rd_addr		),
		.rvfi_rd_wdata		(rvfi_rd_wdata		),
		.rvfi_pc_rdata		(rvfi_pc_rdata		),
		.rvfi_pc_wdata		(rvfi_pc_wdata		),
		.rvfi_mem_addr		(rvfi_mem_addr		),
		.rvfi_mem_rmask		(rvfi_mem_rmask		),
		.rvfi_mem_wmask		(rvfi_mem_wmask		),
		.rvfi_mem_rdata		(rvfi_mem_rdata		),
		.rvfi_mem_wdata		(rvfi_mem_wdata		)		
		);

endmodule


