/*===================================
  PWM CONTROLLER FOR AUDIO GENERATION
  ===================================*/
`timescale 1ps / 1ps
module PWM_Controller (
			PWM_CW,               // Ports declared
			PWM_out,					         
			clk
	);
	
	input clk;            		//Port type declared
	input [9:0] PWM_CW;   		// 10 bit PWM input
	
	output reg PWM_out; 			// 1 bit PWM output
	wire [9:0] counter_out;  	// 10 bit counter output

	always @ (posedge clk)
	begin
		if (PWM_CW > counter_out)
			PWM_out <= 1;
		else 
			PWM_out <= 0;
	end
	
	counter counter_inst(
		.clk (clk),
		.counter_out (counter_out)
		);
	
endmodule



/*******************************
      C O U N T E R          
********************************/
module counter (
	clk,										//Counter clock
	counter_out   			 				// 8 bit output from the counter
	);

	input clk;								// clock declared as an input port
	output reg [9:0] counter_out;  	// counter_out declared as an 8 bit output register

	initial
	begin
		counter_out = 0;
	end

	
	always @(posedge clk)
	begin
		counter_out <= #1 counter_out + 1'b1;
	end
		
endmodule				
