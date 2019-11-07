/****************************************************************************
 * fwrisc_fpga_top.sv
 * 
 * Copyright 2018 Matthew Ballance
 * 
 * Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in
 * writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See
 * the License for the specific language governing
 * permissions and limitations under the License.
 * 
 ****************************************************************************/

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
		output			d0_n);

	wire				reset;
	wire				iaddr_ok;
	wire				idata_ok;

	reg[1:0]			clk_cnt;

	// /4 clock divider
	always @(posedge clock)
		clk_cnt <= clk_cnt + 1;

	wire	clock4 = clk_cnt[1];
	assign clock_o = clock4;

	
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
	wire[3:0]			dwstb;
	wire				dwrite;
	wire				dvalid;
	wire				dready;

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
		.dwstb   (dwstb  ), 
		.dwrite  (dwrite ), 
		.dvalid  (dvalid ), 
		.dready  (dready ));

	// ROM: 'h8000_0000
	// RAM: 'h8000_8000
	// LED: 'hC000_0000
	reg[7:0]			ram_0[1023:0]; // 16k ram
	reg[7:0]			ram_1[1023:0]; // 16k ram
	reg[7:0]			ram_2[1023:0]; // 16k ram
	reg[7:0]			ram_3[1023:0]; // 16k ram
	reg[31:0]			rom[4095:0];   // 16k rom
	reg[31:0]			led;
	reg[31:0]			tx_r;
	reg					iready_r, dready_r;
	
	assign iready = iready_r;
	assign dready = dready_r;

	assign d0_p = iaddr_ok; // iaddr[4]; // clk_cnt[0]; // iaddr[2]; // led[1];
	assign d0_n = led[3]; //data_ok; // clk_cnt[1]; // iaddr[3]; // led[2];
	assign tx   = tx_r[0];
	assign led0 = led[0];
	assign led1 = led[1];

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
				daddr[15:12] == 4'h8) begin
//				$display("Write to RAM: 'h%08h", daddr[13:2]);
				if (dwstb[0]) ram_0[daddr[13:2]] <= dwdata[7:0];
				if (dwstb[1]) ram_1[daddr[13:2]] <= dwdata[15:8];
				if (dwstb[2]) ram_2[daddr[13:2]] <= dwdata[23:16];
				if (dwstb[3]) ram_3[daddr[13:2]] <= dwdata[31:24];
			end else if (daddr[31:28] == 4'hc) begin
				if (daddr[3:2] == 4'h0) begin
					led <= dwdata;
				end else if (daddr[3:2] == 4'h1) begin
					tx_r <= dwdata;
				end
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
		if (addr_d[31:28] == 4'h8 && addr_d[15:12] == 4'h8) begin 
			drdata = {
				ram_3[addr_d[13:2]],
				ram_2[addr_d[13:2]],
				ram_1[addr_d[13:2]],
				ram_0[addr_d[13:2]]
				};
			/*
			$display("read 'h%08h 'h%0h", addr_d[13:2], 
					{ram_3[addr_d[13:2]],
				ram_2[addr_d[13:2]],
				ram_1[addr_d[13:2]],
				ram_0[addr_d[13:2]]
				});
			 */
		end else begin
			drdata = rom[addr_d[13:2]];
		end
		
		if (addr_i[31:28] == 4'h8 && addr_i[15:12] == 4'h8) begin
			idata = {
				ram_3[addr_d[13:2]],
				ram_2[addr_d[13:2]],
				ram_1[addr_d[13:2]],
				ram_0[addr_d[13:2]]
				};
		end else begin
			idata = rom[addr_i[13:2]];
		end
	end

endmodule


