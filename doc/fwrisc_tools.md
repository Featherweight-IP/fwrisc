# FWRISC Tools

FWRISC was developed on Centos 7 Linux. No attempt has yet been made to support FWRISC development
on Windows or any other Linux distribution. Several software packages require 32-bit compatability
libraries to be installed on a 64-bit Linux distribution.


### Bourne (again) Shell
Bourne shell was used for development. A C-Shell setup script is provided, but
has little to no testing. 

### Java 1.8+
The FWRISC-S dependencies include some Scala/CHISEL which must be run using Java.
Java 1.8 or higher is required.

### Libero 11.9
Libero 11.9 was used to performa synthesis for Microsemi IGLOO2/Fusion2 devices. The synthesis scripts
assume that you have the 'libero' on your search path, and that your licensing environment
is properly configured.

### Yosys 0.8+53
Yosys 0.8+53 was used to perform synthesis for Lattice ICE40 devices. The synthesis scripts
assume that you have 'yosys' on your search path.

### CMake 3.12.4
CMake 3.12.4 is required by Zephyr. Please ensure that 'cmake' is in your search path.

### Zephyr SDK 0.9.5
The Zephyr SDK was used to provide cross-compilers for Zephyr and Zephyr applications. Please
ensure that you have ZEPHR_TOOLCHAIN_VARIANT and ZEPHYR_SDK_INSTALL_DIR properly set.


### Python 2.7.5
Several scripts used by FWRISC require Python2 to be installed. Python 2.7.5 is provided by Centos7

### Python 3.6
Zephyr requires Python3, as well as several additional Python modules. You must install 
these required modules in your Python3 installation.

### Verilator 4.010 
Verilator 4.010 was used for verification of the FWRISC core. Verilator must be compiled 
with FST support enabled. Please ensure that 'verilator' is on your search path.

### GTKWave
GTKWave was used for viewing waveforms.

### Host GCC 4.8.5
Centos7 provides GCC 4.8.5, which was used for compiling the simulation image and testbench.

### RISC-V GCC 7.3.0 
GCC 7.3.0 was used for the cross-compiler used for all non-Zephyr tests. The cross compiler was
created using [cross-tool-scripts](http://github.com/mballance/cross-tools-scripts). Other cross
compilers may be used, provided the executable names have a riscv32-unknown-elf- prefix (eg riscv32-unknown-elf-gcc).
Please ensure riscv32-unknown-elf-gcc is on your search path.

### Symbiyosys
The open-source Symbiyosys tool was used for formal analysis of several sub-blocks
in the FWRISC-S core. Using the latest Symbiyosys built from GitHub is recommended.

