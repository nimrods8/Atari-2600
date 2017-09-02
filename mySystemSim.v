`define GRANDPRIX

/* Atari on an FPGA
Masters of Engineering Project
Cornell University, 2007
Daniel Beer
MySystemSim.v
Top level system for simulation purposes. This can be run in the Quartus II
simulator by supplying it with the necessary clocks and inputs.
*/
module MySystemSim(CLOCK_50, // 50 Mhz clock input
						CLOCK_27, // 27 Mhz clock input
						RES_n, // Active low reset input
						ATARI_CLOCKBUS16, // Atari 1.19 Mhz clock input * 16
						ATARI_CLOCKPIXEL16, // Atari 3.58 Mhz clock input * 16
						ATARI_ROM_CS, // ROM chip select output
						ATARI_ROM_Addr, // ROM address output
						ATARI_ROM_Dout); // ROM data input

	input CLOCK_50, CLOCK_27, RES_n;
	input ATARI_CLOCKBUS16, ATARI_CLOCKPIXEL16;
	output ATARI_ROM_CS;
	output [11:0] ATARI_ROM_Addr;
	output [7:0] ATARI_ROM_Dout;
	wire ATARI_CLOCKPIXEL, ATARI_CLOCKBUS;
	wire [7:0] ATARI_COLOROUT;
	wire ATARI_ROM_CS;
	wire [11:0] ATARI_ROM_Addr;
	wire [7:0] ATARI_ROM_Dout;
	wire ATARI_HSYNC, ATARI_HBLANK, ATARI_VSYNC, ATARI_VBLANK;
	wire RES_n;

	// Atari System
	Atari2600 at2600(.CLOCKPIXEL(ATARI_CLOCKPIXEL), .CLOCKBUS(ATARI_CLOCKBUS),
	.COLOROUT(ATARI_COLOROUT), .ROM_CS(ATARI_ROM_CS),
	.ROM_Addr(ATARI_ROM_Addr), .ROM_Dout(ATARI_ROM_Dout),
	.RES_n(RES_n), .ROM_RW_n( rw_n));
/*
	// Cartridge
	Cartridge2k cart
	(.address(ATARI_ROM_Addr[10:0]),
	.clken(ATARI_ROM_CS),
	.clock(ATARI_CLOCKBUS),
	.q(ATARI_ROM_Dout));
*/

`ifdef GRANDPRIX

	// Uncomment this block to use 4k cartridges
	Cartridge4k c4k
	//#(.init_file("./tools/grandprx.hex"))
	(.address(ATARI_ROM_Addr),
	.clken(ATARI_ROM_CS),
	.clock(ATARI_CLOCKBUS),
	.q(ATARI_ROM_Dout));
	defparam c4k.init_file = "./tools/grandprx.hex";

`else	

	reg rom_switch, rom_switch_tst;
	
	always @ ( ATARI_ROM_Addr)
	begin
		if( ~RES_n) begin
			rom_switch = 0;
			rom_switch_tst = 0;
		end
		else if( ATARI_ROM_CS /*&& ~rw_n*/)
		begin
			if( rom_switch == 0 && ATARI_ROM_Addr == 12'hFF9)
			begin
				rom_switch = 1;
				if( rw_n)
				   rom_switch_tst = 1;
			end
			else if( rom_switch == 1 && ATARI_ROM_Addr == 12'hFF8)
			begin
				rom_switch = 0;
				if( rw_n)
				   rom_switch_tst = 1;
			end
			else 
				rom_switch = rom_switch;
				
				

		end
	end // always

	
	Cartridge8k cart8k
	(.address( { rom_switch, ATARI_ROM_Addr } ),
	.clken(ATARI_ROM_CS),
	.clock(ATARI_CLOCKBUS),
	.q(ATARI_ROM_Dout));	
	//defparam cart8k.init_file = "./tools/mspacman.hex";
	defparam cart8k.init_file = "./tools/testms1.hex";

`endif	
	
	// Clock Dividers
	
	reg [3:0] cnt = 0;
	reg		 reset_dividers;
	
	always @ (posedge ATARI_CLOCKBUS16 or negedge RES_n)
	begin
		if( ~RES_n)
		begin
			if( cnt == 4) reset_dividers <= 1;
			else begin
				reset_dividers <= 0;
				cnt <= cnt + 4'd1;
			end
		end
		else
			cnt <= 4'h00;
	end
	
	
	wire ATARI_CLOCKPIXEL16, ATARI_CLOCKBUS16;

	ClockDiv16 clkd1(.inclk(ATARI_CLOCKPIXEL16),
					.outclk(ATARI_CLOCKPIXEL),
					.reset_n(reset_dividers));

	ClockDiv16 clkd2 (.inclk(ATARI_CLOCKBUS16),
				.outclk(ATARI_CLOCKBUS),
				.reset_n(reset_dividers));
endmodule
