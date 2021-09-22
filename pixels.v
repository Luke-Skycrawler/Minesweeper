module pixelgenerater(pixel_x,pixel_y,video_on,rgb,clk,
    request,GMdata,GMaddress,current_x,current_y
);

// it's a problem to share the ram of graphics, need flushing in vertical retrace
// bulit-in ROM 
// tested, fine with receiving
    input wire [9:0] pixel_x,pixel_y;
    input wire video_on,clk;
    output wire [11:0] rgb;
    // output reg [7:0] request=0;
    output wire request;
    input wire [3:0] GMdata,current_x,current_y;
    input wire [7:0] GMaddress;

    localparam width=20,block_cnt=256;

    assign request=(pixel_y>=480);
    // does it really goes that big?
    // serious things happens if it doesn't
    wire [4:0] x,y;
    wire area_on,v_on;
    wire [7:0] cnt_address;
    wire [4:0]  cntx,cnty;
    assign v_on=(pixel_y>=80)&(pixel_y<=400);
    assign area_on=(pixel_x>=160)&(pixel_x<=480)&(pixel_y>=80)&(pixel_y<=400);
    assign x=area_on?pixel_x%20:0;
    assign y=v_on?pixel_y%20:0;
    assign cnt_address=cnty*16+cntx;
    assign cntx=area_on?(pixel_x-160)/20:0;
    assign cnty=v_on?(pixel_y-80)/20:0;
    wire [11:0] tmp_rgb;
    // reg aux_WE=0;
    wire aux_WE;
    assign aux_WE=request;
    wire [7:0] A;
    wire [3:0] localcopy;
    assign A=aux_WE?GMaddress:cnt_address;
    // trust on the other side
    wire [1:0] tile_color;
    wire left_bound,up_bound;
    // [1]:up border;[0] left
    assign tile_color={up_bound,left_bound};
    assign left_bound=((cntx==current_x)|(cntx==current_x+1))&(cnty==current_y);
    assign up_bound=(cntx==current_x)&((cnty==current_y)|(cnty==current_y+1));
    // assign tile_color=(cntx==current_x)&(cnty==current_y);
    graphicsmemory aux_GM(A,aux_WE,clk,GMdata,localcopy);
    pixelarray PA1(localcopy,x,y,tmp_rgb,tile_color);
    localparam white=12'hfff;
    assign rgb=area_on?tmp_rgb:(video_on?white:0);
endmodule
module pixelarray(graphicsdata,x,y,rgb,tile_color);
// ROM
// tested, along with the following
    input wire [3:0] graphicsdata;
    input wire [4:0] x,y;
    output wire [11:0] rgb;
    input wire [1:0] tile_color;
    // block is 20*20, size is 8*8, but font is 16*16
    wire [6:0] address;
    wire area_on;
    wire [3:0] pixel_row;
    assign area_on=(x>=2)&(x<18)&(y>=2)&(y<18);
    // future use
    assign pixel_row=(~area_on)?0:y-2;
    assign address={pixel_row[3:1],graphicsdata};
    assign tile=(x==0)|(y==0);
    reg [7:0] pixel=0;
    // first 3 bits: position, 4 bits: graphicsdata
    always @*
        case (address)
            // 7'hx0:pixel=8'h00;
            // flag
            7'h01:pixel=8'h18;
            7'h11:pixel=8'h1c;
            7'h21:pixel=8'h1e;
            7'h31:pixel=8'h10;
            7'h41:pixel=8'h10;
            7'h51:pixel=8'h10;
            7'h61:pixel=8'h10;
            7'h71:pixel=8'h7c;
            // 1
            7'h09:pixel=8'h38;
            7'h19:pixel=8'h18;
            7'h29:pixel=8'h18;
            7'h39:pixel=8'h18;
            7'h49:pixel=8'h18;
            7'h59:pixel=8'h18;
            7'h69:pixel=8'h18;
            7'h79:pixel=8'h3c;
            // 2
            7'h0a:pixel=8'hfe;
            7'h1a:pixel=8'h03;
            7'h2a:pixel=8'h03;
            7'h3a:pixel=8'h7e;
            7'h4a:pixel=8'hc0;
            7'h5a:pixel=8'hc0;
            7'h6a:pixel=8'hc0;
            7'h7a:pixel=8'hff;
            // 3
            7'h0b:pixel=8'hfe;
            7'h1b:pixel=8'h03;
            7'h2b:pixel=8'h03;
            7'h3b:pixel=8'h1e;
            7'h4b:pixel=8'h03;
            7'h5b:pixel=8'h03;
            7'h6b:pixel=8'h03;
            7'h7b:pixel=8'hfe;
            // 4
            7'h0c:pixel=8'hc3;
            7'h1c:pixel=8'hc3;
            7'h2c:pixel=8'hc3;
            7'h3c:pixel=8'hff;
            7'h4c:pixel=8'h03;
            7'h5c:pixel=8'h03;
            7'h6c:pixel=8'h03;
            7'h7c:pixel=8'h03;
            // 5
            7'h0d:pixel=8'hff;
            7'h1d:pixel=8'hc0;
            7'h2d:pixel=8'hc0;
            7'h3d:pixel=8'hfe;
            7'h4d:pixel=8'h03;
            7'h5d:pixel=8'h03;
            7'h6d:pixel=8'h03;
            7'h7d:pixel=8'hfe;
            // 6
            7'h0e:pixel=8'h7f;
            7'h1e:pixel=8'hc0;
            7'h2e:pixel=8'hc0;
            7'h3e:pixel=8'hfe;
            7'h4e:pixel=8'hc3;
            7'h5e:pixel=8'hc3;
            7'h6e:pixel=8'hc3;
            7'h7e:pixel=8'h7e;
            // 7
            7'h0f:pixel=8'hff;
            7'h1f:pixel=8'h87;
            7'h2f:pixel=8'h07;
            7'h3f:pixel=8'h0e;
            7'h4f:pixel=8'h0c;
            7'h5f:pixel=8'h1c;
            7'h6f:pixel=8'h1c;
            7'h7f:pixel=8'h3c;
            default:pixel=0;
        endcase

    wire [3:0] pixel_collum;
    wire print;
    wire [2:0] pixel_select;
    assign pixel_collum=(~area_on)?0:(x-2);
    assign pixel_select=~(pixel_collum[3:1]);
    assign print=area_on?(pixel[pixel_select]):0;

    // wire r,g,b;
    wire [2:0] num;
    assign num=graphicsdata[2:0];
    localparam blue=12'h45c,
        green=12'h060,
        red=12'hf00,
        darkblue=12'h008,
        brown=12'ha53,
        cyan=12'h9e9,
        black=12'h000,
        grey=12'h888,
        white=12'hfff,
        light=12'haaa;
    wire [11:0] color,regular_color;
    assign regular_color=(num==1)?blue:
        (num==2)?green:
        (num==3)?red:
        (num==4)?darkblue:
        (num==5)?brown:
        (num==6)?cyan:
        (num==7)?black:
        grey;

    reg flag;
    reg [11:0] flagcolor;
    always @*
        if((graphicsdata==1)&print)begin
            flag=1;
            flagcolor=(y>=8)?black:red;
        end
        else flag=0;
    assign color=flag?flagcolor:regular_color;
    wire [11:0] background;
    assign background=graphicsdata[3]?grey:light;
    // collor leave to later
    // assign rgb=tile?(tile_color?black:white):((print)?color:(graphicsdata[3])?grey:light);
    assign rgb=(x==0)?(tile_color[0]?black:white):(y==0)?(tile_color[1]?black:white):print?color:background;
endmodule    
