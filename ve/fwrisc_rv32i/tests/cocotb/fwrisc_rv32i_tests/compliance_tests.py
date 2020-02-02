'''
Created on Nov 23, 2019

@author: ballance
'''
import cocotb
from cocotb.triggers import Timer
from cocotb.bfms import BfmMgr
from fwrisc_rv32i_tests.instr_tests import InstrTests
from fwrisc_tracer_bfm.fwrisc_tracer_signal_bfm import FwriscTracerSignalBfm
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection


class ComplianceTests(InstrTests):
    
    def __init__(self, tracer_bfm):
        super().__init__(tracer_bfm, mem_size=4096)

    def instr_exec(self, pc, instr):
        InstrTests.instr_exec(self, pc, instr)

    @cocotb.coroutine
    def check(self):
        sw_image = cocotb.plusargs["SW_IMAGE"]
        testname = cocotb.plusargs["TESTNAME"]
        ref_file = cocotb.plusargs["REF_FILE"]
        
        if False:
            yield Timer(0)
        
        with open(sw_image, "rb") as f:
            elffile = ELFFile(f)
            
            symtab = elffile.get_section_by_name('.symtab')
            
            begin_signature = symtab.get_symbol_by_name("begin_signature")[0]["st_value"]
            end_signature = symtab.get_symbol_by_name("end_signature")[0]["st_value"]
            
            cocotb.log.info("Check Results: begin_signature=0x%08x end_signature=0x%08x" %
                            (begin_signature, end_signature))
            
            with open(ref_file, "rb") as ref_fp:
                
                for cnt,line in enumerate(ref_fp):
                    addr = ((begin_signature & 0xFFFF) >> 2) + cnt
                    print("addr=" + str(addr))
                    exp = int(line, 16)
                    actual = self.mem[addr]
                    
                    cocotb.log.info("0x%08x: exp=0x%08x actual=0x%08x" % (4*addr, exp, actual))
                    
                    if exp != actual:
                        raise Exception("Test Failed")
                
            
        
        print("TODO: ComplianceTests.check()")
        yield Timer(0)
        pass
        

@cocotb.test()
def runtest(dut):
    
    tracer_bfm = BfmMgr.find_bfm(".*u_tracer")
    test = ComplianceTests(tracer_bfm)
    tracer_bfm.add_listener(test)
    
#    signal_tracer = FwriscTracerSignalBfm(dut.u_tracer)
    
    yield test.run()
