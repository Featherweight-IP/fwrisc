# FWRISC Quickstart

This Quickstart guide describes a process for getting up and running with FWRISC. Follow the process
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
% cd fwrisc/ve/fwrisc/sim
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



## Run Zephyr Examples
Two of the Zephyr examples, synchronization and philosophers, are much more visual and do not terminate.
Running these tests interactively is recommended.

### Run "philosophers":

```
% cd fwrisc/ve/fwrisc/sim
% runtest.pl -test tests/fwrisc_zephyr_philosophers.f
```

You should see something like what is seen below:

![alt text](imgs/Philosophers.gif "Philosophers")


### Run "synchronization"

```
% cd fwrisc/ve/fwrisc/sim
% runtest.pl -test tests/fwrisc_zephyr_synchronization.f
```


## Run Synthesis


