
`timescale 1ns/1ns

module tb();
    reg [9:0]w;
    reg [4:0]d;
    reg rst,start,clk;

    wire [4:0]quo;
    wire [5:0]rem;
    wire done,ov,divbyzero;
    wire [3:0]pss;
    wire [10:0]outw;
    restoring_divider rd(w,d,start,rst,quo,rem,clk,done,ov,divbyzero,pss,outw);




    initial
    begin

    start = 1'b0;
    rst = 1'b0;
    clk = 1'b0;
     rst = 1'b1;
    #20 rst = 1'b0;
    #20 w = 10'b0001001011; //75
    #20 d = 5'b01011;       // 11 => q=6,r=9
    #20 start = 1'b1;
    #20 start = 1'b0;
    #600
    #20 w = 10'b0001011011;    //91
    #20 d = 5'b01111;    // 15 => q = 6, r=1
    #20 start = 1'b1;
    #20 start = 1'b0;
    #600
    #20 w = 10'b0011010101;    //213
    #20 d = 5'b11001;    // 25 => q=8, r=13
    #20 start = 1'b1;
    #20 start = 1'b0;
    #600
    #20 w = 10'b1111010101;    //OV
    #20 d = 5'b11001;    
    #20 start = 1'b1;
    #20 start = 1'b0;
    #600
    #20 w = {$random}%(2^10) ;
    #20 d = {$random}%(2^5);
    #20 start = 1'b1;
    #20 start = 1'b0;
    #1000 $stop;

    end


    always begin
        #10 clk=~clk;
    end

endmodule

