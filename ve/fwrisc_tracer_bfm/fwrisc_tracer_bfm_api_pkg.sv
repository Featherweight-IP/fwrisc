/****************************************************************************
 * fwrisc_tracer_bfm_api_pkg.sv
 ****************************************************************************/
package fwrisc_tracer_bfm_api_pkg;

	// Class used to communicate from the HDL to the HVL
	class fwrisc_tracer_bfm_api;
		virtual task regwrite(int unsigned raddr, int unsigned rdata);
		endtask
		virtual task exec(int unsigned addr, int unsigned instr);
		endtask
		virtual task memwrite(int unsigned addr, byte unsigned mask, int unsigned data);
		endtask

	endclass
	
	// Interface class used by listeners in the HVL
	interface class fwrisc_tracer_bfm_api_if;
		pure virtual task regwrite(int unsigned raddr, int unsigned rdata);
		pure virtual task exec(int unsigned addr, int unsigned instr);
		pure virtual task memwrite(int unsigned addr, byte unsigned mask, int unsigned data);

	endclass
	
	// Class implementation used to call a listener
	class fwrisc_tracer_bfm_api_closure extends fwrisc_tracer_bfm_api;
        local fwrisc_tracer_bfm_api_if m_if_c;
	
        function new(fwrisc_tracer_bfm_api_if if_c);
        	m_if_c = if_c;
        endfunction
        
		virtual task regwrite(int unsigned raddr, int unsigned rdata);
			m_if_c.regwrite(raddr, rdata);
		endtask
		virtual task exec(int unsigned addr, int unsigned instr);
			m_if_c.exec(addr, instr);
		endtask
		virtual task memwrite(int unsigned addr, byte unsigned mask, int unsigned data);
			m_if_c.memwrite(addr, mask, data);
		endtask

    endclass
	
endpackage
