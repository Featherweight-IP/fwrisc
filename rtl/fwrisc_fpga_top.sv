/****************************************************************************
 * fwrisc_fpga_top.sv
 ****************************************************************************/

/**
 * Module: fwrisc_fpga_top
 * 
 * TODO: Add module documentation
 */
module fwrisc_fpga_top (
		input			clock,
		output			led0,
		output			led1);

	wire				reset;
	
	reg					reset_r = 0;
	reg[3:0]			reset_cnt = 0;
	
	always @(posedge clock) begin
		if (reset_cnt == 10) begin
			reset_r <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	assign reset = reset_r;
	
	wire[31:0]			iaddr;
	reg[31:0]			idata;
	wire				ivalid;
	wire				iready;
	wire[31:0]			daddr;
	wire[31:0]			dwdata;
	reg[31:0]			drdata;
	wire[3:0]			dstrb;
	wire				dwrite;
	wire				dvalid;
	wire				dready;
	
	
	fwrisc u_core (
		.clock   (clock  ), 
		.reset   (reset  ), 
		.iaddr   (iaddr  ), 
		.idata   (idata  ), 
		.ivalid  (ivalid ), 
		.iready  (iready ), 
		.daddr   (daddr  ), 
		.dwdata  (dwdata ), 
		.drdata  (drdata ), 
		.dstrb   (dstrb  ), 
		.dwrite  (dwrite ), 
		.dvalid  (dvalid ), 
		.dready  (dready ));

	// ROM: 'h8000_0000
	// RAM: 'h8000_2000
	// LED: 'hC000_0000
	reg[31:0]			ram[2047:0]; // 8k ram
	reg[31:0]			rom[2047:0]; // 8k rom
	reg[31:0]			led;
	reg					iready_r, dready_r;
	
	assign iready = iready_r;
	assign dready = dready_r;
	
	assign led0 = led[0];
	assign led1 = led[1];
	
	initial begin
		$readmemh("rom.hex", rom);
	end
	
	reg[31:0]			addr_d;
	reg[31:0]			addr_i;
	
	always @(posedge clock) begin
		addr_d <= daddr;
		addr_i <= iaddr;
		
		if (dwrite && dvalid && dwrite &&
				daddr[31:28] == 4'h8 && 
				daddr[15:12] == 4'h2) begin
			ram[daddr] <= dwdata;
		end else if (dwrite && dvalid && dwrite &&
				daddr[31:28] == 4'hc) begin
			led <= dwdata;
		end
	end
	
	always @(posedge clock) begin
		// Prefer data access
		if (dvalid) begin
			dready_r <= 1;
			iready_r <= 0;
		end else if (ivalid) begin
			iready_r <= 1;
			dready_r <= 0;
		end else begin
			iready_r <= 0;
			dready_r <= 0;
		end
	end

	always @* begin
		if (addr_d[31:28] == 4'h8 && addr_d[15:12] == 4'h2) begin 
			drdata = ram[addr_d[31:2]];
		end else begin
			drdata = rom[addr_d[31:2]];
		end
		
		if (addr_i[31:28] == 4'h8 && addr_i[15:12] == 4'h2) begin
			idata = ram[addr_i[31:2]];
		end else begin
			idata = rom[addr_i[31:2]];
		end
	end

endmodule


