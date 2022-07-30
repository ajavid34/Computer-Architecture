`timescale 1ns/1ns


module mips_bench();
    reg clk, rst;
    wire mem_read, mem_write;
    wire [31:0] mem_in, address, mem_out;

    mips MIPS(mem_in, address, mem_out, mem_read, mem_write, 
              clk, rst);


    memory Memory(address, mem_out, mem_read,
                   mem_write, mem_in, clk);

    initial begin
    clk = 1'b0;
    rst = 1'b1;
    #20 rst = 1'b0;
    #6000 $stop;

    end



    always begin
    #10 clk = ~clk;
    end

endmodule
