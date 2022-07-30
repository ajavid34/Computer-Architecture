module restoring_divider(w,d,start,rst,quo,rem,clk,done,ov,divbyzero,pss,outw);
    input [9:0]w;
    input [4:0]d;
    input start,rst,clk;

    output done,ov,divbyzero;
    output [4:0]quo;
    output [5:0]rem;
    output [3:0] pss;
    
  
    output [10:0]outw;
    wire ser_in,shw,setq0_to1,clrw,ldw,muxsel,
    add_sub_sel, is_neg, ldd, clrd,
    clrcnt, cnt_en, co;
    
    datapath dp(.inmux(w),.muxsel(muxsel),.ldw(ldw),.ser_in(ser_in),.clrw(clrw),.shw(shw),
                .ov(ov),.divbyzero(divbyzero),.add_sub_sel(add_sub_sel),.is_neg(is_neg),
                .ind(d),.ldd(ldd),.clrd(clrd),.clrcnt(clrcnt),.cnt_en(cnt_en),
                .co(co),.clk(clk),.setq0_to1(setq0_to1),.w(outw));

    controller cont(.start(start),.rst(rst),.clrw(clrw),.clrcnt(clrcnt),.clrd(clrd),
                    .muxsel(muxsel),.ldw(ldw),.ldd(ldd),.ser_in(ser_in),
                    .add_sub(add_sub_sel),.cnt_en(cnt_en),.setq0_to1(setq0_to1),
                    .ov(ov),.divbyzero(divbyzero),.is_neg(is_neg),.shw(shw),
                    .co(co),.done(done),.clk(clk),.pss(pss));
    assign {rem,quo} = outw;


endmodule
