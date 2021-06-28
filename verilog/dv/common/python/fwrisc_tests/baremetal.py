'''
Created on Jan 2, 2021

@author: mballance
'''
import cocotb
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection
from fwrisc_tracer_bfm.exec_monitor import ExecMonitor
import pybfms
from fwrisc_tracer_bfm.fwrisc_tracer_bfm_if import FwriscTracerBfmIF
from riscv_debug_bfms.riscv_debug_bfm import RiscvDebugBfm, RiscvDebugTraceLevel

class Tube(object):
    
    def __init__(self, addr):
        self.addr = addr
        self.out = ""

    def memwrite(self, pc, addr, data, mask):
        if addr == self.addr:
            ch = data & 0xFF
            
            if ch != 0:
                if ch == 0xa:
                    print("# " + self.out)
                    self.out = ""
                else:
                    self.out += "%c" % (ch,)
    

@cocotb.test()
async def test(top):
    await pybfms.init()
    
    u_sram = pybfms.find_bfm(".*u_sram")
    u_dbg_bfm : RiscvDebugBfm = pybfms.find_bfm(".*u_dbg", type=RiscvDebugBfm)
    
    sw_image = cocotb.plusargs["sw.image"]
    u_dbg_bfm.load_elf(sw_image)

    # Mask extra events to go fast     
#    u_dbg_bfm.set_trace_level(RiscvDebugTraceLevel.Call)
    
    tube = Tube(u_dbg_bfm.sym2addr("outstr_addr"))
    u_dbg_bfm.add_memwrite_cb(tube.memwrite)
    
    print("Note: loading image " + sw_image)    
    with open(sw_image, "rb") as f:
        elffile = ELFFile(f)
        
        # Find the section that contains the data we need
        section = None
        for i in range(elffile.num_sections()):
            shdr = elffile._get_section_header(i)
            if shdr['sh_size'] != 0 and (shdr['sh_flags'] & 0x2):
                section = elffile.get_section(i)
                data = section.data()
                addr = shdr['sh_addr']
                j = 0
                while j < len(data):
                    word = (data[j+0] << (8*0))
                    word |= (data[j+1] << (8*1)) if j+1 < len(data) else 0
                    word |= (data[j+2] << (8*2)) if j+2 < len(data) else 0
                    word |= (data[j+3] << (8*3)) if j+3 < len(data) else 0
                    u_sram.write_nb(int((addr & 0xFFFFF)/4), word, 0xF)
                    addr += 4
                    j += 4    

    test_pass_addr = u_dbg_bfm.sym2addr("test_pass")
    test_fail_addr = u_dbg_bfm.sym2addr("test_fail")
    
    print("--> wait end_test")
    addr = await u_dbg_bfm.on_entry(("test_pass", "test_fail"))
    print("<-- wait end_test")
    
    print("addr=" + hex(addr) + " test_pass_addr=" + hex(test_pass_addr))
    
    if addr != test_pass_addr:
        raise Exception("Test failed")


        