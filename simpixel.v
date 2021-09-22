`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:36:57 01/03/2020
// Design Name:   pixelgenerater
// Module Name:   D:/0IOS Games/SWORD/pixels/pixelsim.v
// Project Name:  pixels
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: pixelgenerater
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module pixelsim;

	// Inputs
	reg [9:0] pixel_x;
	reg [9:0] pixel_y;
	reg video_on;
	reg clk;
	reg [3:0] GMdata;
	reg [7:0] GMaddress;
	reg [3:0] currrent_x,current_y;

	// Outputs
	wire [11:0] rgb;
	wire request;

	// Instantiate the Unit Under Test (UUT)
	pixelgenerater uut (
		.pixel_x(pixel_x), 
		.pixel_y(pixel_y), 
		.video_on(video_on), 
		.rgb(rgb), 
		.clk(clk), 
		.request(request), 
		.GMdata(GMdata), 
		.GMaddress(GMaddress),
		.current_x(current_x),
		.current_y(current_y)
	);
	always begin
		#10;
		clk=~clk;
	end
	initial begin
		// Initialize Inputs
		pixel_x = 0;
		pixel_y = 0;
		video_on = 0;
		clk = 0;
		GMdata = 4'h9;
		GMaddress = 0;
		current_x=10;
		current_y=0;

		#10;
		video_on=1;
		#20;
		video_on=0;
		pixel_y=480;
		#1000;
		// for(pixel_y=0;pixel_y<600;pixel_y=pixel_y+80)
		// 	for(pixel_x=0;pixel_x<800;pixel_x=pixel_x+100)begin
		// 		if(pixel_x<640&pixel_y<480)video_on=1;
		// 			else video_on=0;
		// 		#20;
		// 	end
		pixel_y=80;
		for(pixel_x=160;pixel_x<390;pixel_x=pixel_x+1)begin
			if(pixel_x<640&pixel_y<480)video_on=1;
				else video_on=0;
			#20;
		end
		for(pixel_y=80;pixel_y<400;pixel_y=pixel_y+1)begin
				if(pixel_x<640&pixel_y<480)video_on=1;
					else video_on=0;
				#20;
			end
	end
	integer i;
    always @(posedge request)
		for(i=0;i<=15;i=i+1)begin
			GMaddress=i;
			GMdata=8+i%8;
			#20;
		end
endmodule

