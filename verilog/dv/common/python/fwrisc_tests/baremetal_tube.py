'''
Created on Feb 21, 2021

@author: mballance
'''

class BaremetalTube(object):
    
    def __init__(self, addr):
        self.addr = addr
        self.out = ""

    def memwrite(self, addr, data, mask):
        if addr == self.addr:
            ch = data & 0xFF
            
            if ch != 0:
                if ch == 0xa:
                    print("# " + self.out)
                    self.out = ""
                else:
                    self.out += "%c" % (ch,)
    
    