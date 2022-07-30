
`define START 4'b0000
`define CLR 4'b0001
`define LOAD 4'b0010
`define OV_ZERO 4'b0011
`define SHIFTL 4'b0100
`define SUB 4'b0101
`define LOAD2 4'b0110
`define CHECK 4'b0111
`define Q0 4'b1000
`define DONE1 4'b1001
`define DONE2 4'b1010
`define RETURN 4'b1011
`define NEG 4'b1100

module controller(start, rst, clrw,clrcnt,clrd,muxsel,ldw,ldd,ser_in,
    add_sub,cnt_en,setq0_to1,ov,divbyzero,is_neg,shw,
    co,done,clk,pss);
    input start, rst, ov, divbyzero, is_neg, co, clk;
    
    output clrw, clrcnt, clrd, muxsel, ldd, ldw,shw;
    output ser_in, add_sub, cnt_en, setq0_to1, done;
    output [3:0] pss;


    reg clrw, clrcnt, clrd, muxsel, ldd, ldw,shw;
    reg ser_in, add_sub, cnt_en, setq0_to1, done;

    reg [3:0] ps, ns;

    always @(posedge clk) 
        if(rst)
            ps = 4'b0000;
        else 
            ps=ns;

    always @(ps or start) begin
        case(ps)
            `START: ns = start?`CLR:`START;
            `CLR: ns = `LOAD;
            `LOAD: ns = `OV_ZERO;
            `OV_ZERO: ns = (ov|divbyzero)? `DONE1:`SHIFTL;
            `SHIFTL: ns = `SUB;
            `SUB: ns = is_neg? `CHECK :`LOAD2;
            `LOAD2: ns = `Q0;
            `CHECK: ns = co? `DONE1: `SHIFTL;
            `Q0: ns = `RETURN;
            `RETURN: ns = `CHECK;
            `DONE1: ns = `DONE2;
            `DONE2: ns = `START;
        endcase
    end
    
    always @(ps) begin
        {clrw, clrcnt, clrd, muxsel, ldd, ldw,ser_in,
         add_sub, cnt_en, setq0_to1, done} = 11'b00000001000;

         case(ps)
            `START: done = 1'b0;
            `CLR: {clrw,clrd,clrcnt}=3'b111;
            `LOAD: {clrcnt,clrd,clrw,ldw,ldd,muxsel}=6'b000111;
            `OV_ZERO: {ser_in,muxsel,ldw,ldd}=4'b0000;
            `SHIFTL: {add_sub,cnt_en,shw}=3'b111;
            `SUB: {cnt_en,shw}=2'b00;
 	    `LOAD2: ldw = 1'b1;
            `CHECK:  ;
            `Q0: {setq0_to1,ldw}=2'b10;
            `RETURN: setq0_to1=1'b0;
            `DONE1: done=1'b1;
            `DONE2: ;
        
         endcase
    end

    

    assign pss = ps;    
endmodule
