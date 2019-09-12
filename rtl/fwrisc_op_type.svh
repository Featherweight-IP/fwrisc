/****************************************************************************
 * fwrisc_op_type.svh
 * 
 * Defines parameters for the op_type data shared between decode and exec
 ****************************************************************************/

parameter [4:0] 
  /**
   * OP_TYPE_ARITH (0)
   * op_a = regs[rs1] 
   * op_b = regs[rs2] | imm
   * op = alu_op_type
   * 
   * LUI and AUIPC are also represented as ARTH ops
   * op_a = imm
   * op_b = imm base (pc or zero)
   * op = alu_op_type - OPA, ADD
   */
  OP_TYPE_ARITH  = 5'd0,
  
  /**
   * OP_TYPE_BRANCH (1)
   * op_a = regs[rs1]
   * op_b = regs[rs2]
   * op = alu_op_type
   * op_c = imm
   */
  OP_TYPE_BRANCH = (OP_TYPE_ARITH+5'd1),
  
  /**
   * OP_TYPE_LDST (2)
   * op_a = regs[rs1]
   * op_b = regs[rs2] (ST)
   * op = mem_op_type 
   * op_c = offset
   */
  OP_TYPE_LDST   = (OP_TYPE_BRANCH+5'd1),

  /**
   * OP_TYPE_MDS (3)
   * op_a = regs[rs1]
   * op_b = regs[rs2] | imm
   * op = mdu_op_type
   */
  OP_TYPE_MDS    = (OP_TYPE_LDST+5'd1),
  
  /**
   * OP_TYPE_JUMP (4)
   * op_a = jump base (pc or rs1)
   * op_b = rd
   * op = OPA
   * op_c = offset of jump base
   */
  OP_TYPE_JUMP   = (OP_TYPE_MDS+5'd1),
  OP_TYPE_CALL   = (OP_TYPE_JUMP+5'd1),
  /**
   * OP_TYPE_CSR (6)
   * op_a = regs[rs1]
   * op_b = regs[csr]
   * op_c = instruction rd
   * rd_raddr = csr
   * op = alu_op_type - OPA, OR, CLR
   */
  OP_TYPE_CSR    = (OP_TYPE_CALL+5'd1)
  ;
