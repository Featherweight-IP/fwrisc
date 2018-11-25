/****************************************************************************
 * fwrisc_fpga_top.sv
 ****************************************************************************/

module clockdiv(
		input			clk_i,
		output			clk_o);
	reg[1:0]			clk_cnt;

	always @(posedge clk_i)
		clk_cnt <= clk_cnt + 1;

	assign clk_o = clk_cnt[1];	
endmodule
/**
 * Module: fwrisc_fpga_top
 * 
 * TODO: Add module documentation
 */
module fwrisc_fpga_top (
		input			clock,
		output			clock_o,
		output			led0,
		output			led1,
		output			tx,
		output			d0_p,
		output			d0_n,
		output			clk_o);

	wire				reset;
	wire				iaddr_ok;
	wire				idata_ok;



	wire	clock4;
	assign clock_o = clock4;

	clockdiv	u_div(
		.clk_i(clock),
		.clk_o(clock4));
	
	reg[15:0]			reset_cnt;
	reg[15:0]			reset_key;
	
	always @(posedge clock4) begin
		if (reset_key != 16'ha520) begin
			reset_key <= 16'ha520;
			reset_cnt <= 16'h0000;
		end else if (reset_cnt != 1000) begin
			reset_cnt <= reset_cnt + 1;
		end
	end
	
	assign reset = (reset_key != 16'ha520 || reset_cnt != 1000);
	
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

	assign iaddr_ok = (iaddr >= 32'h8000_0000 && iaddr <= 32'h8000_0018);
	
	
	fwrisc u_core (
		.clock   (clock4  ), 
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
	// RAM: 'h8000_8000
	// LED: 'hC000_0000
	reg[31:0]			ram_0[1023:0]; // 16k ram
	reg[31:0]			ram_1[1023:0]; // 16k ram
	reg[31:0]			ram_2[1023:0]; // 16k ram
	reg[31:0]			ram_3[1023:0]; // 16k ram
	reg[31:0]			rom[2047:0]; // 8k rom
	reg[31:0]			led;
	reg					iready_r, dready_r;
	
	assign iready = iready_r;
	assign dready = dready_r;

	assign d0_p = iaddr_ok; // iaddr[4]; // clk_cnt[0]; // iaddr[2]; // led[1];
	assign d0_n = led[3]; //data_ok; // clk_cnt[1]; // iaddr[3]; // led[2];
	assign tx   = dvalid && dwrite && (daddr[31:28] == 4'hc); // led[0];
	assign led0 = led[0];
	assign led1 = led[1];

	assign clk_o = led[2];
	
	initial begin
		$readmemh("rom.hex", rom);
	end
	
	reg[31:0]			addr_d;
	reg[31:0]			addr_i;
	
	always @(posedge clock4) begin
		addr_d <= daddr;
		addr_i <= iaddr;

		if (dvalid && dready && dwrite) begin
			if (daddr[31:28] == 4'h8 && 
				daddr[15:12] == 4'h2) begin
				if (dstrb[0]) ram_0[daddr[13:2]]<=dwdata[7:0];
				if (dstrb[1]) ram_1[daddr[13:2]]<=dwdata[15:8];
				if (dstrb[2]) ram_2[daddr[13:2]]<=dwdata[23:16];
				if (dstrb[3]) ram_3[daddr[13:2]]<=dwdata[31:24];
			end else if (daddr[31:28] == 4'hc) begin
				led <= dwdata;
			end
		end
	end
	
	always @(posedge clock4) begin
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
			drdata = {
				ram_3[addr_d[12:2]],
				ram_2[addr_d[12:2]],
				ram_1[addr_d[12:2]],
				ram_0[addr_d[12:2]]
				};
		end else begin
			drdata = rom[addr_d[12:2]];
		end
		
		if (addr_i[31:28] == 4'h8 && addr_i[15:12] == 4'h2) begin
			idata = {
				ram_3[addr_d[12:2]],
				ram_2[addr_d[12:2]],
				ram_1[addr_d[12:2]],
				ram_0[addr_d[12:2]]
				};
		end else begin
			idata = rom[addr_i[12:2]];
		end
	end

	/*
	assign idata_ok = (ivalid && iready)?(
		(iaddr == 32'h8000_0000 && idata == 32'hC000_00B7) ||
		(iaddr == 32'h8000_0004 && idata == 32'h0000_0113) ||
		(iaddr == 32'h8000_0008 && idata == 32'h0131_5193) ||
		(iaddr == 32'h8000_000C && idata == 32'h0030_A023) ||
		(iaddr == 32'h8000_0010 && idata == 32'h0011_0113) ||
		(iaddr == 32'h8000_0014 && idata == 32'hFF5F_F06F) ||
		(iaddr == 32'h8000_0018 && idata == 32'h0000_0013)
	):1;
	 */

endmodule


