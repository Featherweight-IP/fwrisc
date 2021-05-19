'''
Created on Mar 18, 2021

@author: mballance
'''
import hvlrpc
import pybfms

@hvlrpc.api_exp
class BareMetalSupport(object):
    
    _objections = 0
    _objections_ev = None
    
    def __init__(self, coreid=""):
        self.coreid = coreid
    
    @hvlrpc.func
    def record_pass(self, m : str):
        print("%s: PASS: %s" % (self.coreid, m))
        
    @hvlrpc.func
    def record_fail(self, m : str):
        print("%s: FAIL: %s" % (self.coreid, m))
        
    @hvlrpc.func
    def endtest(self):
        print("endtest")
        BareMetalSupport.drop_objection()
   
    @classmethod 
    def raise_objection(cls):
        if cls._objections_ev is None:
            cls._objections_ev = pybfms.event()
        cls._objections += 1

    @classmethod        
    def drop_objection(cls):
        if cls._objections_ev is None:
            cls._objections_ev = pybfms.event()
        if cls._objections > 0:
            cls._objections -= 1
            if cls._objections == 0:
                cls._objections_ev.set()

    @classmethod            
    async def wait(cls):
        if cls._objections_ev is None:
            cls._objections_ev = pybfms.event()
            
        while BareMetalSupport._objections > 0:
            await BareMetalSupport._objections_ev.wait()
            BareMetalSupport._objections_ev.clear()
    
    @hvlrpc.func
    def vprint(self, fmt : str, ap : hvlrpc.va_list):
#        print("vprint: fmt=" + fmt)
        msg = ""
        
        i=0
        while i < len(fmt):
            pi = fmt.find('%', i)
            if pi != -1:
                # Add 
                # TODO: First, handle any formatting options
                msg += fmt[i:pi]
                i = pi+1
                fc = fmt[i]
                if fc == '%':
                    # Escaped format char
                    msg += '%'
                elif fc == 'd':
                    # TODO: handle ll modifier
                    # TODO: handle padding
                    msg += "%d" % ap.int32()
                elif fc == 'x':
                    # TODO: handle ll modifier
                    # TODO: handle padding
                    msg += "%x" % ap.int32()
                elif fc == 's':
                    msg += ap.str()
                i += 1
            else:
                # No more
                if i < len(fmt):
                    msg += fmt[i:]
                    i = len(fmt)
                    
        print("%s: %s" % (self.coreid, msg))
                    
        
                
            
        