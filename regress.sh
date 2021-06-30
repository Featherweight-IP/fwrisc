#!/bin/sh

python3 -m pip install ivpm

cd /project

export PATH=/tools/bin:/tools/riscv64-zephyr-elf/bin:$PATH

# Fetch development packages and dependencies
# using non-SSH git
ivpm update --anonymous-git

cd verilog/dv/sim/rv32i

make -f mkdv.mk regress


