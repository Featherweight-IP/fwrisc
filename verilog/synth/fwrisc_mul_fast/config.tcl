set script_dir [file dirname [file normalize [info script]]]


set ::env(CLOCK_PORT) "clock"
#set ::env(CLOCK_NET) "u_payload.clock"
set ::env(CLOCK_PERIOD) "20"
#set ::env(BASE_SDC_FiLE) "$script_dir/fwrisc_rv32i.sdc"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 350 350"
set ::env(DESIGN_IS_CORE) 0

#set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

#set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.45
#set ::env(PL_TARGET_DENSITY) 0.50

#set ::env(DIODE_INSERTION_STRATEGY) 1
#set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 4

set ::env(ROUTING_CORES) 10
# Removed
#set ::env(GLB_RT_MAXLAYER) 4

