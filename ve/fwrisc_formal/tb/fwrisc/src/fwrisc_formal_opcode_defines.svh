/****************************************************************************
 * fwrisc_formal_opcode_defines.svh
 ****************************************************************************/
 
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
	
	`define btype(target, imm, rs1, funct3, rd, opcode) \
	assign target[31] = (imm >> 12); \
	assign target[30:25] = (imm >> 5); \
	assign target[19:15] = rs1; \
	assign target[14:12] = funct3; \
	assign target[11:6] = (imm >> 1); \
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

`define lui(target, imm, rd) `utype(imm, rd, 7'b0110111)	
`define auipc(target, imm, rd) `utype(imm, rd, 7'b0010111)	
`define jal(target, imm, rd) `jtype(imm, rd, 7'b0010111)	
`define jalr(target, imm, rs1, rd) `itype(imm, rs1, 3'b000, rd, 7'b1100111)	

	