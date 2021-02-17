
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
	wire[31:0] instr_slt;
	wire[31:0] instr_sltu;
	wire[31:0] instr_xor;
	
	wire[5:0] rs1 = instr[19:15];
	wire[11:0] imm = instr[31:20];
//	wire[5:0] rs2 = instr[24:20];
	wire[5:0] rd  = instr[11:7];

	wire[2:0] isel = $anyconst;
	
	`itype_add(instr_add, $anyconst, $anyconst, $anyconst);
	`itype_and(instr_and, $anyconst, $anyconst, $anyconst);
	`itype_or(instr_or, $anyconst, $anyconst, $anyconst);
	`itype_slt(instr_slt, $anyconst, $anyconst, $anyconst);
	`itype_sltu(instr_sltu, $anyconst, $anyconst, $anyconst);
	`itype_xor(instr_xor, $anyconst, $anyconst, $anyconst);
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
					case (isel % 6)
//					assume(instr == instr_add || instr == instr_and || instr == instr_or || instr == instr_slt);
					
//					case (count) 
						0: instr <= instr_add;
						1: instr <= instr_and;
						2: instr <= instr_or;
						3: instr <= instr_slt;
						4: instr <= instr_sltu;
						5: instr <= instr_xor;
						default: instr <= instr_add;
					endcase
					state <= 1;
					count <= count + 1;
//					cover (count == 5);
				end
				1: begin
					if (decode_ready) begin
						cover(isel == 0); // add
						cover(isel == 1); // and
						cover(isel == 2);
						cover(isel == 3);
						cover(isel == 4);
						cover(isel == 5);
						fetch_valid <= 0;
						state <= 0;
					end
				end
			endcase
		end
	end

endmodule