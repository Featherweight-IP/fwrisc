'''
Created on Jun 9, 2019

@author: ballance
'''
import hpi
from fwrisc_tests.instr import fwrisc_instr_tests

class fwrisc_riscv_compliance_tests(fwrisc_instr_tests):
    
    def __init__(self):
        fwrisc_instr_tests.__init__(self)

    def memwrite(self, addr, mask, data):
        if addr == 0x80001000:
            # End of the test
            self.end_sem.put(1)
        else:
            fwrisc_instr_tests.memwrite(self, addr, mask, data)
            
    def check(self):
        # TODO:
        pass
    
@hpi.entry
def riscv_compliance_main():
    print("--> riscv_compliance_main")
    test = fwrisc_riscv_compliance_tests()

    test.runtest()
    print("<-- riscv_compliance_main")