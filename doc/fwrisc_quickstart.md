# FWRISC Quickstart

This Quickstart guide describes the process for getting up and running with FWRISC. Follow the process
described below 

## Setup Tools

Please see the [Tools](fwrisc_tools.md) page for information on the tools required to run FWRISC. 
Please install the required tools and configure your environment before proceeding.

## Setup FWRISC Project

Please see the [Setup](fwrisc_setup.md) page for information on cloning and bootstrapping the
FWRISC project.

## Run Regression Tests

The block-level regression tests can be run using the following steps. Note that the
FWRISC environment-setup script must have previously been sourced:

```
% cd fwrisc-s/ve/fwrisc_rv32imc/sim
% runtest.pl -testlist testlists/fwrisc_riscv_all_tests.tl
```

The runtest command above will run unit tests, RISC-V compliance tests, and simple Zephyr tests. You should see 
something like the following after the test run completes:

```
#*********************************************************************
# PASSED:  120
# FAILED:  0
# UNKNOWN: 0
# TOTAL:   120
#*********************************************************************
```



## Run the RIPE Tests

The five intrusion techniques that are part of the 2019 contest can be run using
the fwrisc_riscv_ripe_tests.tl testlist. There are five tests in this
testlist, each of which configures the 'NV' define to run one of the intrusion 
techniques.

```
% cd fwrisc-s/ve/fwrisc_rv32imc/sim
% runtest.pl -tl testlists/fwrisc_riscv_ripe_tests.tl
```

Expected output is:

```
PASSED: fwrisc_ripe_4
PASSED: fwrisc_ripe_2
PASSED: fwrisc_ripe_3
PASSED: fwrisc_ripe_1
PASSED: fwrisc_ripe_5
make: Entering directory `/project/fun/fwrisc/fwrisc-s/ve/fwrisc_rv32imc/sim/rundir/fwrisc_rv32imc/vl'
make: Nothing to be done for `post-run'.
make: Leaving directory `/project/fun/fwrisc/fwrisc-s/ve/fwrisc_rv32imc/sim/rundir/fwrisc_rv32imc/vl'
#*********************************************************************
# PASSED:  5
# FAILED:  0
# UNKNOWN: 0
# TOTAL:   5
#*********************************************************************
```

Individual RIPE tests can be run using a tests/fwrisc_ripe_X.f test files. The output 
from the first RIPE test is:

```
# RIPE is alive! fwrisc_sim
# -t direct -i shellcode -c longjmpstackparam -l stack -f homebrew----------------
# Shellcode instructions:
# lui t1,  0x00000               00000000
# addi t1, t1, 0x00                  00000000
# jalr t1000300e7
# ----------------
# target_addr == 0x80009ed0
# buffer == 0x80009aa0
# payload size == 1077
# bytes to pad: 1060
# 
# overflow_ptr: 0x80009aa0
# payload: 
# 
hit halt address 0x80003e04
--> m_engine=0xde7870
<-- m_engine=0xde7870
[       OK ] fwrisc_ripe_tests.ripe (94 ms)
[----------] 1 test from fwrisc_ripe_tests (94 ms total)

[----------] Global test environment tear-down
[==========] 1 test from 1 test case ran. (94 ms total)
[  PASSED  ] 1 test.
plusarg +TESTNAME=fwrisc_ripe_1 matches pattern +TESTNAME
PASSED: fwrisc_ripe_1
PASSED: fwrisc_ripe_1
make: Entering directory `/project/fun/fwrisc/fwrisc-s/ve/fwrisc_rv32imc/sim/rundir/fwrisc_rv32imc/vl'
make: Nothing to be done for `post-run'.
make: Leaving directory `/project/fun/fwrisc/fwrisc-s/ve/fwrisc_rv32imc/sim/rundir/fwrisc_rv32imc/vl'
#*********************************************************************
# PASSED:  1
# FAILED:  0
# UNKNOWN: 0
# TOTAL:   1
#*********************************************************************
```

The test terminates when the core hits the instruction access fault exception
occurs, as a result of the intrusion code.

## Run Synthesis
Please see the [Synthesis](fwrisc_synthesis.md) document for more information on running synthesis. The short version is:

- Ensure your environment is properly configured
- cd fwrisc/synth/microsemi
- make clean
- make




