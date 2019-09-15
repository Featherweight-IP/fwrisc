# FWRISC-S Design Notes

## Execution State Machine
fwrisc uses a state machine to implement instruction execution. Most logical and arithmetic instructions execute in three cycles (Fetch, Decode, Execute). Memory instructions have an additional MEMR or MEMW state. CSR instructions use several states to implement the atomic read/modify/write
behavior of these instructions.

## Memory Interface
The memory interface for both the instruction-fetch and data interfaces follows a simple valid/ready handshake scheme. 

Reads begin with the core asserting VALID along with the address. Read data is sampled when the READY signal is also high.

Writes begin with the core asserting VALID along with address, data, strobes, and write. The cycle terminates when the READY signal
is also high.


## Register File
fwrisc uses FPGA blockram to implement the core RISC-V registers, as well as the CSRs. Currently, dual-port
full-width RAM is used to increase performance.

## Data-Execution Prevention
FWRISC-S implements a lightweight version of data execution prevention. The RISC-V spec defines and optional
set of Physical Memory Protection (PMP) registers. This approach is very appropriate for more-complex
systems, but does have more flexibility and complexity than is required for simple deeply-embedded systems.
The data-execution prevention mechanism implemented by FWRISC-S supports a single executable region, 
bounded by two addresses aligned on 16-byte boundaries stored in two custom CSR registers. 
Data-execution prevention is enabled once the 0th bit of both registers is set to 1. 
Once data-execution prevention is enabled, these registers cannot be written again until the core is reset.

