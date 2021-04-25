'''
Created on Mar 18, 2021

@author: mballance
'''
import hvlrpc

@hvlrpc.api_exp
class BareMetalSupport(object):
    
    @hvlrpc.func
    def record_pass(self, m : str):
        print("PASS: " + m)
        
    @hvlrpc.func
    def record_fail(self, m : str):
        print("FAIL: " + m)
        
    @hvlrpc.func
    def endtest(self):
        print("endtest")
        pass
        
    
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
                    
        print(msg)
                    
        
                
            
        