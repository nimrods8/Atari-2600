/* Atari on an FPGA
Masters of Engineering Project
Cornell University, 2007
Daniel Beer
Atari2600.v
Atari system module. Expects clock, controller and switch inputs and a ROM port.
Outputs are the video signal and NTSC control signals.
*/
module Atari2600(CLOCKPIXEL, // 3.58 Mhz pixel clock input
	CLOCKBUS, // 1.19 Mhz bus clock input
	COLOROUT, // 8 bit indexed color output
	ROM_CS, // ROM chip select output
	ROM_Addr, // ROM address output
	ROM_Dout, // ROM data input
	ROM_RW_n, // R_Wn of ROM (output)
	RES_n, // Active low reset input
	HSYNC, // Video horizontal sync output
	HBLANK, // Video horizontal blank output
	VSYNC, // Video verical sync output
	VBLANK, // Video verical blank output
	SW_COLOR, // Color/BW switch input
	SW_DIFF, // Difficulty switch input
	SW_SELECT, // Select switch input
	SW_START, // Start switch input
	Leds, HEX4, HEX5, 
	JOY_A_in, // Joystick A inputs
	JOY_B_in); // Joystick B inputs
	input CLOCKPIXEL, CLOCKBUS;
	output [7:0] COLOROUT;
	output ROM_CS, ROM_RW_n;
	output [11:0] ROM_Addr;
	output HSYNC, HBLANK, VSYNC, VBLANK;
	input [7:0] ROM_Dout;
	input RES_n;
	input SW_COLOR, SW_SELECT, SW_START;
	input [1:0] SW_DIFF;
	input [4:0] JOY_A_in, JOY_B_in;
	
	// debug
	output [9:0] Leds;
	output [7:0] HEX4, HEX5;
	
	// MOS6507 CPU
	wire [12:0] CPU_Addr;
	reg [7:0] CPU_Din;
	wire [7:0] CPU_Dout;
	wire CPU_R_W_n;
	wire CPU_CLK_n;
	wire CPU_RDY;
	wire CPU_RES_n;
	
	assign ROM_RW_n = CPU_R_W_n;
	

	
	MOS6507 cpu(.A(CPU_Addr), .Din(CPU_Din), .Dout(CPU_Dout), .R_W_n(CPU_R_W_n),
						.CLK_n(CPU_CLK_n), .RDY(CPU_RDY), .RES_n(CPU_RES_n));

	assign CPU_CLK_n = CLOCKBUS;
	assign CPU_RES_n = RES_n;
	assign ROM_Addr = CPU_Addr[11:0];
	assign ROM_CS = CPU_Addr[12];
	// MOS6532 "RIOT" module
	wire [6:0] RIOT_Addr;
	wire [7:0] RIOT_Din;
	wire [7:0] RIOT_Dout;
	wire RIOT_CS, RIOT_CS_n, RIOT_R_W_n, RIOT_RS_n, RIOT_RES_n, RIOT_CLK;
	wire RIOT_IRQ_n;
	wire [7:0] RIOT_PAin, RIOT_PBin;
	wire [7:0] RIOT_PAout, RIOT_PBout;

	RIOT r1(.A(RIOT_Addr), .Din(RIOT_Din), .Dout(RIOT_Dout), .CS(RIOT_CS), .CS_n(RIOT_CS_n),
			.R_W_n(RIOT_R_W_n), .RS_n(RIOT_RS_n), .RES_n(RIOT_RES_n), .IRQ_n(RIOT_IRQ_n),
			.CLK(RIOT_CLK), .PAin(RIOT_PAin), .PAout(RIOT_PAout), .PBin(RIOT_PBin),
			.PBout(RIOT_PBout) /*, .HEX4(HEX4), .HEX5(HEX5)*/);
	assign RIOT_Addr = CPU_Addr[6:0];
	assign RIOT_Din = CPU_Dout;
	assign RIOT_CS = CPU_Addr[7];
	assign RIOT_CS_n = CPU_Addr[12];
	assign RIOT_R_W_n = CPU_R_W_n;
	assign RIOT_RS_n = CPU_Addr[9];
	assign RIOT_RES_n = RES_n;
	assign RIOT_CLK = CLOCKBUS;
	assign RIOT_PAin = {JOY_A_in[3:0], JOY_B_in[3:0]};
	assign RIOT_PBin = {SW_DIFF, 2'd0, SW_COLOR, 1'd0, SW_SELECT, SW_START};
	// TIA module
	wire [5:0] TIA_Addr;
	wire [7:0] TIA_Din;
	wire [7:0] TIA_Dout;
	wire [2:0] TIA_CS_n;
	wire TIA_CS;
	wire TIA_R_W_n;
	wire TIA_RDY;
	wire TIA_MASTERCLK;
	wire TIA_CLK0;
	wire TIA_CLK2;
	wire [1:0] TIA_Ilatch;
	wire [3:0] TIA_Idump;
	wire TIA_HSYNC, TIA_HBLANK;
	wire TIA_VSYNC, TIA_VBLANK;
	wire [7:0] TIA_COLOROUT;
	wire TIA_RES_n;
	wire [3:0] audiov0, audiov1;
	wire aud0, aud1;
	wire [15:0] AUD_SIGNAL;
	
	TIA t1(.A(TIA_Addr), .Din(TIA_Din), .Dout(TIA_Dout), .CS_n(TIA_CS_n), .CS(TIA_CS),
		.R_W_n(TIA_R_W_n), .RDY(TIA_RDY), .MASTERCLK(TIA_MASTERCLK), .CLK2(TIA_CLK2),
		.idump_in(TIA_dump), .Ilatch(TIA_Ilatch), .HSYNC(TIA_HSYNC), .HBLANK(TIA_HBLANK),
		.VSYNC(TIA_VSYNC), .VBLANK(TIA_VBLANK), .COLOROUT(TIA_COLOROUT), .RES_n(TIA_RES_n), .Leds( Leds), .HEX4(HEX4), .HEX5(HEX5),
		.AUD0( aud0), 			//audio pin 0
		.AUD1( aud1), 			//audio pin 1
		.audv0( audiov0), 	//audio volume for use with external xformer module
		.audv1( audiov1) 		//audio volume for use with external xformer module
	);

	//======== A U D I O    volume control ========
	audio_xformer audx( .AUD0( aud0), .AUD1( aud1),
							  .AUDV0( audiov0), .AUDV1( audiov1), 
							  .AUD_SIGNAL (AUD_SIGNAL));
							  
   //assign Leds[5] = aud0;
	//assign Leds[6] = aud1;


	assign TIA_Addr = CPU_Addr[5:0];
	assign TIA_Din = CPU_Dout;
	assign TIA_CS_n = {CPU_Addr[12], CPU_Addr[7], 1'b0};
	assign TIA_CS = 1'b1;
	assign TIA_R_W_n = CPU_R_W_n;
	assign CPU_RDY = TIA_RDY /*& SW_SELECT*/;   //TIA_RDY = CPU_RDY;			// DEBUG 20-02-17 add SW_SELECT, not to simulations....
	assign TIA_CLK2 = CLOCKBUS;
	assign TIA_MASTERCLK = CLOCKPIXEL;
	assign TIA_RES_n = RES_n;
	assign COLOROUT = TIA_COLOROUT;
	assign HSYNC = TIA_HSYNC;
	assign HBLANK = TIA_HBLANK;
	assign VSYNC = TIA_VSYNC;
	assign VBLANK = TIA_VBLANK;
	assign TIA_Ilatch = {JOY_B_in[4], JOY_A_in[4]};

	// Bus Controller
	always @(CPU_Addr, RIOT_Dout, TIA_Dout, ROM_Dout)
	begin
		if (CPU_Addr[12])
			CPU_Din <= ROM_Dout;
		else if (CPU_Addr[7])
			CPU_Din <= RIOT_Dout;
		else
			CPU_Din <= TIA_Dout;
	end
endmodule
