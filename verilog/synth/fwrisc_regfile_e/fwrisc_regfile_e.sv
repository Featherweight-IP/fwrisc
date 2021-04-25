
module fwrisc_regfile_e(
                input                           clock,
                input                           reset,
                output                          soft_reset_req,
                input                           instr_complete,
                input                           trap,
                input                           tret,
                input                           irq,

                input[5:0]                      ra_raddr,
                output reg[31:0]                ra_rdata,
                input[5:0]                      rb_raddr,
                output reg[31:0]                rb_rdata,
                input[5:0]                      rd_waddr,
                input[31:0]                     rd_wdata,
                input                           rd_wen,

                output[31:0]                    dep_lo,
                output[31:0]                    dep_hi,
                output[31:0]                    mtvec,
                output reg                      meie,
                output reg                      mie
                );

	fwrisc_regfile #(
                .ENABLE_COUNTERS(0),
                // Enable Data Execution Protection
                .ENABLE_DEP(0),
                .RV32E(1)
                ) u_regs (
                .clock(                           clock),
                .reset(                           reset),
                .soft_reset_req(                  soft_reset_req),
                .instr_complete(                  instr_complete),
                .trap(                            trap),
                .tret(                            tret),
                .irq(                             irq),

                .ra_raddr(                        ra_raddr),
                .ra_rdata(                        ra_rdata),
                .rb_raddr(                        rb_raddr),
                .rb_rdata(                        rb_rdata),
                .rd_waddr(                        rd_waddr),
                .rd_wdata(                        rd_wdata),
                .rd_wen(                          rd_wen),

                .dep_lo(                          dep_lo),
                .dep_hi(                          dep_hi),
                .mtvec(                           mtvec),
                .meie(                            meie),
                .mie(                             mie)
                );

endmodule
