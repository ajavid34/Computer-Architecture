`timescale 1ns/1ns

module mips_bench();
    reg clk, rst;
    wire mem_read, mem_write;
    wire [31:0] mem_in, mem_adr, mem_out, inst, address;

    mips MIPS(mem_in, mem_adr, mem_out, mem_read, mem_write, 
            inst, address, clk, rst);

    data_memory data_mem(mem_adr, mem_out, mem_read,
                        mem_write, mem_in, clk);

    inst_mem Inst_mem(address, inst);

    initial begin
    clk = 1'b0;
    rst = 1'b1;
    #20 rst = 1'b0;
    #3600 $stop;

    end



    always begin
    #10 clk = ~clk;
    end

endmodule