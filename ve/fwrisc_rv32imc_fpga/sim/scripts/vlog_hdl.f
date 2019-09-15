
-f ${MEMORY_PRIMITIVES}/rtl/sim/sim.f

-f ${FWRISC}/rtl/fwrisc.f
-f ${FWRISC}/soc/fwrisc_soc.f
+incdir+${FWRISC}/ve/fwrisc_tracer_bfm
${FWRISC}/ve/fwrisc_tracer_bfm/fwrisc_tracer_bfm.sv
-F ${FWRISC}/ve/fwrisc_rv32imc_fpga/tb/tb.F
