'''
Created on Dec 30, 2020

@author: mballance
'''

import cocotb
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection
from fwrisc_tracer_bfm.exec_monitor import ExecMonitor
from gpio_bfms import GpioBfm
import pybfms


@cocotb.test()
async def test(top):
   
    await pybfms.init()
#     await pybfms.delta()
#     await pybfms.delta()
#     await pybfms.delta()
    
    u_sram = pybfms.find_bfm(".*u_sram")
    u_dbg_bfm = pybfms.find_bfm(".*u_dbg_bfm")

    u_irq_bfm : GpioBfm = pybfms.find_bfm(".*u_irq_bfm")
    
    async def irq_toggle():
        while True:
            await cocotb.triggers.Timer(10, "us")
            u_irq_bfm.set_gpio_out_bit(0, 1)
            await cocotb.triggers.Timer(10, "us")
            u_irq_bfm.set_gpio_out_bit(0, 0)
    
    cocotb.fork(irq_toggle())
    
#    mon = ExecMonitor()
#    u_tracer.add_listener(mon)
    
    sw_image = cocotb.plusargs["sw.image"]
    exp_l    = []
    reg_data = []
    
    u_dbg_bfm.load_elf(sw_image)

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
            
          
        for i in range(start_expected,end_expected,8):
            reg = data[i+0] | (data[i+1] << 8) | (data[i+2] << 16) | (data[i+3] << 24)
            exp = data[i+4] | (data[i+5] << 8) | (data[i+6] << 16) | (data[i+7] << 24)
                
            exp_l.append([reg, exp])                    

    addr = await u_dbg_bfm.wait_exec({0x80000004}, 100)
    
    if addr != 0x80000004:
        raise cocotb.result.TestError("execution timed out")
    

#     for i in range(64):
#         info = await u_tracer.get_reg_info(i)
#         reg_data.append(info)
#         
    print("exp_l: " + str(exp_l))
    print("reg_data: " + str(reg_data))
 
    errors = 0
    for e in exp_l:
        if u_dbg_bfm.reg(e[0]) == e[1]:
            print(" x" + str(e[0]) + ": " + hex(e[1]))
        else:
            print("*x" + str(e[0]) + ": expect=" + hex(e[1]) + " actual=" + hex(u_dbg_bfm.reg(e[0])))
            errors += 1
             
    if errors:
        raise cocotb.result.TestError("" + str(errors) + " register-compare errors")
    
    