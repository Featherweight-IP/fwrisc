

read_verilog fwrisc_alu.sv
read_verilog fwrisc_dbus_if.sv
read_verilog fwrisc_comparator.sv
read_verilog fwrisc_tracer.sv
read_verilog fwrisc_regfile.sv
read_verilog fwrisc.sv

hierarchy -check

# high-level synthesis
proc; opt; fsm; opt; memory; opt

show -format ps

#synth_intel -top fwrisc -family cyclone10
#synth_ice40 -top fwrisc -blif fwrisc.blif -abc2 -json fwrisc.json

