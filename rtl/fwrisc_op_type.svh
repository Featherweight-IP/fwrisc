/****************************************************************************
 * fwrisc_op_type.svh
 * 
 * Defines parameters for the op_type data shared between decode and exec
 ****************************************************************************/

parameter [4:0] 
  /**
   * OP_TYPE_ARITH
   * op_a = regs[rs1] 
   * op_b = regs[rs2] | imm
   * op = alu_op_type
   */
  OP_TYPE_ARITH  = 5'd0,
  
  /**
   * OP_TYPE_BRANCH
   * op_a = regs[rs1]
   * op_b = regs[rs2]
   * op = alu_op_type
   * op_c = imm
   */
  OP_TYPE_BRANCH = (OP_TYPE_ARITH+5'd1),
  
  /**
   * OP_TYPE_LDST
   * op_a = regs[rs1]
   * op_b = regs[rs2] (ST)
   * op = (TBD)
   * op_c = offset
   */
  OP_TYPE_LDST   = (OP_TYPE_BRANCH+5'd1),

  /**
   * OP_TYPE_MDS
   * op_a = regs[rs1]
   * op_b = regs[rs2] | imm
   * op = mdu_op_type
   */
  OP_TYPE_MDS    = (OP_TYPE_LDST+5'd1),
  
  /**
   * OP_TYPE_JUMP
   * op_a = jump base (pc or rs1)
   * op_b = rd
   * op = NOP
   * op_c = offset of jump base
   */
  OP_TYPE_JUMP   = (OP_TYPE_MDS+5'd1),
  OP_TYPE_CALL   = (OP_TYPE_JUMP+5'd1),
  OP_TYPE_CSR    = (OP_TYPE_CALL+5'd1)
  ;
