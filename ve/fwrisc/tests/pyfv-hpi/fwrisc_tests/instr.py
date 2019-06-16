'''
Created on Jun 1, 2019

@author: ballance
'''
import hpi
import fwrisc_tracer_bfm
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection

class fwrisc_instr_tests():
    def __init__(self):
        self.regs = []
        self.mem = []
        self.icount = 0
#        self.max_instr = 1000
        self.max_instr = 1000000000
        self.end_sem = hpi.semaphore(0)
        
        # Initialize the registers
        for i in range(64):
            self.regs.append([0, False])
            
        for i in range(1024):
            self.mem.append([0, False])
            
    def runtest(self):
        print("runtest")
       
        bfm = hpi.bfm_list[0]
        bfm.listeners.append(self)

        # Wait for the test to decide it's done       
        self.end_sem.get(1)

        bfm.dumpregs()

        testname = hpi.get_plusarg("TESTNAME")
        if self.check():
            print("PASSED: " + testname)
        else:
            print("FAILED: " + testname)
            
        
    def check(self):
        status = True
        sw_image = hpi.get_plusarg("SW_IMAGE")
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
                
            # Now, check results
            for exp in exp_l:
                print("Expect: R[" + str(exp[0]) + "] = " + str(exp[1]))
                
            for exp in exp_l:
                if not self.regs[exp[0]][1]:
                    print("Error: R[" + str(exp[0]) + "] not written")
                    status = False
                    
                if self.regs[exp[0]][0] != exp[1]:
                    print("Error: R[" + str(exp[0]) + "] has unexpected value")

        return status 
        
    def regwrite(self, raddr, rdata):
        if raddr == 0:
            print("Error: writing to $zero")
            
        if raddr < 64:
            self.regs[raddr][0] = rdata
            self.regs[raddr][1] = True
        else:
            print("Error: raddr " + str(raddr) + " outside 0..63 range")
            
    def memwrite(self, addr, mask, data):
        if (addr & 0xFFF8000) == 0x80000000:
            offset = ((addr & 0x0000FFFF) >> 2)
            self.mem[offset][1] = True
            
            if (mask & 1) != 0:
                self.mem[offset][0] &= 0x000000FF
                self.mem[offset][0] |= (data & 0x000000FF)
            if (mask & 2) != 0:
                self.mem[offset][0] &= 0x0000FF00
                self.mem[offset][0] |= (data & 0x0000FF00)
            if (mask & 4) != 0:
                self.mem[offset][0] &= 0x00FF0000
                self.mem[offset][0] |= (data & 0x00FF0000)
            if (mask & 8) != 0:
                self.mem[offset][0] &= 0xFF000000
                self.mem[offset][0] |= (data & 0xFF000000)
        else:
            print("Error: illegal access to address " + str(addr))
            
    def exec(self, addr, instr):
        print("exec: " + str(addr))
        if addr == 0x80000004:
            print("Test done")
            self.end_sem.put(1)
            
        self.icount += 1
        if self.icount > self.max_instr:
            testname = hpi.get_plusarg("TESTNAME")
            print("FAILED: " + testname + " timeout")
            hpi.drop_objection()
        
    
@hpi.entry
def instr_main():
    test = fwrisc_instr_tests()

    test.runtest()

    
