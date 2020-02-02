'''
Created on Nov 23, 2019

@author: ballance
'''
import cocotb
from cocotb.bfms import BfmMgr
from fwrisc_rv32i_tests.instr_tests import InstrTests
from fwrisc_tracer_bfm.fwrisc_tracer_signal_bfm import FwriscTracerSignalBfm

from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection
from sys import stdout


class ZephyrTests(InstrTests):
    
    def __init__(self, tracer_bfm):
        super().__init__(tracer_bfm)
        
        self.max_instr = 0
        self.halt_addr = -1
        
        tracer_bfm.add_listener(self)
        
        sw_image = cocotb.plusargs["SW_IMAGE"]

        self.raw_console = False
        self.console_buffer = ""        
        self.console_output = []
        with open(sw_image, "rb") as f:
            elffile = ELFFile(f)
            
            symtab = elffile.get_section_by_name(".symtab")
            
            self.ram_console_addr = symtab.get_symbol_by_name("ram_console")[0]["st_value"]
            tracer_bfm.add_addr_region(self.ram_console_addr, self.ram_console_addr+1023)
            
    def configure_tracer(self):
        self.tracer_bfm.set_trace_reg_writes(0)
        self.tracer_bfm.set_trace_instr(0, 0, 0)
        self.tracer_bfm.set_trace_all_memwrite(0)
        
        self.tracer_bfm.add_addr_region(
            self.ram_console_addr,
            self.ram_console_addr+1023)
        
    def mem_write(self, maddr, mstrb, mdata):
        if maddr >= self.ram_console_addr and maddr < self.ram_console_addr+1024 and mdata != 0:
            ch = 0
            if mstrb == 1:
                ch = ((mdata >> 0) & 0xFF)
            elif mstrb == 2:
                ch = ((mdata >> 8) & 0xFF)
            elif mstrb == 4:
                ch = ((mdata >> 16) & 0xFF)
            elif mstrb == 8:
                ch = ((mdata >> 24) & 0xFF)
                
            ch = str(chr(ch))
            if ch == '\n':
                self.console_line(self.console_buffer)
                if not self.raw_console:
                    print(self.console_buffer)
                    stdout.flush()
                self.console_buffer = ""
            else:
                self.console_buffer += ch
                
            if self.raw_console:
                stdout.write(ch)
                stdout.flush()

    def console_line(self, line):
        self.console_output.append(line)
        

    @cocotb.coroutine
    def run(self):
        # Configure the tracer BFM
        self.configure_tracer()
        
        yield self.test_done_ev.wait()
        pass

    @cocotb.coroutine        
    def check(self):
        print("Check")
        pass
        

@cocotb.test()
def runtest(dut):
    use_tf_bfm = True
   
    if use_tf_bfm: 
        tracer_bfm = BfmMgr.find_bfm(".*u_tracer")
    else:
        tracer_bfm = FwriscTracerSignalBfm(dut.u_dut.u_core.u_tracer)
    test = ZephyrTests(tracer_bfm)
    
    
    yield test.run()
    
