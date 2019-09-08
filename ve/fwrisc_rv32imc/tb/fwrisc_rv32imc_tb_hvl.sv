/****************************************************************************
 * fwrisc_rv32imc_tb_hvl.sv
 ***************************************************************************/
 
`ifdef HAVE_UVM
	`include "uvm_macros.svh"
`endif

/**
 * Module: fwrisc_rv32imc_tb_hvl
 *
 * TODO: Add module documentation
 */
module fwrisc_rv32imc_tb_hvl;
	`ifdef HAVE_UVM
		import uvm_pkg::*;
		import googletest_uvm_pkg::*;
	`endif

	initial begin
		`ifdef HAVE_UVM
			run_test("googletest_uvm_test");
		`else
			googletest_sv_pkg::run_all_tests();
		`endif /* HAVE_UVM */
	end

endmodule
 