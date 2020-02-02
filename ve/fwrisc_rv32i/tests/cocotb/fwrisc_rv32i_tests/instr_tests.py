'''
Created on Nov 20, 2019

@author: ballance
'''
import cocotb
from cocotb.triggers import RisingEdge, Event
from cocotb.bfms import BfmMgr
from fwrisc_tracer_bfm import FwriscTracerBfmIF
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection
from fwrisc_tracer_bfm.fwrisc_tracer_signal_bfm import FwriscTracerSignalBfm

class InstrTests(FwriscTracerBfmIF):
    
    def __init__(self, tracer_bfm, mem_size=1024, halt_addr=0x80000004, max_instr=1000000):
        self.instr_count = 0
        self.test_done_ev = Event()
        self.halt_addr = halt_addr
        self.max_instr = max_instr
        self.complete = False
        self.tracer_bfm = tracer_bfm
        self.mem = [0] * mem_size
        
        self.trace_instr = "trace_instr" in cocotb.plusargs
        self.trace_memwrite = "trace_memwrite" in cocotb.plusargs
        

    def init_mem(self):
        pass
            
    def configure_tracer(self):
        self.tracer_bfm.set_trace_reg_writes(0)
        self.tracer_bfm.set_trace_instr(1, 1, 1)
        self.tracer_bfm.set_trace_all_memwrite(1)

    def instr_exec(self, pc, instr):
        if self.trace_instr:
            cocotb.log.info("[InstrExec] addr=0x%08x instr=0x%08x" % (pc, instr))
        self.instr_count += 1
        
        if self.halt_addr != -1 and pc == self.halt_addr:
            print("Done!")
            self.complete = True
            self.test_done_ev.set()
        
        if self.max_instr != 0 and self.instr_count >= self.max_instr:
            print("TIMEOUT")
            self.test_done_ev.set()
            
    def mem_write(self, maddr, mstrb, mdata):
       
        if self.trace_memwrite: 
            cocotb.log.info("[MemWrite] maddr=%08x mstrb=%x mdata=%08x" % (maddr, mstrb, mdata))
        
        if ((maddr & 0xFFFF8000) == 0x80000000):
            offset = ((maddr & 0x0000FFFF) >> 2)

            for i in range(4):            
                if (mstrb & (1 << i)) != 0:
                    self.mem[offset] &= ~(0xFF << (8*i))
                    self.mem[offset] |= (mdata & (0xFF << (8*i)))
        else:
            print("Error: out-of-bounds access")
            
    @cocotb.coroutine
    def run(self):
        self.configure_tracer()
        self.init_mem()

        yield self.test_done_ev.wait()
        
        yield self.check()

    @cocotb.coroutine
    def check(self):
        reg_data = []
        
        sw_image = cocotb.plusargs["SW_IMAGE"]
        testname = cocotb.plusargs["TESTNAME"]
        print("SW_IMAGE=" + sw_image)
        
        with open(sw_image, "rb") as f:
            elffile = ELFFile(f)
            
            symtab = elffile.get_section_by_name('.symtab')
            start_expected = symtab.get_symbol_by_name("start_expected")[0]["st_value"]
            end_expected = symtab.get_symbol_by_name("end_expected")[0]["st_value"]

            section = None       
            for i in range(elffile.num_sections()):
                shdr = elffile._get_section_header(i)
                if (start_expected >= shdr['sh_addr']) and (end_expected <= (shdr['sh_addr'] + shdr['sh_size'])):
                    start_expected -= shdr['sh_addr']
                    end_expected -= shdr['sh_addr']
                    section = elffile.get_section(i)
                    break

            data = section.data()
            
            exp_l = []
            
            for i in range(start_expected,end_expected,8):
                reg = data[i+0] | (data[i+1] << 8) | (data[i+2] << 16) | (data[i+3] << 24)
                exp = data[i+4] | (data[i+5] << 8) | (data[i+6] << 16) | (data[i+7] << 24)
                
                exp_l.append([reg, exp])        
        
        for i in range(64):
            info = yield self.tracer_bfm.get_reg_info(i)
            reg_data.append(info)
        
        if not self.complete:
            print("FAIL: " + testname)
        else:
            print("PASS: " + testname)
            

@cocotb.test()
def runtest(dut):
#     print("--> runtest")
#     yield RisingEdge(dut.clock)
#     print("<-- runtest")
#     
#     BfmMgr.init()
#     
#     bfms = BfmMgr.get_bfms()
#     for b in bfms:
#         print("BFM: " + b.bfm_info.inst_name)
#         
    tracer_bfm = BfmMgr.find_bfm(".*u_tracer")
    test = InstrTests(tracer_bfm)
    tracer_bfm.add_listener(test)
    
#    signal_tracer = FwriscTracerSignalBfm(dut.u_tracer)
    
    yield test.run()
    
    
