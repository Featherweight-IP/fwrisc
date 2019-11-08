/****************************************************************************
 * fwrisc_test_base.svh
 ****************************************************************************/

/**
 * Class: fwrisc_test_base
 * 
 * Base test for FWRISC. Captures 
 */
class fwrisc_test_base extends uvm_test 
		implements fwrisc_tracer_bfm_api_if;
	`uvm_component_utils(fwrisc_test_base)
	
	uvm_phase			m_run_phase;
	string				m_summary_msg;
	bit					m_reg_written[int unsigned];
	int unsigned		m_reg_value[int unsigned];
	int unsigned		m_memory[1024];

	function new(string name="fwrisc_test_base", uvm_component parent=null);
		super.new(name, parent);
		
		for (int i=0; i<64; i++) begin
			m_reg_written[i] = 0;
			m_reg_value[i] = 0;
		end
	endfunction
	

	// Listeners that monitor core activity
	virtual task regwrite(int unsigned raddr, int unsigned rdata);
		// Save the written register value
		m_reg_written[raddr] = 1;
		m_reg_value[raddr] = rdata;
	endtask
	
	virtual task exec(int unsigned addr, int unsigned instr);
		// Do nothing
	endtask
	
	virtual task memwrite(int unsigned addr, byte unsigned mask, int unsigned data);
		if ((addr & 'hFFFF_8000) == 'h8000_0000) begin
			m_memory[(addr & 'hFFFF)] = data;
		end else begin
			`uvm_error(get_name(), $sformatf("illegal access to address 'h%08h", addr));
		end
	endtask

	function void connect_phase(uvm_phase phase);
		virtual fwrisc_tracer_core tracer;
	
		// Connect up to the tracer BFM
		uvm_config_db #(virtual fwrisc_tracer_core)::get(
				this, "", "tracer", tracer);
		
		tracer.m_api = fwrisc_tracer_bfm_api_closure::new(this);
	endfunction
	
	task run_phase(uvm_phase phase);
		m_run_phase = phase;
		// Raise an objection to keep the test running
		phase.raise_objection(this, "Main");
	endtask
	
	function void report_phase(uvm_phase phase);
		string testname;
		uvm_report_server srv = uvm_top.get_report_server();
		int num_errors, num_warnings;
		
		if (!$value$plusargs("TESTNAME=%s", testname)) begin
			`uvm_fatal(get_name(), "No +TESTNAME specified");
		end
		
		num_errors = srv.get_severity_count(UVM_ERROR);
		num_warnings = srv.get_severity_count(UVM_WARNING);
	
		if (num_errors != 0 || num_warnings != 0) begin
			if (m_summary_msg == "") begin
				m_summary_msg = $sformatf("%0d errors and %0d warnings", num_errors, num_warnings);
			end
			`uvm_info(get_name(), $sformatf("FAILED: %0s (%0s)", testname, m_summary_msg), UVM_LOW);
		end else begin
			`uvm_info(get_name(), $sformatf("PASSED: %0s", testname), UVM_LOW);
		end
		
	endfunction

endclass


