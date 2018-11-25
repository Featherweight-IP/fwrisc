
info commands
info procs

new_project \
  -location libero/fwrisc_fpga \
  -name fwrisc_fpga \
  -hdl VERILOG \
  -family SmartFusion2 \
  -die "M2S025" \
  -use_enhanced_constraint_flow 1

# open_project -file libero/fwrisc_fpga
import_files -hdl_source $env(FWRISC)/rtl/fwrisc_alu.sv 
import_files -hdl_source $env(FWRISC)/rtl/fwrisc_comparator.sv 
import_files -hdl_source $env(FWRISC)/rtl/fwrisc_dbus_if.sv 
import_files -hdl_source $env(FWRISC)/rtl/fwrisc_regfile.sv 
import_files -hdl_source $env(FWRISC)/rtl/fwrisc_tracer.sv 
import_files -hdl_source $env(FWRISC)/rtl/fwrisc.sv 
import_files -hdl_source $env(FWRISC)/rtl/fwrisc_defines.vh 
import_files -hdl_source $env(FWRISC)/rtl/fwrisc_fpga_top.sv

set_root fwrisc_fpga_top

file copy sw/rom.hex libero/fwrisc_fpga/synthesis/rom.hex

run_tool -name {CONSTRAINT_MANAGEMENT}
import_files \
  -io_pdc constraints/fwrisc_fpga_top.pdc

organize_tool_files -tool {PLACEROUTE} \
  -file ./libero/fwrisc_fpga/constraint/io/fwrisc_fpga_top.pdc \
  -module {fwrisc_fpga_top::work} \
  -input_type constraint
  
import_files -sdc constraints/fwrisc_fpga_top.sdc

organize_tool_files -tool {SYNTHESIZE} \
  -file ./libero/fwrisc_fpga/constraint/fwrisc_fpga_top.sdc \
  -module {fwrisc_fpga_top::work} \
  -input_type constraint

organize_tool_files -tool {PLACEROUTE} \
  -file ./libero/fwrisc_fpga/constraint/io/fwrisc_fpga_top.pdc \
  -file ./libero/fwrisc_fpga/constraint/fwrisc_fpga_top.sdc \
  -module fwrisc_fpga_top::work \
  -input_type {constraint}

organize_tool_files -tool {VERIFYTIMING} \
  -file ./libero/fwrisc_fpga/constraint/fwrisc_fpga_top.sdc \
  -module fwrisc_fpga_top::work \
  -input_type {constraint}

save_project

# update_and_run_tool -name SYNTHESIZE

delete_files -file {./synthesis/fwrisc_fpga_top.edn} -from_disk 
delete_files -file {./synthesis/fwrisc_fpga_top_sdc.sdc} -from_disk 

set_device \
  -family {SmartFusion2} -die {M2S025} -package {256 VF} \
  -speed {-1} -die_voltage {1.2} -part_range {COM} \
  -adv_options {IO_DEFT_STD:LVCMOS 2.5V} \
  -adv_options {RESERVEMIGRATIONPINS:1} \
  -adv_options {RESTRICTPROBEPINS:1} \
  -adv_options {RESTRICTSPIPINS:0} \
  -adv_options {TEMPR:COM} \
  -adv_options {UNUSED_MSS_IO_RESISTOR_PULL:None} \
  -adv_options {VCCI_1.2_VOLTR:COM} \
  -adv_options {VCCI_1.5_VOLTR:COM} \
  -adv_options {VCCI_1.8_VOLTR:COM} \
  -adv_options {VCCI_2.5_VOLTR:COM} \
  -adv_options {VCCI_3.3_VOLTR:COM} -adv_options {VOLTR:COM} 

puts "**> SYNTHESIZE (1)"
run_tool -name {SYNTHESIZE} 
puts "<** SYNTHESIZE (1)"

generate_sdc_constraint_coverage -tool {PLACEROUTE} 

# generate_sdc_constraint_coverage -tool {PLACEROUTE} 

puts "**> PLACEROUTE (1)"
run_tool -name {PLACEROUTE} 
puts "<** PLACEROUTE (1)"
puts "**> GENERATEPROGRAMMINGDATA (1)"
run_tool -name {GENERATEPROGRAMMINGDATA} 
puts "<** GENERATEPROGRAMMINGDATA (1)"
puts "**> GENERATEPROGRAMMINGFILE (1)"
run_tool -name {GENERATEPROGRAMMINGFILE} 
puts "<** GENERATEPROGRAMMINGFILE (1)"
puts "**> SYNTHESIZE (2)"
run_tool -name {SYNTHESIZE} 
puts "<**> SYNTHESIZE (2)"
generate_sdc_constraint_coverage -tool {PLACEROUTE} 

# generate_sdc_constraint_coverage -tool {PLACEROUTE} 
puts "**> PLACEROUTE (2)"
run_tool -name {PLACEROUTE} 
puts "<** PLACEROUTE (2)"
puts "**> GENERATEPROGRAMMINGFILE (2)"
run_tool -name {GENERATEPROGRAMMINGFILE} 
puts "<** GENERATEPROGRAMMINGFILE (2)"


puts "**> export_bitstream"
export_bitstream_file -trusted_facility_file 1 -trusted_facility_file_components {FABRIC}
puts "<** export_bitstream"

exit 0

