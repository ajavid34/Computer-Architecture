 module mux_2_to_1(i0,i1,sel,y);
    input [10:0]i0,i1;
    input sel;
    output [10:0]y;
    assign y = sel?i1:i0;
    
endmodule

module add_sub(a,b,sel,y);
    input [5:0] a,b;
    input sel; //0 for add 1 for sub
    output [5:0] y;
    reg co;
    //a-b
    assign {co,y} = sel?(a + {~b}+6'b000001):a+b ;
endmodule


module comperator(a,b,y  );
    input [4:0] a,b;
    output y;
    assign y = {1'b0,a}>{1'b0,b};
endmodule


module Zero_Div(d,DivByZero);
    input [4:0]d;
    output DivByZero;

    assign DivByZero = ~(|d);

endmodule

module dreg5b(d,ld,clr,clk,q);
    input [4:0]d;
    input ld,clk,clr;
    output [4:0]q;
    reg [4:0]q;
       
    always @(posedge clk) 
        if(clr)
            q<=5'b0;
        else if(ld)
            q<=d;

endmodule

module wshreg11b(d,ser_in,setq0_to1,sclr,ld,sh,clk,q);
    input [10:0]d;
    input ser_in,sclr,ld,sh,clk,setq0_to1;
    output [10:0] q;
    reg [10:0] q;

    always @(posedge clk) 
        if(sclr)
            q<=11'b0;
        else if(ld)
            q<=d;
        else if (sh)
            q = {q[9:0],ser_in};
        else if (setq0_to1)
            q[0]=1'b1;
            
endmodule



module counter(clr,en,clk,co );
    input clr,en,clk;
    output co;
    reg [2:0]q;

    assign co = (q==5)?1'b1:1'b0;

    always @(posedge clk) 
        if(clr)
            q<=3'b000;
        else if (en)
            q<=q+1;

endmodule
