# FWRISC

FWRISC is a _Featherweight RISC-V_ implementation of the RV32I instruction set. This implementation
supports the integer instructions, registers, CSRs, and exceptions as required by the RISC-V spec.

FWRISC is a non-pipelined processor that aims to balance performance with FPGA resource utilization. 
It achieves 0.15 DMIPS/Mhz.

FWRISC correctly runs all RISCV RV32I [compliance tests](https://github.com/riscv/riscv-compliance).
It also supports the [Zephyr](https://www.zephyrproject.org/) RTOS.

See the [Quickstart](docs/fwrisc_quickstart.md) document to get started with FWRISC. For more 
detailed information, see the documents below.

- [Tools](docs/fwrisc_tools.md)
- [Setup](docs/fwrisc_setup.md)
- [Verification Environment](docs/fwrisc_verification.md)
- [Design Documents](docs/fwrisc_design.md)
- [Zephyr Port](docs/fwrisc_zephyr.md)

## Resource Stats
The bare FWRISC 1.0.0 core consumes the following resources:

<table border="1">
<tr>
<th>Target</th><th>LUTs/LCs</th><th>RAM</th><th>Frequency</th>
</tr>
<tr><td>Microsemi IGLOO2 (Synplify)</td><td>1060 LUTs</td><td>2x 64x18</td><td>20Mhz</td></tr>
<tr><td>Lattice ICE40 (Yosys)</td><td>1653 LCs</td><td>4x RAM40_4k</td><td>unconstrained</td></tr>
</table>

