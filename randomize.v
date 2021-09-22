`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:16:42 01/04/2020
// Design Name:   RanGen
// Module Name:   D:/0IOS Games/SWORD/realsolid/randomize.v
// Project Name:  realsolid
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: RanGen
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module randomize;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] seed;
	// Outputs
	wire [7:0] Y;

	// Instantiate the Unit Under Test (UUT)
	RanGen uut (
		.clk(clk), 
		.reset(reset)
		,.seed(seed),
		.Y(Y)
	);
	always begin
		#10;
		clk=~clk;
	end
	initial begin
		// Initialize Inputs
		clk = 0;
		reset=0;
		#10;
		#20;
		seed=8'he2;
		reset=1;
		#20;
	end
      
endmodule

