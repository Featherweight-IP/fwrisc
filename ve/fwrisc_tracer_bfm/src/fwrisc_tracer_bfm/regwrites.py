
@cocotb.bfm(hdl={
    bfm_vlog : bfm_hdl_path(__file__, "hdl/fwrisc_tracer_bfm.v"),
    bfm_sv : bfm_hdl_path(__file__, "hdl/fwrisc_tracer_bfm.v")
    })
class FwriscTracerBfm():

    # ...

    @cocotb.bfm_import(cocotb.bfm_uint32_t)
    def set_trace_reg_writes(self, t):
        pass

