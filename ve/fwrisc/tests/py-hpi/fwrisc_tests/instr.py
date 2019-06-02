'''
Created on Jun 1, 2019

@author: ballance
'''
import hpi

class fwrisc_instr_tests():

    def __init__(self):
        # TODO: find tracer BFM
        # TODO: register
        pass
    
    def runtest(self):
        print("runtest")
        
    
@hpi.entry
def main():
    test = fwrisc_instr_tests()
    
    hpi.raise_objection()
    test.runtest()
    hpi.drop_objection()

    