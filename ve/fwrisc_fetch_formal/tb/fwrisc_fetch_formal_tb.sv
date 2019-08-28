/****************************************************************************
 * fwrisc_fetch_formal_tb.sv
 ****************************************************************************/


/**
 * Module: fwrisc_fetch_formal_tb
 * 
 * TODO: Add module documentation
 */
module fwrisc_fetch_formal_tb(input clock);

	reg[3:0]	reset_cnt = 0;
	(* keep *)
	reg 		reset = 1;
	
	always @(posedge clock) begin
		if (reset_cnt == 1) begin
			reset <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end

	// TODO: instance checker, test, and DUT
	

	wire[31:1]				next_pc;
	wire					next_pc_seq;
	wire[31:0]				iaddr;
	wire[31:0]				idata;
	wire					ivalid;
	wire					iready;
	wire					fetch_valid;
	wire					decode_ready;
	wire[31:0]				instr;
	wire					instr_c;
	
	reg[3:0]				instr_count = 0;
	reg[3:0]				fetch_count = 0;
	
	fwrisc_fetch_formal_test u_test(
			.clock              (clock             ), 
			.reset              (reset             ), 
			.next_pc            (next_pc           ), 
			.next_pc_seq        (next_pc_seq       ), 
			.iaddr              (iaddr             ), 
			.idata              (idata             ), 
			.ivalid             (ivalid            ), 
			.iready             (iready            ), 
			.fetch_valid        (fetch_valid       ), 
			.decode_ready       (decode_ready      ), 
			.instr              (instr             ), 
			.instr_c            (instr_c           )
			);
	
	fwrisc_fetch #(
		.ENABLE_COMPRESSED  (1 )
		) u_dut (
		.clock              (clock             ), 
		.reset              (reset             ), 
		.next_pc            (next_pc           ), 
		.next_pc_seq        (next_pc_seq       ), 
		.iaddr              (iaddr             ), 
		.idata              (idata             ), 
		.ivalid             (ivalid            ), 
		.iready             (iready            ), 
		.fetch_valid        (fetch_valid       ), 
		.decode_ready       (decode_ready      ), 
		.instr              (instr             ), 
		.instr_c            (instr_c           ));
	
	

//	reg fetch_state = 0;
//	always @(posedge clock) begin
//		if (reset) begin
//			decode_ready <= 0;
//			fetch_state <= 0;
//		end else begin
//			case (fetch_state)
//				0: begin
//					if (ivalid) begin
//						iready <= 1;
//						fetch_state <= 1;
//						fetch_count <= fetch_count + 1;
//					end else begin
//						iready <= 0;
//					end
//				end
//				
//				1: begin
//					iready <= 0;
//					fetch_state <= 0;
//				end
//			endcase
//			
//			decode_ready <= fetch_valid;
//			if (fetch_valid) begin
//				next_pc <= next_pc + 2;
//				instr_count <= instr_count + 1;
//				assert(fetch_count == (instr_count+1));
//			end
////			cover(!reset && fetch_valid);
//			cover(instr_count == 4);
//		end
//	end
	
	
	fwrisc_fetch_formal_checker u_checker(
		);
			
endmodule

