/* Atari on an FPGA
Masters of Engineering Project
Cornell University, 2007
Daniel Beer
MOS6507.v
Wrapper for a 6502 CPU module that emulates the MOS 6507.
*/
module MOS6507 (A, // 13 bit address bus output
					Din, // 8 bit data in bus
					Dout, // 8 bit data out bus
					R_W_n, // Active low read/write output
					CLK_n, // Negated clock signal
					RDY, // Active high ready line
					RES_n); // Active low reset line

	output [12:0] A;
	input [7:0] Din;
	output [7:0] Dout;
	output R_W_n;
	input CLK_n;
	input RDY;
	input RES_n;
	// Instatiate a 6502 and selectively connect used lines
	wire [23:0] T65_A;
	wire T65_CLK;

	T65 t0(.Mode(2'b0), .Res_n(RES_n), .Clk(T65_CLK), .Rdy(RDY), .Abort_n(1'b1), .IRQ_n(1'b1),
		.NMI_n(1'b1), .SO_n(1'b1), .R_W_n(R_W_n), .A(T65_A), .DI(Din), .DO(Dout),
		.Sync(), .EF(), .MF(), .XF(), .ML_n(), .VP_n(), .VDA(), .VPA());
	
	assign A = T65_A[12:0];
	assign T65_CLK = ~CLK_n;

endmodule
