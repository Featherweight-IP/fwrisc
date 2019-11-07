from unittest.case import TestCase
import vsr

def add_common_options(test):
    test.add_runarg("+MODE=cover")
    test.add_runarg("+DEPTH=64")

@vsr.test
def i32_btype(test):
    # TODO: append test-specific run options, etc
    add_common_options(test)
    test.add_runarg("+CHECKER=fwrisc_decode_formal_i32_btype_checker")

@vsr.test
def i32_itype():
    add_common_options(test)
    test.add_runarg("+CHECKER=fwrisc_decode_formal_i32_itype_checker")

@vsr.test
def i32_lui():
    add_common_options(test)
    test.add_runarg("+CHECKER=fwrisc_decode_formal_i32_lui_checker")

@vsr.test
def i32_rtype():
    add_common_options(test)
    test.add_runarg("+CHECKER=fwrisc_decode_formal_i32_lui_checker")



