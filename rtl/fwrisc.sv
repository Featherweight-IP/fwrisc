/****************************************************************************
 * fwrisc.sv
 ****************************************************************************/

/**
 * Module: fwrisc
 * 
 * TODO: Add module documentation
 */
module fwrisc #()(
		input			clock,
		input			reset,
		
		output[31:0]	iaddr,
		input[31:0]		idata,
		output			ivalid,
		input			iready,
		
		output[31:0]	daddr,
		output[31:0]	dwdata,
		output[31:0]	drdata,
		output[3:0]		dstrb,
		output			dwrite,
		output			dvalid,
		input			dready
		);

	reg[31:0]			instr;
	
	typedef enum {
		FETCH, // 
		DECODE,
		EXECUTE,
		MEM
	} state_e;
	
	state_e				state;
	reg[31:2]			pc;
	wire[31:2]			pc_plus4;
	wire[31:2]			pc_next;
	
	assign pc_plus4 = (pc + 1'b1);

	assign iaddr = {pc, 2'b0};
	assign ivalid = (state == FETCH && !reset);
	
	
	always @(posedge clock) begin
		if (reset) begin
			state <= FETCH;
			instr <= 0;
		end else begin
			if (ivalid && iready) begin
				instr <= idata;
			end
			
			case (state)
				FETCH: begin
					if (ivalid && iready) begin
						state <= DECODE;
						instr <= idata;
					end
				end
				
				DECODE: begin
					// NOP: wait for decode to occur
					state <= EXECUTE;
				end
				
				EXECUTE: begin
					pc <= pc_next;
					state <= FETCH;
				end
			endcase
		end
	end
	
	
	// RS1, RS2, and RD are always in the same place
	wire[4:0]		rs1 = instr[24:20];
	wire[4:0]		rs2 = instr[19:15];
	wire[4:0]		rd  = instr[11:7];

	wire op_branch_ld_st_arith = (instr[3:0] == 4'b0011);
	wire op_ld        = (op_branch_ld_st_arith && instr[6:4] == 3'b000);
	wire op_arith_imm = (op_branch_ld_st_arith && instr[6:4] == 3'b001);
	wire op_st        = (op_branch_ld_st_arith && instr[6:4] == 3'b010);
	wire op_arith_reg = (op_branch_ld_st_arith && instr[6:4] == 3'b011);
	wire op_branch    = (op_branch_ld_st_arith && instr[6:4] == 3'b110);
	wire op_jal       = (instr[6:0] == 7'b1101111);
	wire op_jalr      = (instr[6:0] == 7'b1100111);
	wire op_auipc     = (instr[6:0] == 7'b0010111);
	wire op_lui       = (instr[6:0] == 7'b0110111);
	
	wire[31:0]      jal_off = (instr[31])?{{21{1'b1}}, instr[31], instr[19:12], instr[20], instr[30:21],1'b0}:
											{{21{1'b0}}, instr[31], instr[19:12], instr[20], instr[30:21],1'b0};
	wire[31:0]      imm_31_12 = (instr[31])?{{22{1'b1}}, instr[31:12]}:{{22{1'b0}}, instr[31:12]};
	wire[31:0]      imm_11_0 = (instr[31])?{{22{1'b1}}, instr[31:12]}:{{22{1'b0}}, instr[31:12]};
	
	wire[31:0]      imm_lui = {instr[31:12], 12'h000};
	wire[31:0]		zero = 32'h00000000;

	wire[5:0]		ra_raddr;
	wire[5:0]		rb_raddr;
	wire[31:0]		ra_rdata;
	wire[31:0]		rb_rdata;
	wire[5:0]		rd_waddr;
	wire[31:0]		rd_wdata;
	wire			rd_wen;

	// ALU signals
	wire[31:0]					alu_op_a;
	wire[31:0]					alu_op_b;
	wire [4:0]					alu_op;
	wire[31:0]					alu_out;
	
	// TEMP: just assign
	assign ra_raddr = rs1;
	assign rb_raddr = rs2;
	assign rd_waddr = rd;
	
	assign rd_wdata = (op_jal)?pc:alu_out;
	always @* begin
		if (op_jal || op_jalr) begin
			rd_wdata = pc_plus4;
		end else begin
			rd_wdata = alu_out;
		end
	end
	

	// Write at the end of the execute state 
	// when the destination isn't $zero
	assign rd_wen = (state == EXECUTE && |rd);
	
	fwrisc_regfile u_regfile (
		.clock     (clock    ), 
		.reset     (reset    ), 
		.ra_raddr  (ra_raddr ), 
		.ra_rdata  (ra_rdata ), 
		.rb_raddr  (rb_raddr ), 
		.rb_rdata  (rb_rdata ), 
		.rd_waddr  (rd_waddr ), 
		.rd_wdata  (rd_wdata ), 
		.rd_wen    (rd_wen   ));
	

	always @* begin
		if (op_lui) begin
			alu_op_a = imm_lui;
			alu_op_b = zero;
			alu_op = OP_ADD;
		end else if (op_auipc) begin
			alu_op_a = 0;
			alu_op_b = pc;
			alu_op = OP_ADD;
		end else if (op_jal) begin
			alu_op_b = pc;
			alu_op_a = jal_off;
			alu_op = OP_ADD;
		end else if (op_jalr) begin
			alu_op_b = pc;
			alu_op = OP_ADD;
		end else if (op_ld || op_st || op_arith_imm) begin
			alu_op_b = ra_rdata; // rs1
		end else if (op_arith_reg) begin
			alu_op_a = rb_raddr; // rs2
			alu_op_b = ra_raddr; // rs1
		end else begin
			alu_op_a = zero;
			alu_op_b = zero;
			alu_op = OP_ADD;
		end
	end
	
	fwrisc_alu u_alu (
		.clock  (clock ), 
		.reset  (reset ), 
		.op_a   (alu_op_a  ), 
		.op_b   (alu_op_b  ), 
		.op     (alu_op    ), 
		.out    (alu_out   ));
	
	
	always @* begin
		if (op_jal || op_jalr) begin
			pc_next = alu_out[31:2];
		end else begin
			pc_next = pc_plus4;
		end
	end

endmodule


