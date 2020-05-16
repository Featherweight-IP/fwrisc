'''
Created on Nov 19, 2019

@author: ballance
'''

import pybfms


@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/fwrisc_tracer_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/fwrisc_tracer_bfm.v")
    })
class FwriscTracerBfm():
    
    def __init__(self):
        self.listener_l = []
        self.lock = pybfms.lock()
        self.ev = pybfms.event()
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
    
    @pybfms.export_task(pybfms.uint32_t, pybfms.uint32_t)
    def instr_exec(self, pc, instr):
#        print("instr_exec: " + hex(pc))
        for l in self.listener_l:
            l.instr_exec(pc, instr)
    
    @pybfms.export_task(pybfms.uint32_t, pybfms.uint32_t)
    def reg_write(self, waddr, wdata):
#        print("reg_write: " + hex(waddr))
        for l in self.listener_l:
            l.reg_write(waddr, wdata)
    
    @pybfms.export_task(pybfms.uint32_t, pybfms.uint32_t, pybfms.uint32_t)
    def mem_write(self, maddr, mstrb, mdata):
#        print("mem_write: " + hex(maddr))
        for l in self.listener_l:
            l.mem_write(maddr, mstrb, mdata)
            
    async def get_reg_info(self, raddr):
        await self.lock.acquire()
        self.get_reg_info_req(raddr)
        await self.ev.wait()
        ret = self.ev.data
        self.ev.clear()
        self.lock.release()
        return ret

    @pybfms.import_task(pybfms.uint32_t)
    def get_reg_info_req(self, raddr):
        pass
    
    @pybfms.import_task(pybfms.uint32_t, pybfms.uint32_t, pybfms.uint32_t, pybfms.uint32_t)
    def set_addr_region(self, i, base, limit, valid):
        pass
    
    @pybfms.export_task(pybfms.uint32_t, pybfms.uint32_t)
    def get_reg_info_ack(self, rdata, accessed):
        self.ev.set((rdata, accessed))
    
    @pybfms.import_task(pybfms.uint32_t)
    def set_trace_all_memwrite(self, t):
        pass
    
    @pybfms.import_task(pybfms.uint32_t, pybfms.uint32_t, pybfms.uint32_t)
    def set_trace_instr(self, all_instr, jump_instr, call_instr):
        pass
    
    @pybfms.import_task(pybfms.uint32_t)
    def set_trace_reg_writes(self, t):
        pass
    
    
    
