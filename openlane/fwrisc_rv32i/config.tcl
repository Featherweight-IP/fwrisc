set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) fwrisc_rv32i

set vlog_files ""
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_alu.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_c_decode.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_decode.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_exec.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_fetch.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_mem.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_mul_div_shift.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_regfile.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_rv32imc.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_rv32im.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_rv32i.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_rv32i_wb.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_tracer.sv
lappend vlog_files $script_dir/../../verilog/rtl/fwrisc_wb.sv

set vlog_incdirs ""
lappend vlog_incdirs $script_dir/../../verilog/rtl
lappend vlog_incdirs $script_dir/../../packages/fwprotocol-defs/src/sv

set ::env(VERILOG_FILES) $vlog_files
set ::env(VERILOG_INCLUDE_DIRS) $vlog_incdirs

set ::env(CLOCK_PORT) "clock"
#set ::env(CLOCK_NET) "u_payload.clock"
set ::env(CLOCK_PERIOD) "25"
#set ::env(BASE_SDC_FiLE) "$script_dir/fwrisc_rv32i.sdc"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1200 1200"
set ::env(DESIGN_IS_CORE) 0

#set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

#set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.32
#set ::env(PL_TARGET_DENSITY) 0.50

#set ::env(DIODE_INSERTION_STRATEGY) 1
#set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 4

set ::env(ROUTING_CORES) 10
# Removed
#set ::env(GLB_RT_MAXLAYER) 4

