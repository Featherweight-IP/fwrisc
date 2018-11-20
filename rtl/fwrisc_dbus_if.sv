/****************************************************************************
 * fwrisc_dbus_if.sv
 ****************************************************************************/

/**
 * Module: fwrisc_dbus_if
 * 
 * TODO: Add module documentation
 */
module fwrisc_dbus_if(
		input			clock,
		input[31:0]		instr,
		input[31:0]		rb_rdata,
		input[31:0]		alu_out,
		input[3:0]		state,
		output[31:0]	daddr,
		output			dvalid,
		output			dwrite,
		output reg[31:0]dwdata,
		output reg[3:0]	dstrb,
		input			dready
		);

	assign dvalid = (state == `MEMR || state == `MEMW);
	assign dwrite = (state == `MEMW);
	assign daddr = {alu_out[31:2], 2'b0}; // Always use the ALU for address
	
	always @* begin
		case (instr[13:12]) 
			2'b00: begin // SB
				dstrb = (1'b1 << alu_out[1:0]);
				dwdata = {rb_rdata[7:0], rb_rdata[7:0], rb_rdata[7:0], rb_rdata[7:0]};
			end
			2'b01: begin // SH
				dstrb = (2'b11 << {alu_out[1], 1'b0});
				dwdata = {rb_rdata[15:0], rb_rdata[15:0]};
			end
			// SW and default
			default: begin
				dstrb = 4'hf;
				dwdata = rb_rdata; // Write data is always @ rs2
			end
		endcase		
	end

endmodule


