`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:51:49 01/05/2020
// Design Name:   control
// Module Name:   D:/0IOS Games/SWORD/realsolid/cotrols.v
// Project Name:  realsolid
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: control
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cotrols;

	// Inputs
	reg clk;
	reg mark_button;
	reg tap_button;
	reg left_button;
	reg right_button;
	reg up_button;
	reg down_button;
	reg [2:0] mine_cnt;
	reg valid;
	reg status;
	reg transmit;
	reg initcue;

	// Outputs
	wire dead;
	wire [5:0] leftover;
	wire [3:0] x;
	wire [3:0] y;
	wire update;
	wire [7:0] A;
	wire [3:0] GMdata;
	wire [7:0] GMaddress;

	// Instantiate the Unit Under Test (UUT)
	control uut (
		.clk(clk), 
		.dead(dead), 
		.mark_button(mark_button), 
		.tap_button(tap_button), 
		.left_button(left_button), 
		.right_button(right_button), 
		.up_button(up_button), 
		.down_button(down_button), 
		.leftover(leftover), 
		.x(x), 
		.y(y), 
		.update(update), 
		.mine_cnt(mine_cnt), 
		.valid(valid), 
		.status(status), 
		.A(A), 
		.transmit(transmit), 
		.GMdata(GMdata), 
		.GMaddress(GMaddress), 
		.initcue(initcue)
	);
	always begin
		#10;
		clk=~clk;
	end
	integer i;
	initial begin
		// Initialize Inputs
		clk = 0;
		mark_button = 0;
		tap_button = 0;
		left_button = 0;
		right_button = 0;
		up_button = 0;
		down_button = 0;
		mine_cnt = 0;
		valid = 1;
		status = 0;
		transmit = 0;
		initcue = 0;
		#10;
		for(i=0;i<10;i=i+1)begin
			right_button=1;
			#20;
			right_button=0;
			status=1;
			#200;
			tap_button=1;
			#20;
			tap_button=0;
		end
		initcue=1;

	end
      
endmodule

