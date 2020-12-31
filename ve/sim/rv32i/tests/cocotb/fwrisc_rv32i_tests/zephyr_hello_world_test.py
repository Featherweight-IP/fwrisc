'''
Created on Feb 1, 2020

@author: ballance
'''
import cocotb
from fwrisc_rv32i_tests.zephyr_tests import ZephyrTests
from cocotb.bfms import BfmMgr

class ZephyrHelloWorldTest(ZephyrTests):
    
    def __init__(self, tracer_bfm):
        super().__init__(tracer_bfm)
        
    def console_line(self, line):
        super().console_line(line)
        
        if line == "Hello World! fwrisc_sim":
            self.test_done_ev.set()
    
@cocotb.test()
def runtest(dut):
    tracer_bfm = BfmMgr.find_bfm(".*u_tracer")
    test = ZephyrHelloWorldTest(tracer_bfm)
    
    yield test.run()    