'''
Created on Nov 19, 2019

@author: ballance
'''

import cocotb
from cocotb.triggers import Lock, Event, RisingEdge


class FwriscTracerSignalBfm():
    '''
    Implements a signal-level BFM for the FWRISC tracer
    '''
    
    def __init__(self, scope):
        self.listener_l = []
        self.lock = Lock()
        self.ev = Event()
        self.scope = scope
        cocotb.fork(self.run())
        pass

    @cocotb.coroutine
    def run(self):
        while True:
            yield RisingEdge(self.scope.clock)
            
            if self.scope.rd_write and self.scope.rd_waddr != 0:
#                print("reg_write")
                self.reg_write(self.scope.rd_waddr, self.scope.rd_wdata)
            
            if self.scope.ivalid:
#                print("instr_exec")
                self.instr_exec(self.scope.pc, self.scope.instr)
        pass
    
    def add_listener(self, l):
        self.listener_l.append(l)
    
    def instr_exec(self, pc, instr):
        for l in self.listener_l:
            l.instr_exec(pc, instr)
    
    def reg_write(self, waddr, wdata):
        for l in self.listener_l:
            l.reg_write(waddr, wdata)
    
    def mem_write(self, maddr, mstrb, mdata):
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

    def set_trace_all_memwrite(self, t):
        pass
    
    def set_trace_all_instr(self, t):
        pass
    
    def set_trace_reg_writes(self, t):
        pass
    
    
    