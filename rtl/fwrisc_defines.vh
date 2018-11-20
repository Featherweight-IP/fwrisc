
`define	OP_ADD 3'b000
`define	OP_SUB 3'b001
`define	OP_AND 3'b010
`define	OP_OR  3'b011
`define	OP_XOR 3'b100
`define	OP_SLL 3'b101
`define OP_SRL 3'b110
`define	OP_SRA 3'b111

`define	COMPARE_EQ  2'b00
`define	COMPARE_LT  2'b01
`define	COMPARE_LTU 2'b10

`define FETCH					4'b0000
`define DECODE					4'b0001
`define EXECUTE					4'b0010
`define CSR_1					4'b0011
`define CSR_2					4'b0100
`define MEMW					4'b0101
`define MEMR					4'b0110
`define EXCEPTION_1				4'b0111
`define EXCEPTION_2				4'b1000
`define SHIFT_1					4'b1001
`define SHIFT_2					4'b1010
`define CYCLE_COUNT_UPDATE_1	4'b1011
`define CYCLE_COUNT_UPDATE_2	4'b1100
`define INSTR_COUNT_UPDATE_1	4'b1101
