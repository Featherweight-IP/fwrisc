/****************************************************************************
 * fwrisc_instr_test.svh
 ****************************************************************************/

/**
 * Class: fwrisc_instr_test
 * 
 * TODO: Add class documentation
 */
class fwrisc_instr_test extends fwrisc_test_base;
	`uvm_component_utils(fwrisc_instr_test)
	bit						m_end_test;

	function new(string name="fwrisc_instr_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction
	
	// Listeners that monitor core activity
	virtual task exec(int unsigned addr, int unsigned instr);
		if (addr == 'h8000_0004) begin
			// Hitting this address means the test has ended
			m_run_phase.drop_objection(this, "Main");
			m_end_test = 1;
		end
		super.exec(addr, instr);
	endtask

	function void report_phase(uvm_phase phase);
		string sw_image;
		elf_symtab_reader reader;
		int unsigned start_expected, end_expected;
		
		if (!m_end_test) begin
			m_summary_msg = "Test timed out";
			`uvm_error(get_name(), "Test timed out");
		end
		
		void'($value$plusargs("SW_IMAGE=%s", sw_image));
		reader = new(sw_image);
	
		// Read expected results from the test-software image
		start_expected = reader.get_sym("start_expected");
		end_expected = reader.get_sym("end_expected");
	
		// Check that registers are set appropriately
		for (int i=0; i<(end_expected-start_expected)/4; i+=2) begin
			int unsigned reg_no = elf_data_reader_read32(sw_image, start_expected+(i*4));
			int unsigned reg_val = elf_data_reader_read32(sw_image, start_expected+((i+1)*4));
			
			if (m_reg_written[reg_no] == 0) begin
				`uvm_error(get_name(), $sformatf("Register %0d not written", reg_no));
			end
			if (m_reg_value[reg_no] != reg_val) begin
				`uvm_error(get_name(), $sformatf("Register %0d value 'h%08h != 'h%08h",
						reg_no, m_reg_value[reg_no], reg_val));
			end
		end
		super.report_phase(phase);
	endfunction

endclass


