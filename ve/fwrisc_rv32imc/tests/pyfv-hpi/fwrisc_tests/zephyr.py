'''
Created on Jun 6, 2019

@author: ballance
'''
from fwrisc_tests.instr import fwrisc_instr_tests

class fwrisc_zephr_tests(fwrisc_instr_tests):
    
    def __init__(self):
        fwrisc_instr_tests.__init__(self)
        
    def regwrite(self, raddr, rdata):
        pass
    
    def memwrite(self, addr, mask, data):
        pass