/****************************************************************************
 * fwrisc_tests_pkg.sv
 ****************************************************************************/
`ifdef HAVE_UVM
`include "uvm_macros.svh"

/**
 * Package: fwrisc_tests_pkg
 * 
 * TODO: Add package documentation
 */
package fwrisc_tests_pkg;
	import uvm_pkg::*;
	import fwrisc_tracer_bfm_api_pkg::*;
	
	`include "elf_symtab_reader.svh"

	`include "fwrisc_test_base.svh"
	`include "fwrisc_instr_test.svh"
	`include "fwrisc_riscv_compliance_tests.svh"


endpackage

`endif
