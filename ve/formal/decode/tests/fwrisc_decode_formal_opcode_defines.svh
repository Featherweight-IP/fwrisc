/****************************************************************************
 * fwrisc_formal_opcode_defines.svh
 ****************************************************************************/
`ifndef INCLUDED_FWRISC_FORMAL_OPCODE_DEFINES_SVH
`define INCLUDED_FWRISC_FORMAL_OPCODE_DEFINES_SVH
	
	`define rtype(target, funct7, rs2, rs1, funct3, rd, opcode) \
	assign target[31:25] = funct7; \
	assign target[24:20] = rs2; \
	assign target[19:15] = rs1; \
	assign target[14:12] = funct3; \
	assign target[11:7] = rd; \
	assign target[6:0] = opcode
	
	`define itype(target, imm, rs1, funct3, rd, opcode) \
	assign target[31:20] = imm; \
	assign target[19:15] = rs1; \
	assign target[14:12] = funct3; \
	assign target[11:7] = rd; \
	assign target[6:0] = opcode
	
	`define stype(target, imm, rs1, funct3, rd, opcode) \
	assign target[31:25] = (imm >> 5); \
	assign target[19:15] = rs1; \
	assign target[14:12] = funct3; \
	assign target[11:7] = imm; \
	assign target[6:0] = opcode
	
`define btype(target, imm, rs1, rs2, funct3, opcode) \
	assign target[31] = (imm >> 12); \
	assign target[30:25] = (imm >> 5); \
	assign target[24:20] = rs2; \
	assign target[19:15] = rs1; \
	assign target[14:12] = funct3; \
	assign target[11:8] = (imm >> 1); \
	assign target[7] = (imm >> 11); \
	assign target[6:0] = opcode
	
	`define utype(target, imm, rd, opcode) \
	assign target[31:12] = (imm >> 12); \
	assign target[11:7] = rd; \
	assign target[6:0] = opcode
	
	`define jtype(target, imm, rd, opcode) \
	assign target[31] = (imm >> 20); \
	assign target[30:21] = (imm >> 1); \
	assign target[20] = (imm >> 11); \
	assign target[19:12] = (imm >> 12); \
	assign target[11:7] = rd; \
	assign target[6:0] = opcode
	
`define opcode(instr) instr[6:0]
`define rs1(instr) instr[19:15]
`define rs2(instr) instr[24:20]
`define rd(instr) instr[11:7]
`define i_imm(instr) instr[31:20]
`define funct7(instr) instr[31:25]
`define funct3(instr) instr[14:12]
	
`define crtype(target, funct4, rd_rs1, rs2, op) \
	assign target[15:12] = funct4; \
	assign target[11:7] = rd_rs1; \
	assign target[6:2] = rs2; \
	assign target[1:0] = op
	
`define citype(target, funct3, imm, rd_rs1, op) \
	assign target[15:13] = funct3; \
	assign target[12] = imm[5]; \
	assign target[11:7] = rd_rs1; \
	assign target[6:2] = imm[4:0]; \
	assign target[1:0] = op
	
`define cjtype(target, funct3, jtarg, op) \
	assign target[15:13] = funct3; \
	assign target[12] = imm[11];  \
	assign target[11] = imm[4];  \
	assign target[10:9] = imm[9:8]; \
	assign target[8] = imm[10]; \
	assign target[7] = imm[6]; \
	assign target[6] = imm[7]; \
	assign target[5:3] = imm[3:1]; \
	assign target[2] = imm[5]; \
	assign target[1:0] = op
	
`define imm_jtype(instr) $signed({instr[31], instr[19:12], instr[20], instr[30:21],1'b0})

`define lui(target, imm, rd) `utype(target, imm, rd, 7'b0110111)	
`define auipc(target, imm, rd) `utype(target, imm, rd, 7'b0010111)	
`define jal(target, imm, rd) `jtype(target, imm, rd, 7'b1101111)	
`define jalr(target, imm, rs1, rd) `itype(target, imm, rs1, 3'b000, rd, 7'b1100111)	
	
`define itype_add(target, imm, rs1, rd) `itype(target, imm, rs1, 3'b000, rd, 7'b0010011)
`define itype_slt(target, imm, rs1, rd) `itype(target, imm, rs1, 3'b010, rd, 7'b0010011)
`define itype_sltu(target, imm, rs1, rd) `itype(target, imm, rs1, 3'b011, rd, 7'b0010011)
`define itype_xor(target, imm, rs1, rd) `itype(target, imm, rs1, 3'b100, rd, 7'b0010011)
`define itype_or(target, imm, rs1, rd) `itype(target, imm, rs1, 3'b110, rd, 7'b0010011)
`define itype_and(target, imm, rs1, rd) `itype(target, imm, rs1, 3'b111, rd, 7'b0010011)
//`define itype_sll(target, imm, rs1, rd) `itype(target, imm, rs1, 3'b001, rd, 7'b0010011)
//`define itype_srl(target, imm, rs1, rd) `itype(target, imm, rs1, 3'b101, rd, 7'b0010011)
//`define itype_sra(target, imm, rs1, rd) `itype(target, imm, rs1, 3'b101, rd, 7'b0010011)
	
`define btype_beq(target, imm, rs1, rs2) `btype(target, imm, rs1, rs2, 3'b000, 7'b1100011)
`define btype_bne(target, imm, rs1, rs2) `btype(target, imm, rs1, rs2, 3'b001, 7'b1100011)
`define btype_blt(target, imm, rs1, rs2) `btype(target, imm, rs1, rs2, 3'b100, 7'b1100011)
`define btype_bge(target, imm, rs1, rs2) `btype(target, imm, rs1, rs2, 3'b101, 7'b1100011)
`define btype_bltu(target, imm, rs1, rs2) `btype(target, imm, rs1, rs2, 3'b110, 7'b1100011)
`define btype_bgeu(target, imm, rs1, rs2) `btype(target, imm, rs1, rs2, 3'b111, 7'b1100011)

`define rtype_add(target, rs2, rs1, rd) `rtype(target, 7'b0000000, rs2, rs1, 3'b000, rd, 7'b0110011)
`define rtype_and(target, rs2, rs1, rd) `rtype(target, 7'b0000000, rs2, rs1, 3'b111, rd, 7'b0110011)
`define rtype_or(target, rs2, rs1, rd) `rtype(target, 7'b0000000, rs2, rs1, 3'b110, rd, 7'b0110011)
`define rtype_sll(target, rs2, rs1, rd) `rtype(target, 7'b0000000, rs2, rs1, 3'b001, rd, 7'b0110011)
`define rtype_srl(target, rs2, rs1, rd) `rtype(target, 7'b0000000, rs2, rs1, 3'b101, rd, 7'b0110011)
`define rtype_sra(target, rs2, rs1, rd) `rtype(target, 7'b0100000, rs2, rs1, 3'b101, rd, 7'b0110011)
`define rtype_slt(target, rs2, rs1, rd) `rtype(target, 7'b0000000, rs2, rs1, 3'b010, rd, 7'b0110011)
`define rtype_sltu(target, rs2, rs1, rd) `rtype(target, 7'b0000000, rs2, rs1, 3'b011, rd, 7'b0110011)
`define rtype_sub(target, rs2, rs1, rd) `rtype(target, 7'b0100000, rs2, rs1, 3'b000, rd, 7'b0110011)
`define rtype_xor(target, rs2, rs1, rd) `rtype(target, 7'b0000000, rs2, rs1, 3'b100, rd, 7'b0110011)
`define rtype_mul(target, rs2, rs1, rd) `rtype(target, 7'b0000001, rs2, rs1, 3'b000, rd, 7'b0110011)
`define rtype_mulh(target, rs2, rs1, rd) `rtype(target, 7'b0000001, rs2, rs1, 3'b001, rd, 7'b0110011)
`define rtype_mulhsu(target, rs2, rs1, rd) `rtype(target, 7'b0000001, rs2, rs1, 3'b010, rd, 7'b0110011)
`define rtype_mulhu(target, rs2, rs1, rd) `rtype(target, 7'b0000001, rs2, rs1, 3'b011, rd, 7'b0110011)
`define rtype_div(target, rs2, rs1, rd) `rtype(target, 7'b0000001, rs2, rs1, 3'b100, rd, 7'b0110011)
`define rtype_divu(target, rs2, rs1, rd) `rtype(target, 7'b0000001, rs2, rs1, 3'b101, rd, 7'b0110011)
`define rtype_rem(target, rs2, rs1, rd) `rtype(target, 7'b0000001, rs2, rs1, 3'b110, rd, 7'b0110011)
`define rtype_remu(target, rs2, rs1, rd) `rtype(target, 7'b0000001, rs2, rs1, 3'b111, rd, 7'b0110011)
	
`define utype_lui(target, imm, rd) `utype(target, imm, rd, 7'b0110111)
`define utype_auipc(target, imm, rd) `utype(target, imm, rd, 7'b0010111)
	
`endif /* INCLUDED_FWRISC_FORMAL_OPCODE_DEFINES_SVH */