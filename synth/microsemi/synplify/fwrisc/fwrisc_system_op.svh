
parameter [3:0]
  OP_TYPE_ECALL  = 1'd0,
  OP_TYPE_EBREAK = (OP_TYPE_ECALL + 1'd1),
  OP_TYPE_ERET   = (OP_TYPE_EBREAK + 1'd1),
  OP_TYPE_WFI    = (OP_TYPE_ERET + 1'd1)
  ;

  