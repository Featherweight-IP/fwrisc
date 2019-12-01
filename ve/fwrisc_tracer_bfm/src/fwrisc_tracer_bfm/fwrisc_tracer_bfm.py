'''
Created on Nov 19, 2019

@author: ballance
'''

import cocotb
from cocotb.bfms import bfm_hdl_path
from cocotb.decorators import bfm_vlog, bfm_sv
from cocotb.triggers import Lock, Event


@cocotb.bfm(hdl={
    bfm_vlog : bfm_hdl_path(__file__, "hdl/fwrisc_tracer_bfm.v"),
    bfm_sv : bfm_hdl_path(__file__, "hdl/fwrisc_tracer_bfm.v")
    })
class FwriscTracerBfm():
    
    def __init__(self):
        self.listener_l = []
        self.lock = Lock()
        self.ev = Event()
        self.addr_region_idx = 0
        pass
    
    def add_listener(self, l):
        self.listener_l.append(l)
        
    def add_addr_region(self, base, limit):
        self.set_addr_region(
            self.addr_region_idx,
            base,
            limit,
            1)
        self.addr_region_idx += 1
    
    @cocotb.bfm_export(cocotb.bfm_uint32_t, cocotb.bfm_uint32_t)
    def instr_exec(self, pc, instr):
#        print("instr_exec: " + hex(pc))
        for l in self.listener_l:
            l.instr_exec(pc, instr)
    
    @cocotb.bfm_export(cocotb.bfm_uint32_t, cocotb.bfm_uint32_t)
    def reg_write(self, waddr, wdata):
#        print("reg_write: " + hex(waddr))
        for l in self.listener_l:
            l.reg_write(waddr, wdata)
    
    @cocotb.bfm_export(cocotb.bfm_uint32_t, cocotb.bfm_uint32_t, cocotb.bfm_uint32_t)
    def mem_write(self, maddr, mstrb, mdata):
#        print("mem_write: " + hex(maddr))
        for l in self.listener_l:
            l.mem_write(maddr, mstrb, mdata)
            
    @cocotb.coroutine
    def get_reg_info(self, raddr):
        yield self.lock.acquire()
        self.get_reg_info_req(raddr)
        yield self.ev.wait()
        ret = self.ev.data
        self.ev.clear()
        self.lock.release()
        return ret

    @cocotb.bfm_import(cocotb.bfm_uint32_t)
    def get_reg_info_req(self, raddr):
        pass
    
    @cocotb.bfm_import(cocotb.bfm_uint32_t, cocotb.bfm_uint32_t, cocotb.bfm_uint32_t, cocotb.bfm_uint32_t)
    def set_addr_region(self, i, base, limit, valid):
        pass
    
    @cocotb.bfm_export(cocotb.bfm_uint32_t, cocotb.bfm_uint32_t)
    def get_reg_info_ack(self, rdata, accessed):
        self.ev.set((rdata, accessed))
    
    @cocotb.bfm_import(cocotb.bfm_uint32_t)
    def set_trace_all_memwrite(self, t):
        pass
    
    @cocotb.bfm_import(cocotb.bfm_uint32_t, cocotb.bfm_uint32_t, cocotb.bfm_uint32_t)
    def set_trace_instr(self, all_instr, jump_instr, call_instr):
        pass
    
    @cocotb.bfm_import(cocotb.bfm_uint32_t)
    def set_trace_reg_writes(self, t):
        pass
    
    
    
