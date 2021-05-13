
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
		
		.iaddr              (iaddr             ), 
		.idata              (idata             ), 
		.ivalid             (ivalid            ), 
		.iready             (iready            ),
		
		.dvalid             (dvalid            ), 
		.daddr              (daddr             ), 
		.dwdata             (dwdata            ), 
		.dwstb              (dwstb             ), 
		.dwrite             (dwrite            ), 
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
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			wb_state <= 2'b0;
		end else begin
			case (wb_state) // synopsys parallel_case full_case
				2'b00: begin
					if (dvalid) begin
						// Give priority to data
						wb_state <= 2'b01;
					end else if (ivalid) begin
						wb_state <= 2'b10;
					end
				end
				2'b01: begin
					if (cyc && sel && ack) begin
						wb_state <= 2'b00;
					end
				end
				2'b10: begin
					if (cyc && sel && ack) begin
						wb_state <= 2'b00;
					end
				end
			endcase
		end
	end
	
	assign adr = (dni_sel)?daddr:iaddr;
	assign cyc = (dni_sel)?dvalid:ivalid;
	assign sel = (dni_sel)?dvalid:ivalid;
	assign stb = (dni_sel)?dwstb:{4{1'b0}};
	assign tgc = (dni_sel)?damo:{4{1'b0}};
	assign we  = (dni_sel)?dwrite:1'b0;
	assign tgd = 1'b0;
	assign tga = 1'b0;
	assign dat_w = dwdata;
	assign drdata = dat_r;
	assign idata = dat_r;
	assign dready = (dni_sel)?(cyc && sel && ack):1'b0;
	assign iready = (~dni_sel)?(cyc && sel && ack):1'b0;

endmodule


