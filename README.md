# FWRISC

FWRISC is a _Featherweight RISC-V_ implementation of the RV32I instruction set. This implementation
supports the integer instructions, registers, CSRs, and exceptions as required by the RISC-V spec.

This core was originally created for the 2018 RISC-V contest:
https://riscv.org/2018contest/

FWRISC is a non-pipelined processor that aims to balance performance with FPGA resource utilization. 
It achieves 0.15 DMIPS/Mhz.

FWRISC correctly runs all RISCV RV32I [compliance tests](https://github.com/riscv/riscv-compliance).
It also supports the [Zephyr](https://www.zephyrproject.org/) RTOS.

## Core Features

- RV32I instructions
- Multi-cycle shift
- MINSTR, MCYCLE counters
- ECALL/EBREAK/ERET instrutions
- Support for address-alignment exceptions

## Resource Stats
The bare FWRISC 1.0.0 core consumes the following resources:

<table border="1">
<tr>
<th>Target</th><th>LUTs/LCs</th><th>RAM</th><th>Frequency</th>
</tr>
<tr><td>Microsemi IGLOO2 (Synplify)</td><td>1060 LUTs</td><td>2x 64x18</td><td>20Mhz</td></tr>
<tr><td>Lattice ICE40 (Yosys)</td><td>1653 LCs</td><td>4x RAM40_4k</td><td>unconstrained</td></tr>
</table>

## Getting Started

See the [Quickstart](doc/fwrisc_quickstart.md) document to get started with FWRISC. For more 
detailed information, see the documents below.

- [Tools](doc/fwrisc_tools.md)
- [Setup](doc/fwrisc_setup.md)
- [Verification Environment](doc/fwrisc_verification.md)
- [Design Documents](doc/fwrisc_design.md)
- [Zephyr Port](doc/fwrisc_zephyr.md)


