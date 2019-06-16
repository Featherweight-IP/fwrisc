'''
Created on Jun 2, 2019

@author: ballance
'''

import hpi

print("fwrisc_tracer_bfm")

@hpi.bfm
class fwrisc_tracer_bfm():
    
    def __init__(self):
        self.listeners = []

    @hpi.export_task()
    def dumpregs(self):
        pass
  
    @hpi.import_task("iuiu")
    def regwrite(self, raddr, rdata):
        for l in self.listeners:
            try:
                l.regwrite(raddr, rdata)
            except:
                print("Error: failed to call regwrite on listener \"" + str(l) + "\"")
                raise

    @hpi.import_task("iuiu")
    def exec(self, addr, instr):
        for l in self.listeners:
            try:
                l.exec(addr, instr)
            except:
                print("Error: failed to call regwrite on listener \"" + str(l) + "\"")
                raise

    @hpi.import_task("iuiuiu")
    def memwrite(self, addr, mask, data):
        for l in self.listeners:
            try:
                l.exec(addr, mask, data)
            except:
                print("Error: failed to call regwrite on listener \"" + str(l) + "\"")
                raise
    
impl = '''
module fwrisc_tracer_bfm(
        input            clock,
        input            reset,
        input [31:0]    pc,
        input [31:0]    instr,
        input            ivalid,
        // ra, rb
        input [5:0]        ra_raddr,
        input [31:0]    ra_rdata,
        input [5:0]        rb_raddr,
        input [31:0]    rb_rdata,
        // rd
        input [5:0]        rd_waddr,
        input [31:0]    rd_wdata,
        input            rd_write,
        
        input [31:0]    maddr,
        input [31:0]    mdata,
        input [3:0]        mstrb,
        input            mwrite,
        input             mvalid        
        );

    wire [31:0]        pc;
    wire [31:0]        instr;
    wire            ivalid;
    // ra, rb
    wire [5:0]        ra_raddr;
    wire [31:0]        ra_rdata;
    wire [5:0]        rb_raddr;
    wire [31:0]        rb_rdata;
    // rd
    wire [5:0]        rd_waddr;
    wire [31:0]        rd_wdata;
    wire            rd_write;

    wire [31:0]        maddr;
    wire [31:0]        mdata;
    wire [3:0]        mstrb;
    wire            mwrite;
    wire             mvalid;

    int unsigned                m_id;
    
    import "DPI-C" context function int unsigned fwrisc_tracer_bfm_register(string path);
    
    initial begin
        $display("TRACER: %m");
        m_id = fwrisc_tracer_bfm_register($sformatf("%m"));
    end

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

    always @(posedge clock) begin
        if (rd_write) begin
            regwrite(rd_waddr, rd_wdata);
        end
    end

    always @(posedge clock) begin
        if (ivalid) begin
            exec(pc, instr);
        end
    end

    always @(posedge clock) begin
        if (mvalid && mwrite) begin
            memwrite(maddr, mstrb, mdata);
        end
    end    
endmodule

'''
