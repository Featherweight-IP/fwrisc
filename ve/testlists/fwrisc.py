'''
Created on Sep 24, 2019

@author: ballance
'''

import os
import unittest
from unittest.case import TestCase
from unittest.suite import TestSuite

from vsr import VSuite
from vsr.compound_suite import CompoundSuite


#
# ve_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# print("ve_dir: " + str(ve_dir))
# 
# # Make it easy for users to point out where subtest-suites live
# os.sys.path.append(os.path.join(ve_dir, "fwrisc_decode_formal", "formal", "testlists"))
# print("--> pre-Import")
# import fwrisc_decode_formal
# print("<-- pre-Import")
# 
# for f in dir(fwrisc_decode_formal):
#     print("Field: " + f)
#     
# fwrisc_decode_formal.suite()
# 
# print("pre-TestSuite")
# 
# suite = TestSuite()
# #print("fwrisc_decode_formal.all=" + str(fwrisc_decode_formal.all))
# #suite.addTests(fwrisc_decode_formal.all)
# 
# print("post-addTests")
# # Add 
def suite():
    ret = CompoundSuite("fwrisc")
    testlists_dir = os.path.dirname(os.path.abspath(__file__))
    ve_dir = os.path.dirname(testlists_dir)
    
    ret.add_vsuite(os.path.join(ve_dir, 
        "fwrisc_decode_formal/formal/testlists/fwrisc_decode_formal.py"))
    
    # Define the test suite and return it
    return ret

