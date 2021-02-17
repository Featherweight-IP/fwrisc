'''
Created on Feb 1, 2020

@author: ballance
'''
import cocotb
from fwrisc_rv32i_tests.zephyr_tests import ZephyrTests
from cocotb.bfms import BfmMgr

class ZephyrPhilosophersTest(ZephyrTests):
    
    def __init__(self, tracer_bfm):
        super().__init__(tracer_bfm)
        self.threada_count = 0
        self.threadb_count = 0
        self.sync_limit = 64
        # Philosophers controls the console directly
        self.raw_console = True
        self.holding = 0
        self.holding_max = 50
        
    def configure_tracer(self):
        super().configure_tracer()
        if "trace_all" in cocotb.plusargs:
            self.tracer_bfm.set_trace_instr(1, 1, 1)
            self.tracer_bfm.set_trace_all_memwrite(1)
            self.tracer_bfm.set_trace_reg_writes(1)
        
    def console_line(self, line):
        super().console_line(line)
        
        if line.find("HOLDING ONE FORK") != -1:
            self.holding += 1
            
        if self.holding >= self.holding_max:
            self.test_done_ev.set()
    
@cocotb.test()
def runtest(dut):
    tracer_bfm = BfmMgr.find_bfm(".*u_tracer")
    test = ZephyrPhilosophersTest(tracer_bfm)
    
    yield test.run()    