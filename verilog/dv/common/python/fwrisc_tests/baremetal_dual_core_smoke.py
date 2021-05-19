'''
Created on May 14, 2021

@author: mballance
'''
import cocotb
from fwrisc_tests.baremetal_test_base import BaremetalTestBase
from fwrisc_tests.baremetal_support import BareMetalSupport

class BaremetalDualCoreSmokeTest(BaremetalTestBase):

    async def run(self):
        # Raise an objection for each core
        BareMetalSupport.raise_objection()
        BareMetalSupport.raise_objection()
        await BareMetalSupport.wait()


@cocotb.test()
async def entry(dut):
    t = BaremetalDualCoreSmokeTest()
    await t.init()
    await t.run()
    
#    await cocotb.triggers.Timer(1, 'us')
#    print("Complete")
    