/****************************************************************************
 * fwrisc_tracer_bfm_api.svh
 ****************************************************************************/

`ifdef HAVE_HDL_VIRTUAL_INTERFACE
import fwrisc_tracer_bfm_api_pkg::*;
	fwrisc_tracer_bfm_api					m_api;
`else
	int unsigned				m_id;
	
	import "DPI-C" context function int unsigned fwrisc_tracer_bfm_register(string path);
	
	initial begin
		$display("TRACER: %m");
		m_id = fwrisc_tracer_bfm_register($sformatf("%m"));
	end
`endif

`ifdef HAVE_HDL_VIRTUAL_INTERFACE
    task regwrite(int unsigned raddr, int unsigned rdata);
        m_api.regwrite(raddr, rdata);
    endtask
    task exec(int unsigned addr, int unsigned instr);
        m_api.exec(addr, instr);
    endtask
    task memwrite(int unsigned addr, byte unsigned mask, int unsigned data);
        m_api.memwrite(addr, mask, data);
    endtask

`else
    export "DPI-C" task fwrisc_tracer_bfm_dumpregs;

    task regwrite(int unsigned raddr, int unsigned rdata);
        fwrisc_tracer_bfm_regwrite(m_id, raddr, rdata);
    endtask
    import "DPI-C" context task fwrisc_tracer_bfm_regwrite(int unsigned id, int unsigned raddr, int unsigned rdata);
    task exec(int unsigned addr, int unsigned instr);
        fwrisc_tracer_bfm_exec(m_id, addr, instr);
    endtask
    import "DPI-C" context task fwrisc_tracer_bfm_exec(int unsigned id, int unsigned addr, int unsigned instr);
    task memwrite(int unsigned addr, byte unsigned mask, int unsigned data);
        fwrisc_tracer_bfm_memwrite(m_id, addr, mask, data);
    endtask
    import "DPI-C" context task fwrisc_tracer_bfm_memwrite(int unsigned id, int unsigned addr, byte unsigned mask, int unsigned data);

`endif

