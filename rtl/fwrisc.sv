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
		EXECUTE
	} state_e;
	
	state_e				state;
	reg[31:2]			pc;
	wire[31:2]			pc_next;

	assign iaddr = {pc, 2'b0};
	assign ivalid = (state == FETCH);
	
	
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
	
	wire jal_op = (instr[6:0] == 7'b1101111);
	
	wire[31:0]      jal_off = (instr[31])?{{21{1'b1}}, instr[31], instr[19:12], instr[20], instr[30:21],1'b0}:
											{{21{1'b0}}, instr[31], instr[19:12], instr[20], instr[30:21],1'b0};

	wire[5:0]		ra_raddr;
	wire[5:0]		rb_raddr;
	wire[31:0]		ra_rdata;
	wire[31:0]		rb_rdata;
	wire[5:0]		rd_waddr;
	wire[31:0]		rd_wdata;
	wire			rd_wen;
	
	// TEMP: just assign
	assign ra_raddr = rs1;
	assign rb_raddr = rs2;
	assign rd_waddr = rd;
	

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
	
	wire[31:0]					alu_op_a;
	wire[31:0]					alu_op_b;
	wire [4:0]					alu_op;
	wire[31:0]					alu_out;
	
	assign alu_op_a = pc;
	assign alu_op_b = jal_off;
	assign alu_op = OP_ADD;
	
	fwrisc_alu u_alu (
		.clock  (clock ), 
		.reset  (reset ), 
		.op_a   (alu_op_a  ), 
		.op_b   (alu_op_b  ), 
		.op     (alu_op    ), 
		.out    (alu_out   ));
	
	assign rd_wdata = (jal_op)?pc:alu_out;
	assign pc_next = (jal_op)?alu_out[31:2]:(pc + 1'b1);

endmodule


