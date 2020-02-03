# FWRISC

[![Build Status](https://dev.azure.com/mballance/mballance/_apis/build/status/mballance.fwrisc?branchName=master)](https://dev.azure.com/mballance/mballance/_build/latest?definitionId=8&branchName=master)


FWRISC-S is a _Featherweight RISC-V_ implementation of the RV32IMC instruction set with
IoT-appropriate security features. This implementation supports the integer instructions,
registers, CSRs, and exceptions as required by the RISC-V spec.

This revision of the core was created for the 2019 RISC-V security contest:
https://riscv.org/2019/07/risc-v-softcpu-core-contest/

FWRISC is a non-pipelined processor that aims to balance performance with FPGA resource utilization. 
It achieves 0.15 DMIPS/Mhz.

FWRISC correctly runs all RISCV RV32I [compliance tests](https://github.com/riscv/riscv-compliance).
It also supports the [Zephyr](https://www.zephyrproject.org/) RTOS.

## Core Features

- RV32IMC instructions
- Multi-cycle shift
- Multi-cycle multiply/divide
- Support for the compressed-instruction ISA
- MINSTR, MCYCLE counters
- ECALL/EBREAK/ERET instrutions
- Support for address-alignment exceptions

## SEcurity Features
FWRISC-S implements Data Execution Prevention, as a way to prevent arbitrary code
execution. While more-complex protection techniques are appropriate for more-complex
systems, IoT systems typically run a fixed program that can be easily protected in
this way. 
The Zephyr SoC-support configuration has been setup such that data execution prevention
is configured just after kernel boot. Using linker symbols, the configuration
programs CSRs to only allow execution in the text section of the image. See 
[Zephyr](doc/fwrisc_zephyr.md) for more information.

## Resource Stats
The bare FWRISC-S 1.0.0 core consumes the following resources:

<table border="1">
<tr>
<th>Target</th><th>LUTs/LCs</th><th>RAM</th><th>Frequency</th>
</tr>
<tr><td>Microsemi IGLOO2 (Synplify)</td><td>2592 LUTs</td><td>2x 64x18</td><td>36.6Mhz</td></tr>
</table>

## Getting Started

See the [Quickstart](doc/fwrisc_quickstart.md) document to get started with FWRISC. For more 
detailed information, see the documents below.

- [Tools](doc/fwrisc_tools.md)
- [Setup](doc/fwrisc_setup.md)
- [Verification Environment](doc/fwrisc_verification.md)
- [Design Documents](doc/fwrisc_design.md)
- [Zephyr Port](doc/fwrisc_zephyr.md)


