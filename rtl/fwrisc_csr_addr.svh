
parameter [5:0]
  CSR_BASE_Q0   = 6'h20,
  CSR_MVENDORID = (CSR_BASE_Q0 + 1'd1),
  CSR_MARCHID   = (CSR_MVENDORID + 1'd1),
  CSR_MIMPID    = (CSR_MARCHID + 1'd1),
  CSR_MHARTID   = (CSR_MIMPID + 1'd1),
  CSR_BASE_Q1   = 6'h28,
  CSR_MSTATUS   = (CSR_BASE_Q1 + 1'd0),
  CSR_MISA      = (CSR_MSTATUS + 1'd1),
  CSR_MEDELEG   = (CSR_MISA + 1'd1),
  CSR_MIDELEG   = (CSR_MEDELEG + 1'd1),
  CSR_MIE       = (CSR_MIDELEG + 1'd1),
  CSR_MTVEC     = (CSR_MIE + 1'd1),
  CSR_MCOUNTEREN= (CSR_MTVEC + 1'd1),
  CSR_BASE_Q2   = 6'h30,
  CSR_MSCRATCH  = (CSR_BASE_Q2 + 1'd0),
  CSR_MEPC      = (CSR_MSCRATCH + 1'd1),
  CSR_MCAUSE    = (CSR_MEPC + 1'd1),
  CSR_MTVAL     = (CSR_MCAUSE + 1'd1),
  CSR_MIP       = (CSR_MTVAL + 1'd1),
  CSR_BASE_Q3   = 6'h38,
  CSR_MCYCLE    = (CSR_BASE_Q3 + 1'd0),
  CSR_MCYCLEH   = (CSR_MCYCLE + 1'd1),
  CSR_MINSTRET  = (CSR_MCYCLEH + 1'd1),
  CSR_MINSTRETH = (CSR_MINSTRET + 1'd1),
  /**
   * Data Execution Prevention register Low
   */
  CSR_DEP_LO    = (CSR_MINSTRETH + 1'd1),
  /**
   * Data Execution Prevention register High
   */
  CSR_DEP_HI    = (CSR_DEP_LO + 1'd1),
  /**
   * Soft reset. Any write to this register 
   * causes a soft reset
   */
  CSR_SOFT_RESET= (CSR_DEP_HI + 1'd1)
  ;
  