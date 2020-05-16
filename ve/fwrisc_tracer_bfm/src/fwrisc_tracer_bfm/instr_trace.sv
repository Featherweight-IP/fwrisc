
module fwrisc_tracer_bfm(
    input  clock,
    input  reset,
    // ...
    );

    // ...

    reg	trace_instr_all = 1;
    reg	trace_instr_jump = 1;
    reg	trace_instr_call = 1;

    task set_trace_instr(reg all, reg jumps, reg calls);
        trace_instr_all = all;
        trace_instr_jump = jumps;
        trace_instr_call = calls;
    endtask

    always @(posedge clock) begin
        if (ivalid) begin
            last_instr <= instr;
            hw_breakpoint = 0;
		
            if (trace_instr_all 
                || (trace_instr_jump && (
                    last_instr[6:0] == 7'b1101111 || // jal
                    last_instr[6:0] == 7'b1100111))  // jalr
                || (trace_instr_call && (
                    // JAL with a non-zero link target
                    last_instr[6:0] == 7'b1101111 ||
                    last_instr[6:0] == 7'b1100111) && last_instr[11:7] != 5'b0)
               ) begin
                instr_exec(pc, instr);
            end
        end
    end

    // ...

endmodule
