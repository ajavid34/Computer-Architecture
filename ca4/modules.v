`timescale 1ns/1ns


module shl2_32b(d_in, d_out);
    input [31:0] d_in;
    output [31:0] d_out;
    
    assign d_out = d_in << 2;
    
endmodule

module shl2_26b (d_in, d_out);
    input [25:0] d_in;
    output [27:0] d_out;
    
    assign d_out = {d_in, 2'b00};
    
endmodule

module reg_file (wr_data, rd_reg1, rd_reg2, wr_reg, reg_write,
                 rst, clk, rd_data1, rd_data2);

    input [31:0] wr_data;
    input [4:0] rd_reg1, rd_reg2, wr_reg;
    input reg_write, rst, clk;
    output [31:0] rd_data1, rd_data2;
    
    reg [31:0] registers [0:31];
    
    assign rd_data1 = (rd_reg1) ?  registers[rd_reg1] : 32'd0 ;
    assign rd_data2 = (rd_reg2) ?  registers[rd_reg2] : 32'd0 ;
    
    always @(posedge clk)
	    if (reg_write)
                if (wr_reg != 5'd0)
                    registers[wr_reg] = wr_data;
    assign registers[0] = 32'b0;
    
endmodule

module reg_32b (d_in, sclr, ld, clk, d_out);

    input [31:0] d_in;
    input sclr, ld, clk;
    output [31:0] d_out;
    reg [31:0] d_out;
    
    always @(posedge clk) begin
        if (sclr)
            d_out = 32'd0;
        else if (ld)
            d_out = d_in;
    end
        
endmodule


module mux4to1_32b(i0, i1, i2, i3, sel, y);
    input [31:0] i0, i1, i2, i3;
    input [1:0] sel;
    output [31:0] y;

    assign y = (sel == 2'b00) ? i0:
                (sel == 2'b01) ? i1:
                (sel == 2'b10) ? i2:
                i3;
endmodule

module mux3to1_5b (i0, i1, i2, sel, y);
    input [4:0] i0, i1, i2;
    input [1:0] sel;
    output [4:0] y;
    
    assign y = (sel == 2'b00) ? i0:
    (sel == 2'b01) ? i1:
    i2;
    
endmodule

module mux3to1_32b (i0, i1, i2, sel, y);
    input [31:0] i0, i1, i2;
    input [1:0] sel;
    output [31:0] y;
    
    assign y = (sel == 2'b00) ? i0:
    (sel == 2'b01) ? i1:
    i2;
    
endmodule

module mux2to1_32b (i0, i1, sel, y);
    input [31:0] i0, i1;
    input sel;
    output [31:0] y;
    
    assign y = (sel == 1'b1) ? i1 : i0;
    
endmodule

module mux2to1_11b (i0, i1, sel, y);
    input [10:0] i0, i1;
    input sel;
    output [10:0] y;
    
    assign y = (sel == 1'b1) ? i1 : i0;
    
endmodule


module inst_mem (adr, d_out);
    input [31:0] adr;
    output [31:0] d_out;
    
    reg [7:0] mem[0:2**10-1];

    initial
    begin
        
        $readmemb("inst.txt", mem);
    end
    
    assign d_out = {mem[adr[15:0]], mem[adr[15:0]+1], mem[adr[15:0]+2], mem[adr[15:0]+3]};
    
endmodule




module data_mem (adr, d_in, mrd, mwr, clk, d_out);
    input [31:0] adr;
    input [31:0] d_in;
    input mrd, mwr, clk;
    output [31:0] d_out;
    
    reg [7:0] mem[0:2**11-1]; 


    
    initial
    begin
        $readmemb("memory.txt", mem);
    end
    
    always @(posedge clk)
        if (mwr) begin
            {mem[adr], mem[adr+1], mem[adr+2], mem[adr+3]} = d_in;
        end
    
    assign d_out = (mrd) ? {mem[adr], mem[adr+1], mem[adr+2], mem[adr+3]} : 32'd0;
    

    reg [31:0] mem2000, mem2004;
    assign mem2000 = {mem[2000], mem[2001], mem[2002], mem[2003]};
    assign mem2004 = {mem[2004], mem[2005], mem[2006], mem[2007]};
	initial begin
        #10000
        $display("value of biggest number: %d",$signed(mem2000));
        $display("index of biggest number: %d", mem2004);
    end



endmodule

module alu (a, b, ctrl, y, zero);
    input [31:0] a, b;
    input [2:0] ctrl;
    output [31:0] y;
    output zero;
    wire [31:0] sub;
    assign sub = a - b;
    assign y = (ctrl == 3'b000) ? (a & b) :
    (ctrl == 3'b001) ? (a | b) :
    (ctrl == 3'b010) ? (a + b) :
    (ctrl == 3'b110) ? (a - b) :
    ((sub[31]) ? 32'd1: 32'd0);
    
    assign zero = (y == 32'd0) ? 1'b1 : 1'b0;
    
endmodule

module adder_32b (a, b, cout, sum);
    input [31:0] a, b;
    output cout;
    output [31:0] sum;
    
    assign {cout, sum} = a + b;
    
endmodule

