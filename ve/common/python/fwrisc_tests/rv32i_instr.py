'''
Created on Dec 30, 2020

@author: mballance
'''

import cocotb
import pybfms
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection
from fwrisc_tracer_bfm.exec_monitor import ExecMonitor


@cocotb.test()
async def test(top):
    print("Hello World")
   
    await pybfms.init()
#     await pybfms.delta()
#     await pybfms.delta()
#     await pybfms.delta()
    
    print("plusargs: " + str(cocotb.plusargs))
    
    u_sram = pybfms.find_bfm(".*u_sram")
    u_tracer = pybfms.find_bfm(".*u_tracer")
    print("u_sram=" + str(u_sram))
    
    mon = ExecMonitor()
    u_tracer.add_listener(mon)
    
    sw_image = cocotb.plusargs["sw.image"]

    with open(sw_image, "rb") as f:
        elffile = ELFFile(f)
            
        # Find the section that contains the data we need
        section = None
        for i in range(elffile.num_sections()):
            shdr = elffile._get_section_header(i)
            print("sh_addr=" + hex(shdr['sh_addr']) + " sh_size=" + hex(shdr['sh_size']) + " flags=" + hex(shdr['sh_flags']))
            print("  keys=" + str(shdr.keys()))
            if shdr['sh_size'] != 0 and shdr['sh_flags'] != 0:
                section = elffile.get_section(i)
                break
               
        data = section.data()
        addr = 0
        while addr < len(data):
            word = (data[addr+0] << (8*0))
            word |= (data[addr+1] << (8*1)) if addr+1 < len(data) else 0
            word |= (data[addr+2] << (8*2)) if addr+2 < len(data) else 0
            word |= (data[addr+3] << (8*3)) if addr+3 < len(data) else 0
            u_sram.write_nb(int(addr/4), word, 0xF)
            addr += 4

    addr = await mon.wait_exec({0x80000004}, 100)
    
    if addr == -1:
        # Timeout
        pass
    
    print("addr=" + str(addr))
    
    
    
    