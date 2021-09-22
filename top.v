module control(clk,dead,mark_button,tap_button,left_button,right_button,up_button,down_button,leftover,
    // control signals, six buttons ,really need to design how the buttons work
    x,y,update,mine_cnt,valid,status,A,
// communication for mine_cnt unit
    transmit,GMdata,GMaddress,
// while transmitting disable all activities
    initcue,newgame
    );
    // core unit, full access to the graphics(r/s)
    // so the graphics memory is put inside, connects to the other modules by ports
    input wire clk,valid,status;
    input wire [2:0] mine_cnt;
    output reg update=0,dead=0;
    output reg [7:0] A=0;
    output reg [3:0] x=0,y=0;
    input wire transmit;
    output wire [7:0] GMaddress;
    output wire [3:0] GMdata;
    input wire initcue,newgame;
    output reg [5:0] leftover=40;

    input wire tap_button,mark_button;
    input wire left_button,right_button,up_button,down_button;
    // these buttons should be async,typically at the posedge;
    // and should not be requested too often
    reg transmit_active=0;
    wire mark,tap;
    assign mark=mark_button&(~transmit_active)&(~dead);
    assign tap=tap_button&(~transmit_active)&(~dead);
    // block out all requests

    localparam h_size=16,v_size=16;
    // easy mode, tag

    assign move=(~transmit_active)&(~dead)&(left_button|right_button|up_button|down_button);
    // subject to changes of buttons, released from multiplications
    reg current_pos_status=0;
    reg [2:0] current_cnt=0;
    always @(posedge clk)if(valid)begin
        current_pos_status=status;
        current_cnt=mine_cnt;
    end
    wire [3:0] S,feed;
    // untapped 0,marked 1,others starts with 1, followed by mine_cnt
    
    // wire [7:0] write_address;
    // assign A=WE?write_address:reg_A;
    // future development
    reg WE=0;
    reg [3:0] D;
    wire [7:0] direct_address;
    reg [7:0] j=0;
    assign direct_address=transmit_active?j:A;
    // transmitting can ruin anything, including initialization

    graphicsmemory GM(direct_address,WE,clk,D,S);
    // deal with write later
    assign feed={1'b1,mine_cnt};
    reg [7:0] tmp;
    reg logic_latch0=0,logic_latch1=0,pre_new=1;
    always @(posedge clk)begin
        if(move)begin
            if(left_button&&(x>0))begin
                x=x-1;
                A=A-1;
            end
            else if(right_button&&(x<h_size-1))begin
                x=x+1;
                A=A+1;
            end
            else if(up_button&&(y>0))begin
                y=y-1;
                A=A-h_size;
            end
            else if(down_button&&y<v_size-1)begin
                y=y+1;
                A=A+h_size;
            end
        end
        if(initcue&~logic_latch0)begin
            tmp=A;
            D=4'b0;
            WE=1;
            logic_latch0=1;
            A=0;
        end
        else if(logic_latch0)
            if(A<8'hff)A=A+1;
            else begin
                logic_latch0=0;
                A=tmp;
                dead=0;
                leftover=40;
                // mid
            end
        else if(logic_latch1&valid&~update)begin
            D=feed;
            logic_latch1=0;
            WE=1;
        end
        else if(valid&~update)begin
            if(mark&~(S[3]))begin
                D=S?0:1;
                WE=1;
                if(S)leftover=leftover+1;
                    else if(leftover)leftover=leftover-1;
            end
            else if(~newgame&tap&(S==0))
                if(current_pos_status)dead=1;
                    else begin
                        D=feed;
                        WE=1;
                    end
            else WE=0;
        end
        else WE=0;
        if(pre_new&~newgame)begin
            logic_latch1=1;
            update=1;
        end
        else if(move&valid)update=1;
        else update=0;
        pre_new=newgame;

    end

    // move can't osilate around, should be debounced

    wire transmit_ready;
    assign transmit_ready=~(move|tap|mark)&transmit&(valid)&(~update);

    reg transmit_over=0;
    always @(posedge clk)begin
        if(transmit_ready==0)transmit_over=0;
        if(transmit_active)
            if(j<8'hff)j=j+1;
            else begin
                transmit_active=0;
                j=0;
                transmit_over=1;
            end
        if(transmit_ready&~(transmit_over|transmit_active))begin
            transmit_active=1;
            j=0;
        end
    end
    assign GMdata=S;
    assign GMaddress=direct_address;
endmodule
module graphicsmemory(A,WE,clk,D,S);
    input wire [7:0] A;
    input wire clk,WE;
    input wire [3:0] D;
    output wire [3:0] S;
    RAM256X1S b0(.D(D[0]),.WE(WE),.WCLK(clk),.A(A),.O(S[0])),
    b1(.D(D[1]),.WE(WE),.WCLK(clk),.A(A),.O(S[1])),
    b2(.D(D[2]),.WE(WE),.WCLK(clk),.A(A),.O(S[2])),
    b3(.D(D[3]),.WE(WE),.WCLK(clk),.A(A),.O(S[3]));
endmodule
module cnt_mine(clk,A,x,y,update,status,valid,mine_cnt,address,tmp_status);
// testified, works fine
// read access to dataRAM, no other privileges
// update should be a delta function then go down, and can't be requested too often, say 9 clk cycles
// only receives update signal when valid
    input wire [7:0] A;
    input wire [3:0] x,y;
    input wire clk,update;
    output reg [2:0] mine_cnt=0;
    output reg valid=1,status=0;
    input wire tmp_status;
    output wire [7:0] address;

    reg [7:0] t=0;
    reg [3:0] i=0;

    always@(posedge clk)
        if(update&valid)begin
            valid=0;
            i=0;
            // i is keeped at zero
            t=A;
        end
        else if(~valid)begin
            if(i==8)valid=1;
            if(i==0)begin
                status=tmp_status;
                mine_cnt=0;
            end
            i=i+1;
            mine_cnt=mine_cnt+tmp_status;
        end
        else i=0;
    // i is always changing, had to put all variables in

    // always@(posedge clk)
    //     if(~valid)i=i+1;
    //         else i=0;
    
    wire [7:0] left,right,up,down,lu,ru,ld,rd;
    localparam h_size=16,v_size=16;
    // easy, tag
    wire left_bound,right_bound,up_bound,down_bound;
    assign left_bound=(x==0);
    assign right_bound=(x==h_size-1);
    assign up_bound=(y==0);
    assign down_bound=(y==v_size-1);
    // boundary conditions
    assign left=left_bound?t:t-1;
    assign right=right_bound?t:t+1;
    assign up=up_bound?t:t-h_size;
    assign lu=(left_bound|up_bound)?t:up-1;
    assign ru=(right_bound|up_bound)?t:up+1;
    assign down=down_bound?t:t+h_size;
    assign ld=(left_bound|down_bound)?t:down-1;
    assign rd=(right_bound|down_bound)?t:down+1;

    assign address=(i==0)?t:
        (i==1)?left:
        (i==2)?right:
        (i==3)?lu:
        (i==4)?up:
        (i==5)?ru:
        (i==6)?ld:
        (i==7)?down:
        (i==8)?rd:t;
endmodule
module top(clk,sw,rstn,reset,	
    BTN_X,BTN_Y,
    SEGLED_CLK,SEGLED_DO,SEGLED_PEN,SEGLED_CLR,
    rgb,vsync,hsync);
    input wire clk,sw,reset,rstn;
    output wire [11:0] rgb;
    output wire vsync,hsync;
    inout [4:0]BTN_X;
	inout [3:0]BTN_Y;
    output SEGLED_CLK,
        SEGLED_DO,
        SEGLED_PEN,
        SEGLED_CLR;
    reg mark,tap,left_button,right_button,up_button,down_button,restart;
    wire update,valid,status,data,request,p_tick,video_on,dead;
    wire [3:0] current_x,current_y,GMdata;
    wire [5:0] leftover;
    wire [7:0] read,A,GMaddress,Y;
    wire [9:0] pixel_x,pixel_y;
    wire [2:0] mine_cnt;
    reg clk_50;
    reg [31:0]clkdiv;

	always@(posedge clk) begin
		clkdiv <= clkdiv + 1'b1;
	end
    reg [26:0] wall_time;
    reg [3:0] sec_0,sec_1,sec_2;
    wire [15:0] display_time;
    assign display_time={4'b0,sec_2,sec_1,sec_0};
    always@(posedge clk)begin
        if(~dead)begin
            if(wall_time<100000000)wall_time=wall_time+1;
                else begin
                    wall_time=0;
                    if(sec_0<9)sec_0=sec_0+1;
                        else begin
                            if(sec_1<9)begin
                                sec_1=sec_1+1;
                                sec_0=0;
                            end
                                else if(sec_2<9)begin
                                    sec_2=sec_2+1;
                                    sec_1=0;
                                    sec_0=0;
                                end
                        end
                end
        end
        if(newgame)begin
            wall_time=0;
            sec_0=0;
            sec_1=0;
            sec_2=0;
        end
    end
    reg WE=0,D=0;
    reg [8:0] i=0;
    reg logic_sgn0=0,
        logic_sgn1=0,
        logic_sgn2=0,
        logic_sgn3=0;
    reg [8:0] loop0,loop1;
    reg [8:0] write,readrandom,writerandom;
    reg newgame=1,werandom,Drandom,resetbar=1;
    always @(posedge clk) begin
        if(restart)resetbar=1;

        if(logic_sgn3)
            if(readrandom<255)begin
                write=i+readrandom+A;
                readrandom=readrandom+1;
                D=datarandom;
            end
            else begin
                WE=0;
                logic_sgn3=0;
                newgame=0;
            end
        if(logic_sgn2)//move to before is Ok, and lose the else 
            if(datarandom==0)begin
                logic_sgn2=0;
                i=readrandom;
                readrandom=0;
                write=i+A;
                logic_sgn3=1;
                WE=1;
            end
            else readrandom=readrandom+1;

        if(restart)begin
            D=0;
            Drandom=0;
            WE=1;
            werandom=1;
            logic_sgn0=1;
            loop0=0;
            write=0;
            writerandom=0;
        end
        // new part
        else if(logic_sgn0)
            if(loop0<255)begin
                loop0=loop0+1;
                write=loop0;
                writerandom=loop0;
            end
            else begin
                loop0=0;
                logic_sgn0=0;
                werandom=0;
                WE=0;
                newgame=1;
            end
        if(newgame&tap)begin
            // newgame=0;
            Drandom=1;
            logic_sgn1=1;
            loop1=0;
        end
        if(logic_sgn1)// could drop else
        if(loop1<40)begin
            // 40 randoms
            loop1=loop1+1;
            writerandom=Y;     
            werandom=1;
        end
        else begin
            werandom=0; 
            resetbar=0;      
            logic_sgn1=0;
            logic_sgn2=1;
            readrandom=0;
        end
    end

    always @(posedge clk)clk_50=~clk_50;
    wire datarandom;
    RAM_data datamemory(D,WE,clk,read,write[7:0],data),
        datamemoryrandom(Drandom,werandom,clk,readrandom[7:0],writerandom[7:0],datarandom);
    cnt_mine CNT(clk,A,current_x,current_y,update,status,valid,mine_cnt,read,data);
    control centralcontrolunit(clk,dead,mark,tap,left_button,right_button,up_button,down_button,leftover,
    current_x,current_y,update,mine_cnt,valid,status,A,
    request,GMdata,GMaddress,
    restart,newgame
    );
    pixelgenerater PG(pixel_x,pixel_y,video_on,rgb,clk,
    request,GMdata,GMaddress,current_x,current_y);
    vga_sync vga(clk_50,reset,hsync,vsync,video_on,p_tick,pixel_x,pixel_y);
    wire [4:0] keyCode;
    wire keyReady;
    Keypad k0 (.clk(clkdiv[15]), .keyX(BTN_Y), .keyY(BTN_X), .keyCode(keyCode), .ready(keyReady));
    RanGen LFSR(clk,resetbar,Y);

	wire [31:0] segTestData;
	wire [3:0] sout,lb0,lb1;
    wire [15:0] tifo;
    wire [15:0] inform;
    wire [7:0] effect;
    assign inform={status,mine_cnt,current_x,current_y,GMdata};
    assign tifo=dead?16'hdead:sw?inform:display_time;
    assign lb0=leftover%10;
    assign lb1=leftover/10;
    assign segTestData={tifo,8'b0,lb1,lb0};
    assign effect=dead?8'hfc:8'h0c;
    Seg7Device segDevice(.clkIO(clkdiv[3]), .clkScan(clkdiv[15:14]), .clkBlink(clkdiv[25]),
		.data(segTestData), .point(8'h0), .LES(effect),
		.sout(sout));
	assign SEGLED_CLK = sout[3];
	assign SEGLED_DO =  sout[2];
	assign SEGLED_PEN = sout[1];
	assign SEGLED_CLR = sout[0];
    reg wasReady;
	always @(posedge clk) begin
		if (!rstn) begin
		end else begin
			wasReady <= keyReady;
			if (!wasReady&&keyReady) begin
				case (keyCode)
                    5'b10000:left_button=1;
                    5'b10001:down_button=1;
                    5'b10010:right_button=1;
                    5'b01100:tap=1;
                    5'b01101:up_button=1;
                    5'b01110:mark=1;
                    5'b00000:restart=1;
					default: ;
				endcase
			end
            else begin
                    left_button=0;
                    down_button=0;
                    right_button=0;
                    tap=0;
                    up_button=0;
                    mark=0;
                    restart=0;
            end
		end
	end
endmodule
module RAM_data(D,WE,clk,read,write,data);
    input wire clk,D,WE;
    input wire [7:0] read,write;
    output wire data;
    wire [7:0] address;
    assign address=WE?write:read;
    RAM256X1S memoryunit1(.D(D),.WE(WE),.WCLK(clk),.A(address),.O(data));
endmodule
