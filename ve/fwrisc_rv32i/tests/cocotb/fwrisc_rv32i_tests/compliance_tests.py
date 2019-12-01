'''
Created on Nov 23, 2019

@author: ballance
'''
import cocotb
from cocotb.bfms import BfmMgr
from fwrisc_rv32i_tests.instr_tests import InstrTests
from fwrisc_tracer_bfm.fwrisc_tracer_signal_bfm import FwriscTracerSignalBfm


class ComplianceTests(InstrTests):
    
    def __init__(self, tracer_bfm):
        super().__init__(tracer_bfm)

    def instr_exec(self, pc, instr):
        InstrTests.instr_exec(self, pc, instr)
        

@cocotb.test()
def runtest(dut):
    
    tracer_bfm = BfmMgr.find_bfm(".*u_tracer")
    test = ComplianceTests(tracer_bfm)
    tracer_bfm.add_listener(test)
    
#    signal_tracer = FwriscTracerSignalBfm(dut.u_tracer)
    
    yield test.run()
    