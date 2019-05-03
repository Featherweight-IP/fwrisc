/****************************************************************************
 * fwrisc_riscv_compliance_tests.svh
 ****************************************************************************/

/**
 * Class: fwrisc_riscv_compliance_tests
 * 
 * TODO: Add class documentation
 */
class fwrisc_riscv_compliance_tests extends fwrisc_test_base;
	`uvm_component_utils(fwrisc_riscv_compliance_tests)
	uvm_phase			m_run_phase;

	function new(string name="fwrisc_riscv_compliance_tests", uvm_component parent=null);
		super.new(name, parent);
	endfunction
	

	// Listeners that monitor core activity
	virtual task memwrite(int unsigned addr, byte unsigned mask, int unsigned data);
		if (addr == 'h80001000) begin
			m_run_phase.drop_objection(this, "Main");
		end else begin
			super.memwrite(addr, mask, data);
		end
	endtask

	task run_phase(uvm_phase phase);
		m_run_phase = phase;
		
		// Raise an objection to keep the test running
		phase.raise_objection(this, "Main");
	endtask
	
	function void report_phase(uvm_phase phase);
		
		super.report_phase(phase);
	endfunction

endclass


