
@cocotb.bfm(hdl={
    bfm_vlog : bfm_hdl_path(__file__, "hdl/fwrisc_tracer_bfm.v"),
    bfm_sv : bfm_hdl_path(__file__, "hdl/fwrisc_tracer_bfm.v")
    })
class FwriscTracerBfm():

    @cocotb.bfm_import(cocotb.bfm_uint32_t, cocotb.bfm_uint32_t, cocotb.bfm_uint32_t)
    def set_trace_instr(self, all_instr, jump_instr, call_instr):
        pass

