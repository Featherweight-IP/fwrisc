
module fwrisc_tracer_bfm(
                input                   clock,
                input                   reset,
                // ...
                );
    reg    trace_reg_writes = 1;

    task set_trace_reg_writes(reg t);
        trace_reg_writes = t;
    endtask

    always @(posedge clock) begin
        if (rd_write && rd_waddr != 0) begin
            if (trace_reg_writes) begin
                reg_write(rd_waddr, rd_wdata);
            end
        end
    end

    // ...
