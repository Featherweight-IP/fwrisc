
`include "fwrisc_decode_formal_opcode_defines.svh"


module fwrisc_decode_formal_test(
		input				clock,
		input				reset,
		output reg			fetch_valid,
		input				decode_ready,
		output reg[31:0]	instr,
		output				instr_c
		);

	assign instr_c = 0;
	wire[31:0] instr_add;
	wire[31:0] instr_and;
	wire[31:0] instr_or;
	wire[31:0] instr_sll;
	wire[31:0] instr_srl;
	wire[31:0] instr_sra;
	wire[31:0] instr_slt;
	wire[31:0] instr_sltu;
	wire[31:0] instr_sub;
	wire[31:0] instr_xor;
	
	wire[5:0] rs1 = instr[19:15];
	wire[5:0] rs2 = instr[24:20];
	wire[5:0] rd  = instr[11:7];
	
	`rtype_add(instr_add, $anyconst, $anyconst, $anyconst);
	`rtype_and(instr_and, $anyconst, $anyconst, $anyconst);
	`rtype_or(instr_or, $anyconst, $anyconst, $anyconst);
	`rtype_sll(instr_sll, $anyconst, $anyconst, $anyconst);
	`rtype_srl(instr_srl, $anyconst, $anyconst, $anyconst);
	`rtype_sra(instr_sra, $anyconst, $anyconst, $anyconst);
	`rtype_slt(instr_slt, $anyconst, $anyconst, $anyconst);
	`rtype_sltu(instr_sltu, $anyconst, $anyconst, $anyconst);
	`rtype_sub(instr_sub, $anyconst, $anyconst, $anyconst);
	`rtype_xor(instr_xor, $anyconst, $anyconst, $anyconst);
	reg state = 0;
	reg[3:0] count = 0;
	
	always @(posedge clock) begin
		if (reset) begin
			fetch_valid <= 0;
			instr <= 0;
			state <= 0;
			count <= 0;
		end else begin
			case (state) 
				0: begin
					fetch_valid <= 1;
					case (count) 
						0: instr <= instr_add;
						1: instr <= instr_and;
						2: instr <= instr_or;
						3: instr <= instr_sll;
						4: instr <= instr_srl;
						5: instr <= instr_sra;
						6: instr <= instr_slt;
						7: instr <= instr_sltu;
						8: instr <= instr_sub;
						9: instr <= instr_xor;
						default: instr <= instr_add;
					endcase
					state <= 1;
					count <= count + 1;
					cover (count == 9);
				end
				1: begin
					if (decode_ready) begin
						fetch_valid <= 0;
						state <= 0;
					end
				end
			endcase
		end
	end

endmodule