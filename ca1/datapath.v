module datapath(inmux, muxsel, ldw, ser_in, clrw, shw,setq0_to1, 
                ov, divbyzero, add_sub_sel, is_neg,
                ind, ldd,clrd, clrcnt, cnt_en, co, clk,w);
    input [9:0]inmux;
    input [4:0]ind;
    input muxsel,ldw, ser_in, clrw, shw,setq0_to1; 
    input clk, add_sub_sel, ldd, clrd, clrcnt, cnt_en;
    output ov, divbyzero, is_neg, co;
    output [10:0]w;    

    wire [10:0]inw,outw;
    wire [5:0]add_sub_out;
    wire [4:0]outd;

    mux_2_to_1 m1({add_sub_out, outw[4:0]}, {1'b0,inmux}, muxsel, inw);
    
    wshreg11b wreg(inw, ser_in,setq0_to1, clrw, ldw, shw, clk, outw);

    add_sub aass(outw[10:5],{1'b0,outd},add_sub_sel,add_sub_out);
    
    dreg5b dreg(ind, ldd, clrd, clk, outd);

    comperator comp(inmux[9:5], ind, ov);

    Zero_Div divzero(ind, divbyzero);

    counter cnt(clrcnt, cnt_en, clk, co);

    assign w = outw;
    assign is_neg = add_sub_out[5];

endmodule