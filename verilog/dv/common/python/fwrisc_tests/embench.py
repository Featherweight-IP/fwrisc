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

@cocotb.test()
async def test(top):
    await pybfms.init()
    
    u_sram = pybfms.find_bfm(".*u_sram")
    u_dbg_bfm : RiscvDebugBfm = pybfms.find_bfm(".*u_dbg", type=RiscvDebugBfm)
    
    sw_image = cocotb.plusargs["sw.image"]
    u_dbg_bfm.load_elf(sw_image)

    print("Note: loading image " + sw_image)    
    with open(sw_image, "rb") as f:
        elffile = ELFFile(f)
        
        # Find the section that contains the data we need
        section = None
        for i in range(elffile.num_sections()):
            shdr = elffile._get_section_header(i)
#            print("sh_addr=" + hex(shdr['sh_addr']) + " sh_size=" + hex(shdr['sh_size']) + " flags=" + hex(shdr['sh_flags']))
#            print("  keys=" + str(shdr.keys()))
            print("sh_size=" + hex(shdr['sh_size']) + " sh_flags=" + hex(shdr['sh_flags']))
            if shdr['sh_size'] != 0 and (shdr['sh_flags'] & 0x2) == 0x2:
                section = elffile.get_section(i)
                data = section.data()
                addr = shdr['sh_addr']
                j = 0
                while j < len(data):
                    word = (data[j+0] << (8*0))
                    word |= (data[j+1] << (8*1)) if j+1 < len(data) else 0
                    word |= (data[j+2] << (8*2)) if j+2 < len(data) else 0
                    word |= (data[j+3] << (8*3)) if j+3 < len(data) else 0
                    print("Write: " + hex(addr) + "(" + hex(int((addr & 0xFFFFF)/4)) + ") " + hex(word))
                    u_sram.write_nb(int((addr & 0xFFFFF)/4), word, 0xF)
                    addr += 4
                    j += 4    

    print("--> wait main")
    await u_dbg_bfm.on_exit("main")
    print("<-- wait main")
   
    print("--> wait start_trigger")
    await u_dbg_bfm.on_exit("start_trigger")
    print("<-- wait start_trigger")
    
    print("--> wait stop_trigger")
    await u_dbg_bfm.on_exit("stop_trigger")
    print("<-- wait stop_trigger")
    

        
        