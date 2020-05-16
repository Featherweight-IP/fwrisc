'''
Created on Feb 1, 2020

@author: ballance
'''
import cocotb
from fwrisc_rv32i_tests.zephyr_tests import ZephyrTests
import pybfms

class ZephyrSynchronizationTest(ZephyrTests):
    
    def __init__(self, tracer_bfm):
        super().__init__(tracer_bfm)
        self.threada_count = 0
        self.threadb_count = 0
        self.sync_limit = 32
        
    def configure_tracer(self):
        super().configure_tracer()

        if "trace_all" in cocotb.plusargs:
            self.tracer_bfm.set_trace_instr(1, 1, 1)
            self.tracer_bfm.set_trace_all_memwrite(1)
            self.tracer_bfm.set_trace_reg_writes(1)
#         self.tracer_bfm.set_trace_instr(1, 1, 1)
#         self.tracer_bfm.set_trace_all_memwrite(1)
#         self.tracer_bfm.set_trace_reg_writes(1)
        
    def console_line(self, line):
        super().console_line(line)
        
        if line == "threadA: Hello World from fwrisc_sim!":
            self.threada_count += 1
        if line == "threadB: Hello World from fwrisc_sim!":
            self.threadb_count += 1
            
        if self.threada_count >= self.sync_limit and self.threadb_count >= self.sync_limit:
            cocotb.log.info("threada_count=%d threadb_count=%d" % (self.threada_count, self.threadb_count))
            self.test_done_ev.set()
    
@cocotb.test()
async def runtest(dut):
    await pybfms.BfmMgr.init()
    tracer_bfm = pybfms.BfmMgr.find_bfm(".*u_tracer")
    test = ZephyrSynchronizationTest(tracer_bfm)
    
    await test.run()    
