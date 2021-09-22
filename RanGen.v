module RanGen(clk,reset,Y);
    input clk,reset;
    output [7:0] Y;

    reg [7:0] LFSR,LFSR_next;
    reg feedback;

    always @(posedge clk)
        if(~reset)LFSR=8'b0;
        else LFSR=LFSR_next;

    always@(LFSR)begin
        feedback=LFSR[7]^(~|LFSR[6:0]);
        LFSR_next[7]=LFSR[6];
        LFSR_next[6]=LFSR[5];
        LFSR_next[5]=LFSR[4];
        LFSR_next[4]=LFSR[3]^feedback;
        LFSR_next[3]=LFSR[2]^feedback;
        LFSR_next[2]=LFSR[1]^feedback;
        LFSR_next[1]=LFSR[0];
        LFSR_next[0]=feedback;
    end
    assign Y=LFSR;
endmodule
        
