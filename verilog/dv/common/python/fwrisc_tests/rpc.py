'''
Created on Feb 21, 2021

@author: mballance
'''

import cocotb
import pybfms
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection
from fwrisc_tests.baremetal_tube import BaremetalTube
from riscv_debug_bfms.riscv_debug_bfm import RiscvDebugBfm
from fwrisc_tests.baremetal_support import BareMetalSupport


@cocotb.test()
async def entry(top):
    await pybfms.init()
    
    u_sram = pybfms.find_bfm(".*u_sram")
    u_dbg_bfm : RiscvDebugBfm = pybfms.find_bfm(".*u_dbg", type=RiscvDebugBfm)
    
    sw_image = cocotb.plusargs["sw.image"]
    u_dbg_bfm.load_elf(sw_image)

    # Mask extra events to go fast     
#    u_dbg_bfm.set_trace_level(RiscvDebugTraceLevel.Call)
    
    tube = BaremetalTube(u_dbg_bfm.sym2addr("outstr_addr"))
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
                    print("Write: " + hex(addr) + " " + hex(word))
                    u_sram.write_nb(int((addr & 0xFFFFF)/4), word, 0xF)
                    addr += 4
                    j += 4
    
    rpc_syms = [
        "func_c",
        "func_sh",
        "func_i",
        "func_l",
        "func_s"]
    rpc_addrs = {}
   
    u_dbg_bfm.register_export_api(BareMetalSupport)
    
#    for sym in rpc_syms:
#        rpc_addrs[sym] = u_dbg_bfm.sym2addr(sym)
        
#    await u_dbg_bfm.on_entry("vprint");
#    params = u_dbg_bfm.param_iter()
    
#    print("Fmt: " + params.nextstr())
    
#    va = params.nextva()
#    print("Next: " + str(va.nextu32()))
#    print("Next: " + str(va.nextu32()))
#    print("Next: " + str(va.nextu32()))
#    print("Next: " + str(va.nextu32()))

    print("--> await exit-main")
    await u_dbg_bfm.on_exit("main")
    print("<-- await exit-main")
        
    return

    # func_c(1)
#    addr = await u_dbg_bfm.on_entry(rpc_syms)
    
#    if addr != rpc_addrs["func_c"]:
#        raise Exception("Unexpected address")
        
#    v = u_dbg_bfm.param_iter().next8()
#    if v != 1:
#        raise Exception("Expect 1 ; receive " + str(v))
    
#    addr = await u_dbg_bfm.on_entry(rpc_syms)
    
#    if addr != rpc_addrs["func_c"]:
#        raise Exception("Unexpected address")
    
#    v = u_dbg_bfm.param_iter().next8()

#    if v != -1:
#        raise Exception("Expect -1 ; receive " + str(v))
        
#    addr = await u_dbg_bfm.on_entry(rpc_syms)
    
#    if addr != rpc_addrs["func_s"]:
#        raise Exception("Unexpected address")
    
#    v = u_dbg_bfm.param_iter().nextstr()
    
#    print("v=" + str(v))
    
    