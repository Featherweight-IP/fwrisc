
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
	wire[31:0] instr_beq;
	wire[31:0] instr_bne;
	wire[31:0] instr_blt;
	wire[31:0] instr_bge;
	wire[31:0] instr_bltu;
	wire[31:0] instr_bgeu;
	
	wire[5:0] rs1 = instr[19:15];
	wire[11:0] imm = instr[31:20];
//	wire[5:0] rs2 = instr[24:20];
	wire[5:0] rd  = instr[11:7];
	
	wire[2:0] isel = $anyconst;

	`btype_beq(instr_beq, $anyconst, $anyconst, $anyconst);
	`btype_bne(instr_bne, $anyconst, $anyconst, $anyconst);
	`btype_blt(instr_blt, $anyconst, $anyconst, $anyconst);
	`btype_bge(instr_bge, $anyconst, $anyconst, $anyconst);
	`btype_bltu(instr_bltu, $anyconst, $anyconst, $anyconst);
	`btype_bgeu(instr_bgeu, $anyconst, $anyconst, $anyconst);
	
	reg state = 0;
	
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
					case ((isel % 6)) 
						0: instr <= instr_beq;
						1: instr <= instr_bne;
						2: instr <= instr_blt;
						3: instr <= instr_bge;
						4: instr <= instr_bltu;
						5: instr <= instr_bgeu;
						default: instr <= instr_beq;
					endcase
					state <= 1;
				end
				1: begin
					if (decode_ready) begin
						fetch_valid <= 0;
						state <= 0;
						cover(isel == 0);
						cover(isel == 1);
						cover(isel == 2);
						cover(isel == 3);
						cover(isel == 4);
						cover(isel == 5);
					end
				end
			endcase
		end
	end

endmodule