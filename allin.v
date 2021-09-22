`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:44:39 01/05/2020
// Design Name:   top
// Module Name:   D:/0IOS Games/SWORD/realsolid/allin.v
// Project Name:  realsolid
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module allin;

	// Inputs
	reg clk;
	reg sw;
	reg reset;

	// Outputs
	wire SEGLED_CLK;
	wire SEGLED_DO;
	wire SEGLED_PEN;
	wire SEGLED_CLR;
	wire [11:0] rgb;
	wire vsync;
	wire hsync;

	// Bidirs
	wire [4:0] BTN_X;
	wire [3:0] BTN_Y;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.sw(sw), 
		.reset(reset), 
		.BTN_X(BTN_X), 
		.BTN_Y(BTN_Y), 
		.SEGLED_CLK(SEGLED_CLK), 
		.SEGLED_DO(SEGLED_DO), 
		.SEGLED_PEN(SEGLED_PEN), 
		.SEGLED_CLR(SEGLED_CLR), 
		.rgb(rgb), 
		.vsync(vsync), 
		.hsync(hsync)
	);
	always begin
		#10;
		clk=~clk;
	end
	initial begin
		// Initialize Inputs
		clk = 0;
		sw = 0;
		reset = 0;


	end
      
endmodule

