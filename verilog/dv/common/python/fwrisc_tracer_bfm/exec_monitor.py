'''
Created on Dec 31, 2020

@author: mballance
'''
from fwrisc_tracer_bfm.fwrisc_tracer_bfm_if import FwriscTracerBfmIF
import pybfms

class ExecMonitor(FwriscTracerBfmIF):
    
    def __init__(self):
        self.addr_s = {}
        self.iaddr = 0
        self.count = 0
        self.timeout = 0
        self.ev = pybfms.event()
        
    async def wait_exec(self, addr_s, timeout=-1):
        self.addr_s = addr_s
        self.count = 0
        self.timeout = timeout
        await self.ev.wait()
        self.ev.clear()
        return self.iaddr
        
    def instr_exec(self, pc, instr):
#        print("instr_exec: " + hex(pc))
        if pc in self.addr_s:
            self.iaddr = pc
            self.ev.set()
        self.count += 1
        if self.timeout != -1 and self.count > self.timeout:
            self.iaddr = -1
            self.ev.set()
        