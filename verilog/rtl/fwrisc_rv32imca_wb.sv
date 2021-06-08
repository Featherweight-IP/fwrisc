
/****************************************************************************
 * fwrisc_rv32imca_wb.sv
 ****************************************************************************/
`include "wishbone_tag_macros.svh"
`include "wishbone_amo_defines.svh"
  
/**
 * Module: fwrisc_rv32imca_wb
 * 
 * TODO: Add module documentation
 */
module fwrisc_rv32imca_wb #(
		parameter VENDORID 	= 0,
		parameter ARCHID 	= 0,
		parameter IMPID 	= 0
		) (
		input				clock,
		input				reset,
		input[31:0]			hartid,
		// Boot location
		input[31:0]			resvec,
		`WB_INITIATOR_TAG_PORT( , 32, 32, 1, 1, 4),
		input				irq
		);
	
	wire[31:0]				iaddr;
	wire[31:0]				idata;
	wire					ivalid;
	wire					iready;
	wire					dvalid;
	wire[31:0]				daddr;
	wire[31:0]				dwdata;
	wire[3:0]				dwstb;
	wire					dwrite;
	wire[3:0]				damo;
	wire[31:0]				drdata;
	wire					dready;
	
	
	fwrisc #(
		.ENABLE_COMPRESSED  (1 			), 
		.ENABLE_MUL_DIV     (1			), 
		.ENABLE_DEP         (0			),
		.ENABLE_COUNTERS    (0			), 
		.VENDORID           (VENDORID	), 
		.ARCHID             (ARCHID		), 
		.IMPID              (IMPID		)
		) fwrisc (
		.clock              (clock             ), 
		.reset              (reset             ), 
		.hartid             (hartid            ), 
		.resvec             (resvec            ),
		
		.iaddr              (iaddr             ), 
		.idata              (idata             ), 
		.ivalid             (ivalid            ), 
		.iready             (iready            ),
		
		.dvalid             (dvalid            ), 
		.daddr              (daddr             ), 
		.dwdata             (dwdata            ), 
		.dwstb              (dwstb             ), 
		.dwrite             (dwrite            ), 
		.damo               (damo              ),
		.drdata             (drdata            ), 
		.dready             (dready            ), 
		.irq                (irq               ));

	reg[1:0] wb_state;
	reg dni_sel;
	
	always @* begin
		if ((wb_state == 2'b00 && dvalid) || wb_state == 2'b01) begin
			dni_sel = 1;
		end else begin
			dni_sel = 0;
		end
	end
	
	reg[31:0] 	adr_r;
	reg[31:0] 	dat_w_r;
	reg[31:0] 	dat_r_r;
	reg			cyc_r;
	reg			stb_r;
	reg[3:0]	sel_r;
	reg[3:0]	tgc_r;
	reg			we_r;
	reg			iready_r;
	reg			dready_r;
	
	assign adr = adr_r;
	assign dat_w = dat_w_r;
	assign cyc = cyc_r;
	assign stb = stb_r;
	assign sel = sel_r;
	assign tgc = tgc_r;
	assign tgd_w = 1'b0;
	assign tga = 1'b0;
	assign we = we_r;
	
	assign iready = iready_r;
	assign dready = dready_r;
	assign drdata = dat_r_r;
	assign idata = dat_r_r;
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			wb_state <= 2'b0;
			adr_r <= {32{1'b0}};
			dat_w_r <= {32{1'b0}};
			dat_r_r <= {32{1'b0}};
			cyc_r <= 1'b0;
			stb_r <= 1'b0;
			sel_r <= {4{1'b0}};
			tgc_r <= {4{1'b0}};
			we_r <= 1'b0;
		end else begin
			case (wb_state) // synopsys parallel_case full_case
				2'b00: begin
					dready_r <= 1'b0;
					iready_r <= 1'b0;
					if (dvalid) begin
						// Give priority to data
						wb_state <= 2'b01;
						adr_r <= daddr;
						dat_w_r <= dwdata;
						cyc_r <= 1'b1;
						stb_r <= 1'b1;
						sel_r <= dwstb;
						we_r <= dwrite;
						tgc_r <= damo;
					end else if (ivalid) begin
						wb_state <= 2'b10;
						we_r <= 1'b0;
						adr_r <= iaddr;
						dat_w_r <= {32{1'b0}};
						cyc_r <= 1'b1;
						stb_r <= 1'b1;
						sel_r <= {4{1'b0}};
						we_r <= 1'b0;
						tgc_r <= {4{1'b0}};
					end
				end
				2'b01: begin // data
					if (cyc && stb && ack) begin
						wb_state <= 2'b11;
						dready_r <= 1'b1;
						dat_r_r <= dat_r;
						cyc_r <= 1'b0;
						stb_r <= 1'b0;
					end
				end
				2'b10: begin // instruction
					if (cyc && stb && ack) begin
						wb_state <= 2'b11;
						iready_r <= 1'b1;
						dat_r_r <= dat_r;
						cyc_r <= 1'b0;
						stb_r <= 1'b0;
					end
				end
				2'b11: begin // post-cycle turn-around
					wb_state <= 2'b00;
				end
			endcase
		end
	end

endmodule


