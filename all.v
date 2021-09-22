`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   06:58:00 01/04/2020
// Design Name:   top
// Module Name:   D:/0IOS Games/SWORD/realsolid/all.v
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

module all;

	// Inputs
	reg clk;
	reg mark;
	reg tap;
	reg left_button;
	reg right_button;
	reg up_button;
	reg down_button;
	reg D;
	reg WE;
	reg [7:0] write;

	// Outputs
	wire dead;
	wire rgb;
	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.dead(dead), 
		.mark(mark), 
		.tap(tap), 
		.left_button(left_button), 
		.right_button(right_button), 
		.up_button(up_button), 
		.down_button(down_button), 
		.D(D), 
		.WE(WE), 
		.write(write),
		.rgb(rgb)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		mark = 0;
		tap = 0;
		left_button = 0;
		right_button = 0;
		up_button = 0;
		down_button = 0;
		D = 0;
		WE = 0;
		write = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

