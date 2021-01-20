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

class ComplianceTestTube(object):
    
    def __init__(self, 
                 sram,
                 dbg,
                 write_str, 
                 write_num):
        self.x31 = 0
        self.a0 = 0
        self.sram = sram
        self.dbg = dbg
        self.write_str = write_str
        self.write_num = write_num
        self.num_passed = 0
        self.num_failed = 0
        self.out = ""
    
    def instr_exec(self, pc, instr):
#        print("ComplianceTestTube: pc=" + hex(pc) + " write_str=" + hex(self.write_str))
        if pc == self.write_str:
#            print("write_str: " + hex(self.a0))
            addr = (self.dbg.reg(10) & 0xFFFFF)
            while True:
                word = self.sram.read_nb(int(addr/4))
                byte = (word >> 8*(addr%4)) & 0xFF
                
                if byte != 0:
                    if byte == 0xa:
                        if self.out.startswith("Test Passed"):
                            self.num_passed += 1
                        if self.out.startswith("Test Failed"):
                            self.num_failed += 1
                        print(self.out)
                        self.out = ""
                    else:
                        self.out += "%c" % (byte,)
                else:
                    break
                addr += 1
                
        if pc == self.write_num:
            self.out += hex(self.a0)


@cocotb.test()
async def test(top):
    await pybfms.init()
    
    u_sram = pybfms.find_bfm(".*u_sram")
    u_dbg_bfm : RiscvDebugBfm = pybfms.find_bfm(".*u_dbg_bfm")
    
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
    
    await cocotb.triggers.Timer(10, 'ms')
    
    return
    
#    u_dbg_bfm.trace_level(RiscvDebugTraceLevel.Call)
#    u_dbg_bfm.en_disasm = False
    
#    mon = ExecMonitor()
#    u_tracer.add_listener(mon)
   
    # Load the test sw
    sw_image = cocotb.plusargs["sw.image"]
   
    u_dbg_bfm.load_elf(sw_image)
    
    ref_file = cocotb.plusargs["ref.file"]
    begin_signature = 0
    end_signature = 0
    write_str = 0
    write_num = 0
    with open(sw_image, "rb") as f:
        elffile = ELFFile(f)
        
        symtab = elffile.get_section_by_name('.symtab')
             
        begin_signature = symtab.get_symbol_by_name("begin_signature")[0]["st_value"]
        end_signature = symtab.get_symbol_by_name("end_signature")[0]["st_value"]
        write_str = symtab.get_symbol_by_name("FN_WriteStr")[0]["st_value"]
        write_num = symtab.get_symbol_by_name("FN_WriteNmbr")[0]["st_value"]
            
        # Find the section that contains the data we need
        section = None
        for i in range(elffile.num_sections()):
            shdr = elffile._get_section_header(i)
#            print("sh_addr=" + hex(shdr['sh_addr']) + " sh_size=" + hex(shdr['sh_size']) + " flags=" + hex(shdr['sh_flags']))
#            print("  keys=" + str(shdr.keys()))
            if shdr['sh_size'] != 0 and shdr['sh_flags'] != 0x0:
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

    tube = ComplianceTestTube(u_sram, u_dbg_bfm, write_str, write_num)
    u_dbg_bfm.add_instr_exec_cb(tube.instr_exec)

    addr = await u_dbg_bfm.wait_exec({"self_loop"}, 100000)
    
    with open(ref_file, "rb") as ref_fp:
                 
        for cnt,line in enumerate(ref_fp):
            addr = ((begin_signature & 0xFFFFF) >> 2) + cnt
            exp = int(line, 16)
            actual = u_sram.read_nb(addr)
                     
            cocotb.log.info("0x%08x: exp=0x%08x actual=0x%08x" % (4*addr, exp, actual))
                     
            if exp != actual:
                tube.num_failed += 1
            else:
                tube.num_passed += 1
                
    if tube.num_passed > 0 and tube.num_failed == 0:
        print("PASSED")
    else:
        raise Exception("FAILED: num_passed=" + str(tube.num_passed) + " num_failed=" + str(tube.num_failed))
    
#     print("init_mem")
#     with open(sw_image, "rb") as f:
#         elffile = ELFFile(f)
#         symtab = elffile.get_section_by_name('.symtab')
#             
#         begin_signature = symtab.get_symbol_by_name("begin_signature")[0]["st_value"]
#         end_signature = symtab.get_symbol_by_name("end_signature")[0]["st_value"]
#             
#         addr = begin_signature
#          
#         # Find the section that contains the data we need
#         section = None
#         for i in range(elffile.num_sections()):
#             shdr = elffile._get_section_header(i)
#             if begin_signature >= shdr['sh_addr'] and begin_signature <= (shdr['sh_addr'] + shdr['sh_size']):
#                 section = elffile.get_section(i)
#                 begin_signature_offset = begin_signature - shdr['sh_addr']
#                 break
#                 
#         data = section.data()
#         for addr in range(begin_signature, end_signature, 4):
#             word = (
#                 (data[begin_signature_offset+0] << (8*0))
#                 | (data[begin_signature_offset+1] << (8*1))
#                 | (data[begin_signature_offset+2] << (8*2))
#                 | (data[begin_signature_offset+3] << (8*3))
#                 );
#             self.mem[(addr & 0xFFFF) >> 2] = word
#                 
#         begin_signature_offset += 4


        
        