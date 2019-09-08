
parameter [3:0]
OP_SLL   = 4'd0,
OP_SRL   = (OP_SLL + 4'd1),
OP_SRA   = (OP_SRL + 4'd1),
OP_MUL   = (OP_SRA + 4'd1),
OP_MULH  = (OP_MUL + 4'd1),
OP_MULS  = (OP_MULH + 4'd1),
OP_MULSH = (OP_MULS + 4'd1),
OP_DIV   = (OP_MULSH + 4'd1),
OP_REM   = (OP_DIV + 4'd1)
;