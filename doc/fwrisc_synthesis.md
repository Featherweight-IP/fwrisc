# FWRISC Synthesis

FWRISC has a goal of supporting the majority of available FPGA platforms. Currently, FWRISC
has a complete synthesis flow setup for Microsemi FPGAs, and runs synthesis for Lattice
using Yosys.

All synthesis-related files are stored in the _synth_ subdirectory of the FWRISC project.

## Microsemi
Synthesis for Microsemi IGLOO2/SmartFusion2 uses the Libero software. Before running synthesis,
please ensure that tools are properly configured in your environment, and you have 
properly configured FWRISC by sourcing the setup file.

Run synthesis for the top-level SoC by running _make_. The output files will be
placed inside the 'libero' subdirectory.

A cached version of the top-level bitstream is stored in the bitstream/fwrisc_fpga_top.stp file.
This bitstream contains a ROM image that alternates flashing the LEDs on the Future Electronics 
CREATIVE board (P/N FUTUREM2SF-EVB).


Resource measurements for the FWRISC core on its own are done using a standalone Synplify project.
The project files are stored in the synplify subdirectory. 


## Lattice
Synthesis for Lattice ICE40 uses the Yosys software. Before running synthesis, please
ensure that tools are properly configured in your environment, and you have properly
configured FWRISC by sourcing the setup file.

Run Yosys synthesis for the FWRISC core on its own by running _make_. The resource
report will be the last thing displayed in the console.

