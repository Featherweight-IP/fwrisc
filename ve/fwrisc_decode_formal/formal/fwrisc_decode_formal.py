
import unittest
from unittest.suite import TestSuite
from unittest.case import TestCase
from vsr.compound_suite import CompoundSuite
import os


print("Hello from fwrisc_decode_formal")

print("pre-formal_dir")
formal_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
print("formal_dir: " + str(formal_dir))

# Make it easy for users to point out where subtest-suites live
os.sys.path.append(os.path.join(formal_dir, "tests"))
print("pre-import")
import fwrisc_decode_formal_tests
print("post-import")


def suite():
    print("Test Suite")
    all = CompoundSuite()
    
    loader = unittest.TestLoader()
    tests = loader.loadTestsFromModule(fwrisc_decode_formal_tests)
    print("fwrisc_decode_formal_tests=" + str(fwrisc_decode_formal_tests))
    all.addTests(tests)
    
    return all
