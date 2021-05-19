'''
Created on May 14, 2021

@author: mballance
'''

import pybfms
import cocotb
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection
from riscv_debug_bfms.riscv_debug_bfm import RiscvDebugBfm
from fwrisc_tests.baremetal_support import BareMetalSupport


class BaremetalTestBase(object):
    
    def __init__(self):
        self.sram_bfm = None
        self.core_dbg_bfms = []
        pass
    
    async def init(self):
        await pybfms.init()
        self.sram_bfm = pybfms.find_bfm(".*u_sram")
        self.core_dbg_bfms.extend(pybfms.find_bfms(".*u_dbg", type=RiscvDebugBfm))
        
        sw_image = cocotb.plusargs["sw.image"]
        
        for bfm in self.core_dbg_bfms:
            bfm.load_elf(sw_image)
            bfm.register_export_api(BareMetalSupport)
            bfm.set_export_impl(BareMetalSupport, BareMetalSupport(bfm.bfm_info.inst_name))
            
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
                        print("Write: " + hex(addr) + " " + hex(word))
                        self.sram_bfm.write_nb(int((addr & 0xFFFFF)/4), word, 0xF)
                        addr += 4
                        j += 4
        
    async def run(self):
        pass
    
    
        